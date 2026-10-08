# 0003. Server OS: AlmaLinux 10

- Status: accepted
- Date: 2026-10-07

## Context
Long support window, minimal maintenance, and skills that transfer to Kai's RHEL-based job.

## Options considered
1. **AlmaLinux 10**: RHEL 10 compatible, security support to 2035, SELinux, firewalld, dnf.
2. **Rocky Linux 10**: equivalent; either is fine.
3. **Debian 13**: excellent, but less aligned with RHEL career story.
4. **Fedora Server**: ~13-month lifecycle, too much churn for a server.

## Decision
AlmaLinux 10 with SELinux enforcing.

## Consequences
Hardening work (SELinux contexts, firewalld, dnf-automatic) doubles as RHCSA/RHCE practice.
