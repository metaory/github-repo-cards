# repo-cards

Generate modern, GitHub-style PNG cards for your repositories. Minimal, fast, and themeable. Perfect for READMEs and dashboards.

> [!CAUTION]
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

#### Basic

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
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Custom

```yaml
name: Generate Repository Cards
on:
  workflow_dispatch:
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
            RADIUS=12
            BORDER=8
          fonts: |
            header=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
            body=inter-regular:300@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-300-normal.ttf
            stats=nabla:200@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
          logo: bottts/svg?backgroundColor=b6e3f4,c0aede,d1d4f9&radius=22&baseColor=00acc1,1e88e5,5e35b1
          output: assets/cards
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- **repositories:** List each repo (newline-separated)
- **overrides:** Style overrides (see below)
- **logo:** Logo overrides (see below)
- **fonts:** Font overrides (see below)
- **output:** Output directory (default: `cards`)

---

### CLI

#### Basic Example

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --output cards
```

#### Advanced Example

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --overrides "DARK_BG=#F6FFFA DARK_FG=#222333 RADIUS=12 BORDER=8" \
  --output assets \
  --logo "rings/svg?backgroundColor=ffe066,ff6f91&radius=24&colorful=true&lineColor=22223b" \
  --fonts 'header=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf body=inter-regular:300@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-300-normal.ttf stats=nabla:200@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf'
```

- **--repos:** Space-separated repo names
- **--fonts:** Space-separated font overrides
- **--output:** Output directory (default: `cards`)
- **--overrides:** Space-separated style overrides
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

### Fonts (Optional)

You can set custom fonts for the card's `head`, `body`, and `stat` sections.
**How to use:**
- Add a `fonts:` block to your workflow or config.
- Each line sets a font for a section, using:
  ```sh
  section=alias:weight@url-to-ttf
  ```
  - `section`: `head`, `body`, or `stat`
  - `alias`: any short name (for file naming only)
  - `weight`: font weight (e.g. 400, 600)
  - `url-to-ttf`: direct link to a `.ttf` file
**Example:**
```yaml
fonts: |
  head=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
  body=krypton:600@https://cdn.jsdelivr.net/fontsource/fonts/monaspace-krypton@latest/latin-600-normal.ttf
  stat=fredoka:400@https://cdn.jsdelivr.net/fontsource/fonts/fredoka-one@latest/latin-400-normal.ttf
```
**Details:**
- You can set any or all sections. Omitted sections use the default font.
- The `alias` is just for file naming; the actual font family is detected from the TTF.
- Only direct `.ttf` links are supported.
- If a font URL is invalid or unreachable, that section will fail.
**Where to find TTF fonts:**
- [Google Fonts](https://fonts.google.com/) (Download TTF from "Download family")
- [Fontsource](https://fontsource.org/) ([example: Inter CDN](https://fontsource.org/fonts/inter/cdn))
  Go to the **CDN** section, select **Static**, check **TTF**, and copy the jsDelivr link.
- [Font Library](https://fontlibrary.org/)
- [Adobe Fonts](https://fonts.adobe.com/) (some TTFs available)
You can use any public, direct `.ttf` URL.


> [!TIP]
> You can use different weights of the same font for different sections
> by specifying separate TTF files and aliases.
>
> For example, you might use a lighter weight for the body and a bold weight for the header:
>
> ```yaml
> fonts: |
>   head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
>   body=inter-regular:300@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-300-normal.ttf
>   stat=nabla:200@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
> ```
>
> You can name the aliases to be unique however you like (e.g. `inter-bold`, `inter-regular`, `inter-800`, `inter-300`).
>
> Just make sure each line points to the correct TTF file and weight for the section.

---

### logos (DiceBear)

You can fully customize the logo style for your repo cards 
using any [DiceBear](https://www.dicebear.com/styles/) URL as input 
(excluding the `seed` parameter, which is set automatically for each repo).

**How to use:**
- Add the `logo` input to your workflow or config.
- Provide any DiceBear style URL (query string options allowed).
- The script will append the correct `seed` for each repository.

**Default:**
```yaml
glass/svg?backgroundType=gradientLinear&radius=20
```

**Examples:**

- **Change only the style:**
  ```yaml
  logo: initials/svg
  ```
  This uses the "initials" style with all default options.

- **Custom background and radius:**
  ```yaml
  logo: bottts/svg?backgroundColor=fafafa,eeeeee&radius=30
  ```
  This uses the "Bottts" style with a custom background and larger radius.

- **Multiple custom options:**
  ```yaml
  logo: rings/svg?backgroundColor=ffe066,ff6f91&radius=24&colorful=true&lineColor=22223b
  ```
  This uses the "Rings" style, sets two background colors, a custom radius, enables colorful mode, and sets a custom line color.

See all available styles and options at [DiceBear Styles](https://www.dicebear.com/styles/).

---

## Requirements

- Bash, jq, gh, inkscape

---

## Dev Mode

Use `--dev` (CLI) or `dev-mode: true` (Action) for mock data and SVG output with editable fonts.

---

## License

[MIT](LICENCE)
