# 0005. No CDN at launch

- Status: accepted
- Date: 2026-10-07

## Context
A single EU origin is fast for EU visitors; US/Asia visitors pay extra latency. A CDN would hide
the origin and the TLS/HTTP/3 setup that's part of the portfolio.

## Decision
Launch without a CDN. Measure TTFB from 3 continents (WebPageTest) after launch; revisit with data.

## Consequences
Simpler setup and full control. Possible follow-up experiment and blog post (step 3.6).
