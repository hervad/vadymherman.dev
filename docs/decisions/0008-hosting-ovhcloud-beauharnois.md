# 0008. Hosting: OVHcloud VPS-1 in Beauharnois (Canada), monthly

- Status: accepted (supersedes 0004)
- Date: 2026-10-08

## Context
ADR 0004 picked Warsaw for an EU-first, mostly Polish audience. Two things changed:

1. **Audience:** expected visitors are Europe plus the US and Canada, not specifically Poland.
2. **Stock:** on 2026-10-08 every European location for VPS-1 2027 (Warsaw, Limburg, Gravelines,
   Roubaix, Strasbourg, Erith and all LocalZones) showed "Niedostępny / Brak dostępnych serwerów".
   Only North America was orderable.

Rough round-trip times (typical published figures, not measured here): Beauharnois is about
15–30 ms from US East/Canada and 80–100 ms from western/central Europe; a western-European
location is the mirror image. With both continents in the audience, one side pays roughly
+0.2–0.3 s on the first page either way, far under the 2.5 s LCP budget for ~1.5 KB pages.

## Options considered
1. **Beauharnois now, no commitment**: available today, close to North America, acceptable for
   Europe; monthly billing keeps the option to move. GitHub Actions runners are mostly in the US,
   so deploys get slightly faster.
2. **Wait for a European location**: better for European visitors, unknown wait.
3. **Another provider** (Hetzner, Scaleway, OVHcloud Public Cloud): more research, loses the
   account setup already done.

## Decision
OVHcloud VPS-1 2027 in Beauharnois (Canada East), AlmaLinux 10, no fixed term.
2 vCores, 4 GB RAM, 40 GB NVMe, 500 Mbps unmetered.
19.20 zł net / **23.62 zł gross per month** (automated standard backup included free as a promotion).
Paid by a saved payment method so monthly renewals are automatic.

## Consequences
- ADR 0005 (no CDN at launch) still holds; step 3.6 measures whether a CDN is worth it for both
  continents.
- Admin access from Poland crosses the Atlantic (~110–130 ms): fine for SSH and Ansible.
- Revisit after analytics (step 2.6): if most visitors turn out to be European, move to an EU
  location once stock returns. No commitment means no penalty for moving.
- GDPR: Canada is recognised by the EU as providing adequate protection (to verify before step 2.6
  stores any visitor data).
