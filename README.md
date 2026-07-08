# D2 Drawing Skill

A shareable Cursor skill for creating and rendering D2 diagrams with a local D2 CLI.

The skill is optimized for:

- architecture diagrams
- system relationship diagrams
- flowcharts
- module dependency diagrams
- SVG rendering
- PNG / `@2x.png` outputs for Markdown, Cursor preview, Feishu/Lark, WeChat, Slack, and other copy/paste surfaces

## Files

```text
.
├── SKILL.md
├── scripts/
│   ├── render-d2.ps1
│   └── svg-to-png-pymupdf.py
└── examples/
    └── simple-architecture.d2
```

## Install As A Cursor Skill

Clone this repository into your Cursor skills folder:

```powershell
git clone https://github.com/gemma1044/d2-drawing-skill.git "$env:USERPROFILE\.cursor\skills\d2-diagram"
```

Or copy `SKILL.md` and `scripts/` into an existing skill folder.

## Requirements

Install D2 locally first.

Recommended on Windows:

1. Open [D2 releases](https://github.com/terrastruct/d2/releases).
2. Download the latest `d2-*-windows-amd64.msi`.
3. Run the installer. The official installer adds `d2` to PATH.
4. Open a new PowerShell window and verify:

```powershell
d2 --version
```

Alternative executable resolution:

- Put `d2.exe` at `D:\tools\d2\d2.exe`, or
- Add `d2` to `PATH`, or
- Set `D2_BIN` to the full executable path.

Check:

```powershell
if ($env:D2_BIN) { & $env:D2_BIN --version }
elseif (Test-Path "D:\tools\d2\d2.exe") { & "D:\tools\d2\d2.exe" --version }
else { d2 --version }
```

For SVG -> PNG conversion, install PyMuPDF:

```powershell
python -m pip install pymupdf
```

Check:

```powershell
python -c "import fitz; print('pymupdf available')"
```

## Render SVG

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\render-d2.ps1 `
  -Source .\examples\simple-architecture.d2 `
  -Output .\examples\simple-architecture.svg `
  -Layout elk
```

## Render PNG

D2 may need Playwright to render PNG directly. A more reliable workflow on Windows is:

1. Render D2 to SVG.
2. Convert SVG to PNG with PyMuPDF.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\render-d2.ps1 `
  -Source .\examples\simple-architecture.d2 `
  -Output .\examples\simple-architecture.svg `
  -Layout elk

python .\scripts\svg-to-png-pymupdf.py .\examples\simple-architecture.svg
```

This creates:

- `simple-architecture.png`
- `simple-architecture@2x.png`

Use `@2x.png` for copying into docs and chat apps.

## Skill Notes

- Keep `.d2` as source.
- Prefer PNG for user-facing documentation and copy/paste.
- Keep SVG as vector/intermediate output.
- Use `direction: down` for large architecture diagrams.
- Try `--layout elk` for complex nested diagrams.
- If a diagram is unreadable, reduce sibling nodes, shorten labels, or split it into multiple diagrams.

## License

MIT
