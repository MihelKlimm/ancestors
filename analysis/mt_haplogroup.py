#!/usr/bin/env python3
"""Call the mitochondrial haplogroup from a 23andMe-style raw genotype file.

Usage:
    python3 analysis/mt_haplogroup.py <raw_genotype.txt>

The maternal call does not need a liftover: mitochondrial positions are quoted
against the rCRS (revised Cambridge Reference Sequence), which is a fixed
coordinate system independent of the nuclear genome build. That is why this
script is short and the Y-chromosome one is not -- see y_haplogroup.sh.

A position is "derived" when the observed base differs from the rCRS base,
meaning the mutation that defines a branch is present. Branch assignment is the
intersection of the derived markers present and the branches excluded by markers
that are still ancestral.
"""

import sys
from collections import OrderedDict

# rCRS reference base at each diagnostic position.
RCRS = {
    73: "A", 263: "A", 750: "A", 1438: "A", 2706: "A", 3010: "G", 3197: "T",
    4216: "T", 4580: "G", 4769: "A", 7028: "C", 8860: "A", 9055: "G", 9477: "G",
    10398: "A", 11467: "A", 11719: "G", 12308: "A", 12372: "G", 13368: "G",
    13617: "T", 13708: "G", 14182: "T", 14766: "C", 15326: "A", 15693: "T",
    15907: "A", 16126: "T", 16189: "T", 16270: "C",
}

# Derived at ALL of these -> the branch is supported.
SUPPORTS = OrderedDict([
    ("U",    [12308, 12372, 11467]),
    ("U5",   [3197, 9477, 13617]),
    ("U5b",  [14182]),
])

# Derived at any of these -> the branch is EXCLUDED (these define other clades).
EXCLUDES = OrderedDict([
    ("K / J / I", [10398]),
    ("U2",        [15907]),
    ("U4",        [15693]),
    ("JT",        [16126]),
])


def load_mt(path):
    """Return {position: base} for the mitochondrion."""
    mt = {}
    with open(path) as fh:
        for line in fh:
            if line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) >= 4 and parts[1] == "MT":
                mt[int(parts[2])] = parts[3]
    return mt


def state(mt, pos):
    """'derived', 'ancestral', or None when the chip does not assay the site."""
    call = mt.get(pos)
    if call is None or call in ("--", "I", "D"):
        return None
    return "ancestral" if call == RCRS.get(pos) else "derived"


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    mt = load_mt(sys.argv[1])
    if not mt:
        sys.exit("No MT rows found. Is this a 23andMe-style raw genotype file?")

    print(f"{len(mt)} mitochondrial sites called\n")
    print(f"{'pos':>7} {'rCRS':>5} {'call':>5}  state")
    for pos in sorted(RCRS):
        st = state(mt, pos)
        print(f"{pos:>7} {RCRS[pos]:>5} {mt.get(pos, '--'):>5}  "
              f"{st if st else 'not on chip'}")

    print()
    branch = None
    for name, positions in SUPPORTS.items():
        got = [p for p in positions if state(mt, p) == "derived"]
        if got:
            branch = name
            print(f"{name:<5} supported by {len(got)}/{len(positions)} markers: "
                  f"{', '.join(map(str, got))}")
        else:
            print(f"{name:<5} NOT supported")
            break

    for name, positions in EXCLUDES.items():
        if any(state(mt, p) == "derived" for p in positions):
            print(f"  ! {name} NOT excluded -- revisit the call")
        else:
            print(f"  {name} excluded")

    print(f"\nmtDNA haplogroup: {branch or 'undetermined'}")


if __name__ == "__main__":
    main()
