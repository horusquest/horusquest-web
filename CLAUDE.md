# OraQuest — project notes

Single-file vanilla-JS SPA. The whole app lives in `OraQuest.html`; `tailwind.css`
is precompiled. Deployed as a static site on **Netlify** (`publish = "."`).

## SEO / AdSense infra (Fase 1 — done)

Production canonical domain: **https://horusquest.com**

Static files served at the site root (must stay versioned, they deploy):
- `robots.txt`, `sitemap.xml`, `ads.txt`, `404.html`, `assets/og-image.png`

`netlify.toml` routing:
- legacy `301`: `/shop→/store`, `/guessora→/oraguess` (+ `es`/`fr` variants)
- `200` rewrites: an explicit allow-list of the **66 valid routes** → `/OraQuest.html`
- catch-all `/* → /404.html` with **status 404** (real 404, no soft-404)
- real static files win over redirects (Netlify default `force = false`)

### ⚠️ Keep these in sync with `ROUTE_PATHS` (in `OraQuest.html`)
`sitemap.xml` and `netlify.toml` are **generated mirrors** of `ROUTE_PATHS`
(22 routes × 3 langs = 66 URLs). If routes change, regenerate:

```
node tools/_gen-sitemap.js     # rewrites sitemap.xml
node tools/_gen-netlify.js      # rewrites netlify.toml
node tools/_gen-og-image.js     # regenerates assets/og-image.png from assets/ora.png
```

Note: `tools/` is **gitignored** (generators do not deploy) — they are local dev
helpers only. `ads.txt` is a placeholder comment until the real AdSense publisher
ID exists; do not invent a `pub-XXXX` id.

## OraGuess (guess game) — fairness + education notes (Fase 2e tandas 1–2 — done)

The guess game lives in `OraQuest.html`: `ANIMALS` bank (100 entries, en/es/fr,
each with `emoji`, `category`, `difficulty`, structured taxonomy
(`animalClass`, `habitat`, `diet`, `size`, `region[]`, `lifestyle`, optional
`role`, `traits[]`), a free `starterClue`, 3 extra `clues`, 2 `facts`, optional
`aliases`) + engine wrapped in `__GUESSENGINE_START__/END__` sentinels.

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

**Taxonomy + educational data (tanda 2 — done).**
- **Structured taxonomy** on all 100 animals as compact tokens, translated at
  render time by `TAXO_I18N` (en/es/fr) via `taxoLabel()`. Token-based keeps the
  bank small, consistent and testable (tests reject any out-of-vocab token). The
  one-shot `tools/_add-taxonomy.js` (gitignored) injected the fields.
- **Corrected classifications:** dolphin/whale/orca = mammal (not fish),
  bat = mammal (not bird), penguin/ostrich = bird (flightless), spider/scorpion =
  arachnid, snail/octopus/squid/oyster = mollusk, worm = annelid,
  crab/lobster/shrimp = crustacean, jellyfish = cnidarian, frog/toad/newt/
  salamander/axolotl = amphibian. `category` (gameplay grouping) was left intact;
  `animalClass` is the taxonomic source of truth.
- **Educational result card** (`GuessEduCard` + `animalEduCard()`): on every
  resolved round (correct, 3 fails, or give-up) it shows name, type/class,
  habitat, diet, region, size, lifestyle, role, traits, 2–3 facts and a
  gender-safe "What you learned" sentence (`animalEduText()`), all in en/es/fr.
- **Feedback:** correct → positive banner with points earned
  (`guessRoundPoints()`); fail → encouragement + the key clue (`animalKeyClue()`,
  the discriminant starter clue) before the card, then advance — no total Game
  Over (per-round attempts still apply). `guess-engine.test.js` covers taxonomy,
  trilingual cards, card-on-win/fail, and a full 10-round mixed flow.

Pending (approved plan, NOT yet done): difficulty/category selector for OraGuess,
large animal-bank expansion (e.g. leopard/jaguar/puma), possible new categories,
and any later tests/UX polish.

## OraMath (maths games) — Fase 1 done

Route `oramath` (`/oramath` + es/fr, indexable), modes via `state.params.mode`
like OraWords. Pure logic lives in the `__MATHENGINE_START__/END__` sentinel
block (`MathEngine` IIFE: injectable rng/date, no DOM/state/clock) — tested by
`tests/oramath-engine.test.js` (56 tests incl. NumDrop + EquaCode, seeded
mulberry32 property tests).

- **Age mapping:** UI uses the site's 6 `AGE_GROUPS`; `ORAMATH_AGE_BANDS`
  collapses them to the spec's 3 bands (`6-8`/`9-12`/`13+`) + `timeFactor`.
  Leaderboard records keep the real ageGroup id.
- **Retention core:** `oramath:profile` (XP; level L→L+1 costs L×100),
  `oramath:streak` (global daily streak, **local-date** `todayKey()`, milestones
  3/7/30), `oramath:records` (per `mode|ageGroup|difficulty`, strictly-higher
  replaces). `finishMathGame()` is the end-of-game funnel for record + XP +
  streak; the leaderboard save is a separate, optional step on the results
  screen via `saveMathScore()` (3–4 char alias card, same validation flow as
  Quiz/OraGuess `saveScore()`). The suspicious flag is intentionally NOT set
  (Sprint legitimately has <1.5s answers).
- **¿Verdad o Trampa?** (`truth-or-trap`): trap equations from `TT_TABLE`
  (engine re-checks falseness; accidental truths fall back to off-by-1 — the
  property test re-evaluates every statement independently). Time bar is a pure
  CSS animation; the `.tt-bar` node is **recreated per question** (same-node
  reuse would freeze it). Swipe via pointer events (`touch-action:pan-y`),
  buttons + ←/→ keys as accessible path. 3 lives, per-question `setTimeout`
  with route/session guards.
- **Ora Sprint** (`math-sprint`): 60s, `endsAt`-based (+2s bonus = `endsAt +=
  2000`), 250ms interval that self-clears via guards, custom on-screen keypad
  (no `<input>` → OS keyboard never opens), combo ×(1+⌊n/3⌋) cap ×5.
- **NumDrop** (`numdrop`): number-fusion puzzle. Tap a column to drop the current
  tile; gravity settles it (`grid[row][col]`, row 0 = top), then any **connected
  group** of orthogonally-adjacent tiles summing to the level `target` clears and
  cascades after gravity (`numdropResolve` greedily clears groups found by
  `numdropFindGroup`, an ordered-extension connected-subset search pruned by sum +
  a shared visit budget so a full board never hangs — not just pairs, so a row
  like [2,1,2,2]=7 clears). Clearing enough tiles advances the level (re-rolls the
  target + raises `mergesToNext`); a full board ends the game. Special tiles:
  **locked** (can't merge until a clear happens beside it, then unlocks),
  **wild** ★ (pairs with any neighbour), **negative** (lets pairs overshoot the
  target, 13+ only). 13+ hard adds **pressure mode** — `numdropPushRow` raises a
  new bottom row every 15s (same self-clearing-interval guard as Sprint;
  overflow = game over). Sizes/specials scale by band in `NUMDROP_TABLE`. Whole
  model is plain data → tests drive full games headlessly. Tap columns or number
  keys 1–N. The 3 games share one `MATH_GAMES` registry (icon/name/sub/start/
  state) consumed by the hub cards, setup, results, share and save flows.
- **EquaCode** (`equacode`): the daily hidden-equation puzzle (Wordle/Nerdle for
  maths). Engine generates ONE puzzle per local day per age band, deterministic
  from `equacodeSeed("YYYY-MM-DD|band|difficulty")` → a local mulberry32 (no
  backend; rolls at local midnight via host `todayKey()`). Shape-based generator
  (`EQUACODE_TABLE` → operand/result digit-counts so the string length is exact);
  every generated answer is a valid equation by construction. Guesses are checked
  by a hand-rolled parser/evaluator (`equacodeParseSide` + `equacodeEval`:
  ×÷-before-+−, exact division, **no `eval`**) — same evaluator used for
  generation so they can't disagree. `equacodeFeedback` is Wordle two-pass with
  duplicate handling; `equacodeKeyStates` colours the on-screen keyboard;
  `equacodeGrid` builds the 🟩🟨⬜ share text (via `shareResult`). Host stores
  per-day progress + Wordle stats (streak of days solved, win%, attempt
  distribution) in `oramath:equacode`; a finished day restores its board instead
  of replaying. Completion calls `finishMathGame` once (XP/global streak/record).
  Scaling: 6-8 = 5 chars, addition, 8 tries; 9-12 = 8 chars, +/−, 6 tries; 13+ =
  8 chars ×÷ (hard = 9 chars, two operators with precedence). Keyboard: on-screen
  + physical digits/operators/Enter/Backspace.
- **Leaderboards page** now renders `LeaderboardTabs()` (was locked to the
  OraQuest tab); OraMath has its own tab via `LB_TAB_META`.
- The OraMath hub now ships all 4 games (no "coming soon" card). Pending (spec
  approved, NOT built): Camino Mágico, Ojo de Ora, achievements/badges,
  OraMath share emoji-grids.

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
