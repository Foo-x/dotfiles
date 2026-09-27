#!/usr/bin/env python3
"""Compute the 0-100 code quality score from four normalized (0.0-1.0) sub-scores.

Usage:
    quality_score.py <coupling_normalized> <cohesion_normalized> <cc_normalized> <cognitive_normalized>

Formula (weights): 40% inverse coupling + 30% cohesion + 20% inverse CC + 10% inverse cognitive complexity.
"""
import sys


def quality_score(coupling: float, cohesion: float, cc: float, cognitive: float) -> float:
    return 40 * (1 - coupling) + 30 * cohesion + 20 * (1 - cc) + 10 * (1 - cognitive)


def evaluation(score: float) -> str:
    if score >= 80:
        return "優秀"
    if score >= 60:
        return "良好"
    if score >= 40:
        return "改善推奨"
    return "要改善"


def main() -> None:
    if len(sys.argv) != 5:
        print(__doc__)
        sys.exit(1)

    coupling, cohesion, cc, cognitive = (float(x) for x in sys.argv[1:5])
    score = quality_score(coupling, cohesion, cc, cognitive)
    print(f"{score:.1f} ({evaluation(score)})")


if __name__ == "__main__":
    main()
