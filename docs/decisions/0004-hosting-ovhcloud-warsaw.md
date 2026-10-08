# 0004. Hosting: OVHcloud VPS in Warsaw

- Status: superseded by 0008 (audience is Europe + North America; EU locations sold out on 2026-10-08)
- Date: 2026-10-07

## Context
Self-hosting is part of the portfolio. Audience is EU-first. Budget: a few euros per month.

## Options considered
1. **OVHcloud VPS-1 (Warsaw)**: cheap, Polish data centre, unlimited traffic, anti-DDoS.
2. **Hetzner**: popular, but 2026 price increases and cheap plans unavailable at research time.
3. **Mikr.us**: very cheap, good as a second node (monitoring/backups), too small as primary.

## Decision
OVHcloud VPS-1 in Warsaw; Mikr.us later as the monitoring/backup node (step 3.1).

## Consequences
Lowest latency for Polish visitors; non-EU visitors pay extra round trips (see 0005).
