#!/usr/bin/env bash
# Call the Y-chromosome haplogroup from a 23andMe-style raw genotype file.
#
#   ./analysis/y_haplogroup.sh <raw_genotype.txt> [out_dir]
#
# THE BUILD TRAP, which is the whole reason this script exists:
#
# yhaplo expects GRCh37 coordinates. This genotype file reports Y positions on
# GRCh38. The two builds differ by roughly 2.11 Mb on chrY -- but NOT by a
# constant. Measured offsets at two markers:
#
#     rs2032597 (M170)   GRCh37 14,847,792   file 12,735,858   diff 2,111,934
#     rs17222573         GRCh37 17,891,241   file 15,779,361   diff 2,111,880
#
# A flat shift would therefore be wrong by tens of bases across parts of the
# chromosome, which is more than enough to land on the wrong marker and call the
# wrong branch. So every coordinate goes through the UCSC hg38->hg19 chain file.
#
# The liftover is checked against a known address before the call is trusted:
# M170 must land on exactly 14,847,792.
set -euo pipefail

RAW="${1:?usage: y_haplogroup.sh <raw_genotype.txt> [out_dir]}"
OUT="${2:-results}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Setting up yhaplo + pyliftover"
python3 -m venv "$WORK/venv"
"$WORK/venv/bin/pip" install --quiet "git+https://github.com/23andMe/yhaplo.git" pyliftover

echo "==> Fetching UCSC hg38->hg19 chain"
curl -sSL --max-time 120 -o "$WORK/chain.gz" \
  "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz"

echo "==> Lifting Y coordinates GRCh38 -> GRCh37"
RAW="$RAW" WORK="$WORK" "$WORK/venv/bin/python" - <<'PY'
import os
from pyliftover import LiftOver

work = os.environ["WORK"]
lo = LiftOver(os.path.join(work, "chain.gz"))

rows, unmapped, ambiguous, skipped = [], 0, 0, 0
with open(os.environ["RAW"]) as fh:
    for line in fh:
        if line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 4 or parts[1] != "Y":
            continue
        pos38, genotype = int(parts[2]), parts[3]
        if len(genotype) != 1 or genotype not in "ACGT":
            skipped += 1           # heterozygous, indel, or no-call
            continue
        hit = lo.convert_coordinate("chrY", pos38 - 1)   # liftover is 0-based
        if not hit:
            unmapped += 1
            continue
        if len(hit) > 1:
            ambiguous += 1
            continue
        chrom, newpos, _, _ = hit[0]
        if chrom != "chrY":
            unmapped += 1
            continue
        rows.append((newpos + 1, genotype))

rows.sort()
print(f"    lifted {len(rows)}  unmapped {unmapped}  "
      f"ambiguous {ambiguous}  het/indel/no-call {skipped}")

# Refuse to proceed on a liftover that cannot reproduce a known address.
check = lo.convert_coordinate("chrY", 12735858 - 1)
got = check[0][1] + 1 if check else None
assert got == 14847792, f"liftover check FAILED: M170 -> {got}, expected 14847792"
print("    liftover check OK: M170 -> 14,847,792")

with open(os.path.join(work, "sample.genos.txt"), "w") as out:
    out.write("ID\t" + "\t".join(str(p) for p, _ in rows) + "\n")
    out.write("sample\t" + "\t".join(g for _, g in rows) + "\n")
PY

echo "==> Calling haplogroup (full ISOGG tree)"
mkdir -p "$OUT"
"$WORK/venv/bin/yhaplo" --input "$WORK/sample.genos.txt" --out_dir "$OUT" --all_aux_output >/dev/null

echo
echo "==> CALL"
cat "$OUT/haplogroups.sample.txt"
echo
echo "Ancestral/derived counts along the path: $OUT/counts.anc_der.sample.txt"
