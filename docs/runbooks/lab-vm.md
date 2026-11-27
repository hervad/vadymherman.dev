# Lab VM (`vh-lab`): a local twin of the VPS

Every Ansible role is proven here before it touches production (roadmap step 1.3). The VM runs
on Kai's Fedora desktop under KVM/libvirt (`qemu:///system`), built from the same kind of image
the VPS uses: the official AlmaLinux 10 cloud image, configured on first boot by cloud-init.

| | Lab VM | VPS |
|---|---|---|
| Image | AlmaLinux-10-GenericCloud-10.2-20260817.0 | OVHcloud's AlmaLinux 10.2 |
| First boot | cloud-init (`almalinux` user, our key, `ssh_pwauth: true`) | cloud-init (`almalinux`, emailed password) |
| Resources | 2 vCPU, 2 GB RAM, 20 GB disk | 2 vCores, 4 GB RAM, 40 GB NVMe |
| Address | `192.168.122.176` (libvirt `default` NAT network, DHCP) | `192.99.43.201` |
| Inventory | `infra/ansible/inventory/local.yml` | `infra/ansible/inventory/production.yml` |

Starting state verified on 2026-10-10: AlmaLinux 10.2, SELinux Enforcing, `cloud-init status: done`,
the same sshd drop-ins as the VPS (`40-redhat-crypto-policies`, `50-cloud-init` with
`PasswordAuthentication yes`, `50-redhat`), `almalinux` with passwordless sudo. Only difference:
the hostname stayed `localhost` (cloud-init didn't apply it); the `base` role sets it.

## Daily use

```bash
virsh -c qemu:///system start vh-lab        # boot (about 20 s)
virsh -c qemu:///system domifaddr vh-lab    # its IP address
virsh -c qemu:///system shutdown vh-lab     # clean shutdown
ssh -i ~/.ssh/vadymherman_vps -o IdentitiesOnly=yes kai@192.168.122.176

cd infra/ansible
ansible vh-lab -m ansible.builtin.ping                  # lab is the default inventory → "pong"
ansible-playbook playbooks/site.yml --check --diff      # dry run as kai (sudo password from the vault)
```

Since `users_ssh` ran (2026-10-10), only `kai` (and later `deploy`) may log in; `almalinux` is refused.
Ansible needs `infra/ansible/.vault_pass` (the vault password, also in KeePassXC) to decrypt
`secrets.vault.yml`. After a **reset**, the fresh VM only has `almalinux` again: run the playbook
once with `-e ansible_user=almalinux` (phase 1), then without it (phase 2), then once more (`changed=0`).

## How it was built (and how to rebuild it)

**1. Image, verified twice.** AlmaLinux signs its checksum list; the signing key ships in Fedora's
own `distribution-gpg-keys` package, so the key reaches us by a different route than the image.

```bash
B=https://repo.almalinux.org/almalinux/10/cloud/x86_64/images
IMG=AlmaLinux-10-GenericCloud-10.2-20260817.0.x86_64.qcow2      # dated name, not "latest"
curl -fsSO "$B/CHECKSUM" -fsSO "$B/CHECKSUM.asc" -fsSO "$B/$IMG"
K=$(mktemp -d); gpg --homedir "$K" --import /usr/share/distribution-gpg-keys/alma*/RPM-GPG-KEY-AlmaLinux-10
gpg --homedir "$K" --verify CHECKSUM.asc CHECKSUM     # expect: Good signature, key EE6DB7B9…C2A1E572
grep " $IMG\$" CHECKSUM | sha256sum -c -              # expect: OK
```

**2. Into libvirt without sudo.** The `images` pool is `/var/lib/libvirt/images` (the right place
for SELinux); `virsh vol-upload` lets libvirt (running as root) store it with the correct label.

```bash
V="virsh -c qemu:///system"
$V vol-create-as images almalinux10-base.qcow2 "$(stat -c %s "$IMG")" --format qcow2
$V vol-upload --pool images almalinux10-base.qcow2 "$IMG"
$V vol-create-as images vh-lab.qcow2 20G --format qcow2 \
   --backing-vol almalinux10-base.qcow2 --backing-vol-format qcow2   # thin overlay
```

The base image is never written to; the VM writes only into the overlay (tracing paper over a map).

**3. Create the VM** (run in your own terminal: it reads your public key from `~/.ssh/`, which
Claude Code is not allowed to read):

```bash
U=$(mktemp) && printf '#cloud-config\nhostname: vh-lab\nssh_pwauth: true\nssh_authorized_keys:\n  - %s\n' \
  "$(cat ~/.ssh/vadymherman_vps.pub)" > "$U" && virt-install --connect qemu:///system --name vh-lab \
  --osinfo almalinux10 --memory 2048 --vcpus 2 --import --disk vol=images/vh-lab.qcow2,bus=virtio \
  --network network=default,model=virtio --graphics none --noautoconsole --cloud-init user-data="$U"; rm -f "$U"
```

## Reset to a factory-fresh server (to re-test roles from zero)

```bash
V="virsh -c qemu:///system"
$V destroy vh-lab; $V undefine vh-lab --nvram 2>/dev/null || $V undefine vh-lab
$V vol-delete --pool images vh-lab.qcow2
$V vol-create-as images vh-lab.qcow2 20G --format qcow2 --backing-vol almalinux10-base.qcow2 --backing-vol-format qcow2
# then step 3 again; afterwards forget the old host key and check the (possibly new) address:
ssh-keygen -R 192.168.122.176; $V domifaddr vh-lab
```

A new VM gets a new MAC address, so DHCP may hand out a different IP: update `local.yml` if so.

## Gotchas met while building it

- **`!` means two different things.** At Claude Code's prompt, `! cmd` runs a shell command and
  shows Claude the output. In a normal terminal, `!` *negates the exit status*: `! a && b` skips
  `b` because the success of `a` became "failure". Paste lab commands into a terminal without `!`.
- **Host keys on the lab** are accepted on first use (`StrictHostKeyChecking=accept-new`): the
  traffic never leaves the desktop's virtual switch, so nobody can sit in the middle. Not acceptable
  for the VPS, where the fingerprint was checked on the provider's console first (step 0.3).
- **group_vars location.** `ansible-playbook` loads `group_vars/` only next to the inventory file
  or the playbook. The skeleton had it beside both, so playbooks saw `site_domain=UNDEFINED`; it
  now lives in `inventory/group_vars/all/` (a folder, so `secrets.vault.yml` loads too).
- **Claude Code only:** Ansible refuses non-blocking stdio in Claude's sandbox ("requires blocking
  IO"); Claude runs it as `ansible … </dev/null 2>&1 | cat`. Not needed in a normal terminal.
