# 0002. Web server: Caddy

- Status: accepted
- Date: 2026-10-07

## Context
Static files only. Need HTTPS with automatic renewal, HTTP/2 + HTTP/3, precompressed Brotli,
security headers, short config.

## Options considered
1. **Caddy**: automatic HTTPS, HTTP/3 on by default, `precompressed br zstd gzip` built in,
   ~30-line config. Installed from the @caddy/caddy COPR on EL10. Con: less common in job ads.
2. **nginx**: ubiquitous. Con: certbot needed, Brotli via EPEL module, HTTP/3 build to verify.

## Decision
Caddy. A later post may reproduce the setup in nginx and benchmark both (step 3.6).

## Consequences
Fewer moving parts (no certbot timer). Package comes from COPR, so pin/watch its updates.
