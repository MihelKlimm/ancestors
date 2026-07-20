# Handoff — state as of 2026-07-20

Where this project stands, and what's open. Read this first next session.

## What exists and is done

- **Repo** `github.com/MihelKlimm/ancestors` — public, working tree clean, all pushed
  (HEAD `4ba540c`). Raw genotype file is **gitignored** and lives only in the user's
  Google Drive (share link), never committed.
- **Live page** `https://ancestry-map-d88.pages.dev` — five sections, `noindex`,
  on the user's own Cloudflare account (project `ancestry-map`, branch `main`).
  Redeploy: `cd /home/misha/Racket && set -a && . ./.racket-cf.env && set +a &&
  npx wrangler@4 pages deploy /path/to/site --project-name=ancestry-map --branch=main`.
  (The CF token is borrowed from the Racket env file — same Cloudflare account.)

## The genetic result (settled)

- Maternal **mtDNA U5b**; paternal **Y-DNA I2a1b (I-M423)**.
- Reproduce: `python3 analysis/mt_haplogroup.py <raw.txt>` and
  `./analysis/y_haplogroup.sh <raw.txt> results/`.
- **The build trap** (don't forget): file is GRCh38, yhaplo wants GRCh37, chrY offset
  is NOT constant → liftover via UCSC chain, verified against M170 → 14,847,792.

## Sections on the page

1. Deep time — map + 3 real Wikimedia photos (Cheddar skull, Djehutynakht head,
   Loschbour) + La Braña drawing.
2. Last 2,000 years — migration + graded carriers; the "Slavic" hedge (Gagauz 24% vs
   Sorbs 4%).
3. Aristocrats — the two Bosnian knezovi; imaginative reconstruction fenced off in a
   dashed "IMAGINED" block.
4. Cultural figures — the documented absence, contrasted with tested figures elsewhere.
5. Last 100 years — frequency bars + drawn folk culture (Dinaric South Slavs; Sami).

## Open items (all need the USER, or a decision)

1. **Delete the mis-uploaded Drive file** — a genetic summary landed in the wrong
   Google account (axel-t, not mihel.klimm). Drive id
   `1Za1MDV1SfcvECh6W3Vt79UGPrS-NpHe0`. The connector has no delete method, so only the
   user can remove it. See `../../.claude/.../memory/feedback_user_account_identity.md`.
2. **Repo visibility** — it is PUBLIC and carries the user's genetic results. Offered to
   make it private; user hasn't decided. `gh repo edit MihelKlimm/ancestors --visibility private`.
3. **The one open science question: placement WITHIN M423.** The chip does not assay
   CTS10228 (the Slavic "Din" marker), so Din vs Isles is unresolved from this file.
   One downstream twig (S17250) is excluded; that's as far as the data goes. Closing it
   needs a **Y-SNP panel or full Y sequencing** (e.g. FTDNA Big Y, YSEQ) — a new sample,
   not a re-analysis. Offer to help the user order one.

## Research provenance / caveats to remember

- A large multi-agent research fleet ran; the web-search budget (200 calls) was fully
  exhausted, so late threads fell back to direct fetches and some stalled. Everything
  substantive was captured. Frequency figures cross-checked against Varzari 2013 (only
  study to type M423 directly), Rootsi 2004, Peričić 2005, Battaglia 2008, Fóthi 2020,
  Olalde 2023, Gretzinger 2025, Tambets 2004.
- **Corrections already absorbed** (see MODERN.md, CARRIERS.md): the circulating
  "Serbian 3.63%" is a misread (real total ~36%); Basques have U5b broadly but ~0%
  U5b1b1 (different sub-branch from the Sami peak); the Sami–Berber link is a
  sister-branch on a handful of genomes, not a population phenomenon; no Y-DNA study
  breaks out Hutsuls/Boykos/Lemkos (the cited Carpathian study is mtDNA — don't conflate
  mt-hg-I with Y-hg-I).
- Costume/architecture drawings are **general ethnographic depictions**, some detail
  from an agent's training knowledge rather than a live citation — labelled as such, not
  cited as fact. No museum reference photos were captured (a possible future improvement).

## If continuing: sensible next steps

- Resolve the two user decisions above (Drive delete, repo privacy).
- If the user orders a Y-SNP/Big-Y test, re-run placement within M423 and update §2/§5.
- Optional polish: capture free museum reference photos to tighten the §5 drawings;
  pull the exact Belarus/Russia national I2a % from Kushniarevich 2015 Supp. Table K.
