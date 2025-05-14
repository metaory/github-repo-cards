# repo-cards

Generate modern, GitHub-style PNG cards for your repositories. Minimal, fast, and themeable. Perfect for READMEs and dashboards.

> [!Caution]
> 🚧 minor documentation work remaining

---

## Features

- Light & dark mode cards, auto-generated
- Customizable via overrides (color, border, radius, etc.)
- Repo logo support (auto-detect or fallback)
- PNG output for easy embedding
- CLI & GitHub Action usage
- Dev mode for rapid template iteration

---

## Quick Start

### GitHub Action

Add to `.github/workflows/repo-cards.yml`:

```yaml
name: Generate Repository Cards
on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * 1'
permissions:
  contents: write
jobs:
  generate-cards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: metaory/repo-card-generator
        with:
          repositories: |
            repo-cards
            dotfiles
          overrides: |
            DARK_BG=#F6FFFA
            DARK_FG=#222333
            DARK_HL=#FF88EE
            RADIUS=10
            BORDER=7
          output: cards
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- **repositories:** List each repo (newline-separated)
- **overrides:** Style overrides (see below)
- **output:** Output directory (default: `cards`)

---

### CLI

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --overrides "DARK_BG=#F6FFFA DARK_FG=#222333 RADIUS=10 BORDER=7" \
  --output cards
```

- **--repos:** Space-separated repo names
- **--overrides:** Space-separated style overrides
- **--output:** Output directory (default: `cards`)
- **--dev:** Use mock data (no GitHub API)

---

## Embedding Cards

<picture>
  <source srcset="cards/repo-cards-dark.png" media="(prefers-color-scheme: dark)">
  <img src="cards/repo-cards-light.png" alt="repo-cards" width="480">
</picture>

---

## Customization

- **Universal:** `BG=#fff RADIUS=10`
- **Light only:** `LIGHT_BG=#f0f0f0`
- **Dark only:** `DARK_BG=#0d1117`
- Any SVG placeholder can be overridden.

---

## Repo Logos

Using [DiceBear](https://dicebear.com/) to generate unique logos for each repository.
<!--
Place a logo at `.github/assets/logo.png` or `.github/logo.png` in your repo for auto-inclusion.  
Fallback: first letter of repo name.
-->

---

## Requirements

- Bash, jq, gh, inkscape
- Fonts: BungeeShade, Baloo2 (see action for install steps)

---

## Dev Mode

Use `--dev` (CLI) or `dev-mode: true` (Action) for mock data and SVG output with editable fonts.

---

## License

[MIT](LICENCE) 
