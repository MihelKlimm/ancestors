# ancestors

Deep-ancestry analysis of a single genotype, and a map built from the result.

**Live page: https://ancestry-map-d88.pages.dev**

| Line | Haplogroup | Confidence |
|---|---|---|
| Maternal (mtDNA) | **U5b** | 7 derived markers, 4 independent exclusions |
| Paternal (Y-DNA) | **I2a1b (I-M423)** | 4 derived markers; I2a2/M223 excluded by 6 ancestral |

Both are **Western Hunter-Gatherer** lineages — the people in Europe before
farming arrived. Both branches are shared with **Cheddar Man** (c. 7100 BC),
whose remains carried mtDNA U5b1 and Y-DNA I2a.

---

## What this analysis can and cannot say

**It can** identify the two lineages that run up the direct maternal and direct
paternal lines, and place them geographically using published population
genetics.

**It cannot:**

- **Produce admixture percentages.** "38% Baltic, 12% Finnish" requires
  comparison against reference population panels. A raw genotype file alone does
  not support it, so no such number appears anywhere in this repo.
- **Name your ancestors.** A haplogroup is a branch, not a person. Someone who
  shares your haplogroup is a *relative on that branch* — you share a common
  ancestor, often thousands of years back. They are not your ancestor, and any
  page claiming otherwise from haplogroup data alone is inventing it.
- **Speak for most of your family tree.** These two lines are a vanishingly thin
  slice: your mother's mother's mother, and your father's father's father. Go
  back 10 generations and you have ~1,024 ancestors; haplogroups describe 2 of
  those paths.

Where the page includes imaginative or novelistic material, it is **explicitly
marked as reconstruction** and kept visually separate from the evidence.

---

## Reproducing the calls

The raw genotype file is **not** in this repo (see `.gitignore`). Pass its path:

```bash
# Maternal — no liftover needed; mtDNA uses rCRS coordinates
python3 analysis/mt_haplogroup.py ~/private/genome.txt

# Paternal — installs yhaplo, lifts GRCh38 -> GRCh37, walks the ISOGG tree
./analysis/y_haplogroup.sh ~/private/genome.txt results/
```

### The build trap

This is the part that is easy to get wrong and quietly produce a confident,
incorrect answer.

`yhaplo` expects **GRCh37**. This genotype file reports Y positions on
**GRCh38**. The builds differ by about 2.11 Mb on chrY — but *not* by a
constant:

| Marker | GRCh37 | file (GRCh38) | difference |
|---|---|---|---|
| rs2032597 (M170) | 14,847,792 | 12,735,858 | 2,111,934 |
| rs17222573 | 17,891,241 | 15,779,361 | 2,111,880 |

Subtracting a flat offset would be wrong by tens of bases in places — ample to
land on a neighbouring marker and call the wrong branch. Every coordinate is
therefore lifted through the UCSC hg38→hg19 chain, and the script **refuses to
run** unless the liftover reproduces a known address (M170 → 14,847,792). In the
recorded run, 0 of 3,741 markers failed to map.

### Y result summary

| Node | Ancestral | Derived | Verdict |
|---|---|---|---|
| I (M170) | 0 | 80 | confirmed |
| I1 | 16 | 0 | excluded |
| I2 | 0 | 2 | confirmed |
| I2a | 0 | 1 | confirmed |
| **I2a1b** | 0 | **4** | **terminal call** |
| I2a2 *(contains M223)* | 6 | 0 | excluded |
| I2a1a (M26, Sardinian) | 1 | 0 | excluded |

Terminal markers: CTS176, CTS1293, CTS5375, CTS5985.

**Open question this file cannot close:** `CTS10228` — the marker of the Slavic
"Din" expansion — is not assayed on this chip at all, zero calls either way. So
I-M423 is settled; whether it sits in the large Slavic sub-branch or the small
British "Isles" sub-branch is not. That needs a Y-SNP panel or full Y sequencing.

---

## Layout

```
analysis/   the two callers (mtDNA in Python, Y as a shell pipeline)
results/    yhaplo output: the call, path, and ancestral/derived counts
site/       the published page (self-contained; deploys to Cloudflare Pages)
docs/       sources, evidence grading, and image licences
```

## Deploying the site

```bash
npx wrangler@4 pages deploy site --project-name=ancestry-map --branch=main
```

## Sources

Marker identities verified against dbSNP and SNPedia. Haplogroup tree from
ISOGG via yhaplo. Ancient-genome haplogroups from the published literature —
Cheddar Man (Natural History Museum, 2018), La Braña-Arintero, Loschbour,
Djehutynakht. Per-claim sources and evidence grades in `docs/`.
