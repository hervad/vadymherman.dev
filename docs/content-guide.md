# Content guide

## Front matter (posts)

```yaml
---
title: "Hardening AlmaLinux 10 with Ansible"
description: "140–160 characters. Used for search results and social cards."
date: 2026-10-07
lastmod: 2026-10-07        # optional; set when you meaningfully update a post
draft: true                # flip to false to publish
translationKey: "almalinux-hardening"   # same value in the EN and PL versions
slug: "hardening-almalinux-10-ansible"  # optional; PL version can have a Polish slug
tags: ["ansible", "almalinux", "security"]
comments: true             # from step 2.5
---
```

## Files

- Posts are page bundles: `content/en/blog/<slug>/index.md` with images in the same folder.
- A Polish translation lives at `content/pl/blog/<slug-or-polish-slug>/index.md` with the same
  `translationKey`. A post may exist in only one language; that's fine.

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
