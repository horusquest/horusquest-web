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

## OraGuess (guess game) — fairness notes (Fase 2e tanda 1 — done)

The guess game lives in `OraQuest.html`: `ANIMALS` bank (100 entries, en/es/fr,
each with `emoji`, `category`, `difficulty`, a free `starterClue`, 3 extra
`clues`, 2 `facts`, optional `aliases`) + engine wrapped in
`__GUESSENGINE_START__/END__` sentinels.

**Clue flow:** every round opens with the `starterClue` shown free (it does NOT
count toward score). The 3 `clues` are the "extra clues" revealed on demand via
`revealClue()` (`gs.revealed` 0→3). Score = `max(50, 300 - revealed*50)`, so a
starter-only correct guess earns the full 300. `nextAnimal()` resets
`gs.revealed` to 0 (starter visible, extra clues 0/3). The 100 starterClues were
inserted with the one-shot `tools/_add-starter-clues.js` (gitignored).

Fixed the "tigre → oso" unfairness (generic clues + harsh scoring):
- **Per-round attempts.** `MAX_FAILED_ATTEMPTS` (3) is per *animal*, not per game.
  `nextAnimal()` resets `gs.failed`; running out reveals the answer + facts and
  advances. The game only ends after the last round.
- **Tolerant matching** via `guessMatches()`: exact name/alias in any language,
  regular plurals (s/es/ies/x), accents+case (`normalizeGuess`), and a single-edit
  (Levenshtein ≤1) allowance only on words ≥5 chars (so cat/bat/rat never collide).
  Scoring unchanged.
- **Discriminant first clues** for confusable animals (bear, lion, fox, spider,
  worm, newt, salamander). Keep the first clue specific enough to point at ~1 answer.

Pending (approved plan, NOT yet done): taxonomy fixes (spider/scorpion=arachnid,
snail=mollusk, worm=annelid), structured edu data (habitat/diet/region),
difficulty/category selector, more animals (leopard/jaguar/puma), broader tests.

## Validation
- `npm run lint` — lints the inline `<script>` block
- `npm test` — full suite (architecture, leaderboard, quiz, guess, orawords,
  letter-rush, vocab, anagram, daily + data/migration checks)
- `npm run build` — `lint && test`
- `check-migration.js` rejects any literal `file://` in `OraQuest.html` — use
  "local file protocol" in comments, never `file://`.

## Out of scope / pending (Fases 2–3)
- Thin/placeholder content: blog has no real articles; shop products are "coming soon".
- Privacy policy lacks AdSense/third-party-cookie disclosures; no certified CMP yet.
- Confirm `horusquest.com` is actually mapped in the Netlify/DNS dashboard.
- Netlify routing (301/404, static-file serving) only verifiable on a deploy preview,
  not via the local file-serving preview.
