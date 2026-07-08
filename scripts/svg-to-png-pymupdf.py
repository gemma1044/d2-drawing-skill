from __future__ import annotations

import argparse
from pathlib import Path

import fitz


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert an SVG file to PNG and @2x.png using PyMuPDF.",
    )
    parser.add_argument("svg", help="Input SVG file")
    parser.add_argument(
        "--output",
        "-o",
        help="Output PNG path. Defaults to input path with .png extension.",
    )
    parser.add_argument(
        "--no-2x",
        action="store_true",
        help="Do not create the @2x PNG.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    src = Path(args.svg)
    if not src.exists():
        raise FileNotFoundError(f"Input SVG does not exist: {src}")

    out = Path(args.output) if args.output else src.with_suffix(".png")
    out.parent.mkdir(parents=True, exist_ok=True)

    doc = fitz.open(str(src))
    page = doc[0]
    page.get_pixmap(alpha=False).save(str(out))
    print(out)

    if not args.no_2x:
        out2x = out.with_name(f"{out.stem}@2x{out.suffix}")
        page.get_pixmap(matrix=fitz.Matrix(2, 2), alpha=False).save(str(out2x))
        print(out2x)


if __name__ == "__main__":
    main()
