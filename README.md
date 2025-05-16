# Repo Card Generator

Generate modern, GitHub-style PNG cards for your repositories. Minimal, fast, and themeable.

![Example Card](https://placehold.co/600x300/181825/cdd6f4?text=Example+Card)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [GitHub Actions Usage](#github-actions-usage)
  - [Configuration Options](#configuration-options)
- [Customization](#customization)
  - [Style Overrides](#style-overrides)
  - [Fonts](#fonts)
  - [Logo Options](#logo-options)
- [CLI Usage](#cli-usage)
- [License](#license)

## Overview

This action generates beautiful, customizable PNG cards for your GitHub repositories that you can use in your profile, documentation, or anywhere else. The primary way to use this tool is through GitHub Actions.

The action handles the entire process: generating the cards, committing them, and pushing them to your repository in one seamless workflow.

## Features

- ⚡ **PNG output** at 300 DPI – paste straight into READMEs, wikis, blogs
- 🎨 **Theme-able** via dead-simple `KEY=value` overrides (light/dark aware)
- 🪄 **Zero dependencies** inside the cards – everything rendered to pixels
- 🏃 **One-shot** GitHub Action that commits the result back to the repository
- 🖥 **CLI parity** for local previews or fully-offline usage

## Quick Start

1. Create a `.github/workflows/repo-cards.yml` file in your repository
2. Add the following content:

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
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

3. Run the workflow manually through the GitHub Actions tab
4. Find your generated cards in the `cards` directory (or custom output location)
5. The action automatically commits and pushes the generated cards to your repository

## GitHub Actions Usage

### Configuration Options

| Parameter     | Required | Description                                      |
|---------------|----------|--------------------------------------------------|
| `repositories`| Yes      | Newline-separated list of repository names       |
| `overrides`   | No       | Style overrides (colors, sizes, etc.)            |
| `fonts`       | No       | Custom font configurations                       |
| `logo`        | No       | Logo style and options                           |
| `output`      | No       | Output directory for generated cards (default: `cards`) |

<details>
<summary>Advanced GitHub Action Configuration</summary>

```yaml
name: Generate Repository Cards
on:
  workflow_dispatch:
  # Optional: Generate on schedule or on push
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sundays
  push:
    branches: [ main ]
    paths:
      - '.github/workflows/repo-cards.yml'

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
            my-awesome-project
          overrides: |
            DARK_BG=#181825
            DARK_FG=#cdd6f4
            RADIUS=14
            BORDER=6
          fonts: |
            head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
            body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
            stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
          logo: |
            style=adventurer
            radius=28
            backgroundColor=181825,313244
            baseColor=89b4fa,f38ba8
          output: assets/cards   # Cards will be generated, committed and pushed to this directory
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
</details>

## Customization

### Style Overrides

Basic overrides for colors and styling:

```yaml
overrides: |
  BG=#ffffff       # Universal background color
  FG=#000000       # Universal foreground color
  RADIUS=10        # Card border radius
  BORDER=2         # Border width
```

<details>
<summary>Advanced Style Overrides</summary>

You can set different styles for light and dark modes:

```yaml
overrides: |
  # Light mode overrides
  LIGHT_BG=#f0f0f0
  LIGHT_FG=#1a1a1a
  LIGHT_HL=#0969da
  LIGHT_AC=#2da44e
  
  # Dark mode overrides
  DARK_BG=#181825
  DARK_FG=#cdd6f4
  DARK_HL=#f38ba8
  DARK_AC=#89b4fa
  
  # Universal overrides
  RADIUS=14
  BORDER=6
```

Available override variables:
- `RADIUS` - Border radius of the card
- `BORDER` - Border width of the card
- `BG` - Background color
- `FG` - Foreground/text color
- `HL` - Highlight color (titles, links)
- `AC` - Accent color (secondary elements)

Prefix any of these with `LIGHT_` or `DARK_` to apply specifically to light or dark mode.
</details>

### Fonts

Basic font configuration:

```yaml
fonts: |
  head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
```

<details>
<summary>Advanced Font Configuration</summary>

You can customize fonts for different sections of the card:

```yaml
fonts: |
  head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
  body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
```

Format for each font entry:
- `section=alias:weight@url-to-ttf`

Available sections:
- `head` - Repository name and headers
- `body` - Description and general text
- `stat` - Statistics and metadata

Font resources:
- [Google Fonts](https://fonts.google.com/)
- [Fontsource](https://fontsource.org/)
- [Font Library](https://fontlibrary.org/)
</details>

### Logo Options

Basic logo configuration:

```yaml
logo: |
  style=bottts
```

<details>
<summary>Advanced Logo Configuration</summary>

```yaml
logo: |
  style=adventurer
  radius=28
  backgroundColor=181825,313244
  baseColor=89b4fa,f38ba8
```

The logo is generated using DiceBear, and you can customize various aspects:

- `style` - The avatar style to use (see below)
- `radius` - Border radius of the avatar
- `backgroundColor` - Background color(s)
- `baseColor` - Primary color(s)

The `seed` is set automatically based on the repository name.

**Available styles:**
adventurer, avataaars, bottts, funEmoji, openPeeps, personas, pixelArt, shapes, and many more.

[Browse all DiceBear styles](https://www.dicebear.com/styles/)

<details>
<summary>Complete DiceBear Options</summary>

style, radius, backgroundType, backgroundColor, baseColor, colorful, lineColor, flip, rotate, scale, size, backgroundRotation, translateX, translateY, clip, randomizeIds, accessories, accessoriesColor, accessoriesProbability, base, clothesColor, clothing, clothingGraphic, eyebrows, eyes, facialHair, facialHairColor, facialHairProbability, hairColor, hatColor, mouth, nose, skinColor, top, topProbability

</details>
</details>

## CLI Usage

The CLI tool provides a way to generate repository cards locally for testing or custom workflows. It uses the same core engine as the GitHub Action but requires some dependencies to be installed on your system.

Basic usage:
```sh
scripts/generate.sh --repos "repo-cards dotfiles"
```

<details>
<summary>Detailed CLI Usage (Advanced)</summary>

### Requirements

For CLI usage, you'll need:
- Bash
- jq
- gh (GitHub CLI)
- inkscape

### Basic CLI Usage

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles"
```

### Advanced CLI Usage

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --overrides "DARK_BG=#181825 DARK_FG=#cdd6f4 RADIUS=14 BORDER=6" \
  --output assets/cards \
  --logo "style=adventurer radius=28 backgroundColor=181825,313244 baseColor=89b4fa,f38ba8" \
  --fonts 'head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf'
```

All the customization options available for the GitHub Action are also available via CLI parameters.
</details>

## License

[MIT](LICENSE)
