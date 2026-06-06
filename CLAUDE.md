# OraQuest — project notes

Single-file vanilla-JS SPA. The whole app lives in `OraQuest.html`; `tailwind.css`
is precompiled. Deployed as a static site on **Netlify** (`publish = "."`).

## SEO / AdSense infra (Fase 1 — done)

Production canonical domain: **https://horusquest.com**

Static files served at the site root (must stay versioned, they deploy):
- `robots.txt`, `sitemap.xml`, `ads.txt`, `404.html`, `assets/og-image.png`

`netlify.toml` routing:
- legacy `301`: `/shop→/store`, `/guessora→/oraguess` (+ `es`/`fr` variants)
- `200` rewrites: an explicit allow-list of the **63 valid routes** → `/OraQuest.html`
- catch-all `/* → /404.html` with **status 404** (real 404, no soft-404)
- real static files win over redirects (Netlify default `force = false`)

### ⚠️ Keep these in sync with `ROUTE_PATHS` (in `OraQuest.html`)
`sitemap.xml` and `netlify.toml` are **generated mirrors** of `ROUTE_PATHS`
(21 routes × 3 langs = 63 URLs). If routes change, regenerate:

```
node tools/_gen-sitemap.js     # rewrites sitemap.xml
node tools/_gen-netlify.js      # rewrites netlify.toml
node tools/_gen-og-image.js     # regenerates assets/og-image.png from assets/ora.png
```

Note: `tools/` is **gitignored** (generators do not deploy) — they are local dev
helpers only. `ads.txt` is a placeholder comment until the real AdSense publisher
ID exists; do not invent a `pub-XXXX` id.

## Validation
- `npm run lint` — lints the inline `<script>` block
- `npm test` — full suite (architecture, leaderboard, quiz, orawords, letter-rush,
  vocab, anagram, daily + data/migration checks)
- `npm run build` — `lint && test`
- `check-migration.js` rejects any literal `file://` in `OraQuest.html` — use
  "local file protocol" in comments, never `file://`.

## Out of scope / pending (Fases 2–3)
- Thin/placeholder content: blog has no real articles; shop products are "coming soon".
- Privacy policy lacks AdSense/third-party-cookie disclosures; no certified CMP yet.
- Confirm `horusquest.com` is actually mapped in the Netlify/DNS dashboard.
- Netlify routing (301/404, static-file serving) only verifiable on a deploy preview,
  not via the local file-serving preview.
