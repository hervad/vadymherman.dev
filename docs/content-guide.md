# Content guide

## Front matter (posts)

```yaml
---
title: "Hardening AlmaLinux 10 with Ansible"
description: "140–160 characters. Used for search results and social cards."
date: 2026-10-07
draft: true                # flip to false to publish
translationKey: "almalinux-hardening"   # same value in the EN and PL versions
slug: "hardening-almalinux-10-ansible"  # optional; PL version can have a Polish slug
tags: ["ansible", "almalinux", "security"]
tested: ["AlmaLinux 10.2", "ansible-core 2.18"]  # optional: "Tested on ..." line; omit if not a how-to
showUpdated: false         # optional: hide the "Updated" date (it comes from git, see below)
comments: true             # from step 2.5
---
```

The meta line under a post's title shows only what applies: the date always; **Updated** when
git has a commit for the file on a later day than `date` (linked to its GitHub history; a manual
`lastmod` is ignored because git wins); **Tested on** only if `tested` is set. No reading time:
see docs/design-spec.md.

## Files

- Posts are page bundles: `content/en/blog/<slug>/index.md` with images in the same folder.
- Translations live at `content/uk/blog/<slug>/index.md` (Ukrainian) and
  `content/pl/blog/<slug>/index.md` (Polish) with the same `translationKey`. English is the
  default. A post may exist in only one language; that's fine.

## Tags

Lowercase English slugs in both languages. Allowed list (ask before adding new ones):
`linux`, `rhel`, `almalinux`, `kvm`, `libvirt`, `vmware`, `ansible`, `automation`, `python`,
`networking`, `security`, `debugging`, `kernel`, `sre`, `observability`, `ci-cd`, `homelab`,
`career`, `meta`.

## Writing

- Kai writes the posts; Claude suggests structure, edits for clarity, checks technical accuracy.
- Polish text is reviewed by Kai, never published as raw machine translation.
- Code blocks always have a language (```bash, ```yaml) for highlighting.
- Every image needs meaningful alt text.
