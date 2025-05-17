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
  # Run weekly to keep cards updated automatically
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Mondays
  # Also allow manual execution when needed
  workflow_dispatch:

permissions:
  contents: write  # Needed for pushing changes

jobs:
  generate-cards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: metaory/repo-card-generator@v1
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

permissions:
  contents: write  # Needed for pushing changes

jobs:
  generate-cards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: metaory/repo-card-generator@v1
        with:
          repositories: |
            repo-cards
            dotfiles
            my-awesome-project
          overrides: |
            DARK_BG=#181825  DARK_FG=#cdd6f4  # Dark mode colors
            RADIUS=14  BORDER=6               # Card shape properties
          fonts: |
            head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
            body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
            stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
          logo: |
            style=glass
            radius=28
            backgroundType=gradientLinear
          output: assets/cards   # Cards will be generated, committed and pushed to this directory
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
</details>

## Customization

### Style Overrides

Simple color and layout adjustments:

```yaml
overrides: |
  BG=#ffffff  RADIUS=10  # Background & border radius
  FG=#000000  BORDER=2   # Text color & border width
```

<details>
<summary>Detailed Style Options</summary>

Theme-specific overrides with `LIGHT_` or `DARK_` prefixes:

```yaml
overrides: |
  # Light mode
  LIGHT_BG=#f0f0f0  LIGHT_HL=#0969da
  LIGHT_FG=#1a1a1a  LIGHT_AC=#2da44e
  
  # Dark mode
  DARK_BG=#181825   DARK_HL=#f38ba8
  DARK_FG=#cdd6f4   DARK_AC=#89b4fa
  
  # Universal
  RADIUS=14  BORDER=6
```

**Variables:**
- `BG`: Background color
- `FG`: Text color
- `HL`: Highlight color (titles)
- `AC`: Accent color (icons)
- `RADIUS`: Card rounded corners
- `BORDER`: Border thickness
</details>

### Fonts

Custom TTF fonts for `head`, `body` and `stat` sections. Default fonts provided but easily overridden:

```yaml
fonts: |
  head=inter:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
  # Only specify sections you want to override - others will use defaults
```

<details>
<summary>Font Configuration Details</summary>

Format: `section=alias:weight@url`

```yaml
# Default fonts
fonts: |
  head=bungee:700@https://cdn.jsdelivr.net/fontsource/fonts/bungee-shade@latest/latin-400-normal.ttf
  body=baloo-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-700-normal.ttf
  stat=baloo-norm:400@https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-400-normal.ttf
```

**Key Points:**
- All sections (`head`, `body`, `stat`) support custom fonts
- Alias is just a reference name
- Weight doesn't need to match the actual font
- The tool automatically detects the actual font family name from the TTF file
- If detection fails, it falls back to the provided alias
- Only `.ttf` format is supported (other formats may cause issues)
- If you only customize some sections (e.g., just `head`), others will use the default fonts

**How to Find Fonts:**
1. **Fontsource** (Recommended): Browse [Fontsource](https://fontsource.org/fonts) for fonts
   - Find your desired font and click on it
   - Look for the "CDN Links" section and copy the URL ending with `.ttf`
   - Example URL format: `https://cdn.jsdelivr.net/fontsource/fonts/font-name@latest/latin-400-normal.ttf`
   - Change `400` to your desired weight (if available)

2. **Google Fonts**: Use [Google Fonts](https://fonts.google.com/)
   - Select a font you like
   - Google Fonts can be accessed via Fontsource using the same pattern as above

3. **Direct TTF Files**: You can use any direct URL to a `.ttf` file

**Example: Mix Different Fonts**
```yaml
fonts: |
  head=comic:700@https://cdn.jsdelivr.net/fontsource/fonts/comic-neue@latest/latin-700-normal.ttf
  body=inter:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  stat=inter:600@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-600-normal.ttf
```

**Sources:** [Google Fonts](https://fonts.google.com/) | [Fontsource](https://fontsource.org/) | [Font Library](https://fontlibrary.org/)
</details>

### Logo Options

Set DiceBear avatar style (style parameter is required):

```yaml
logo: |
  style=glass  # Required parameter!
```

<details>
<summary>Logo Customization</summary>

More options for the DiceBear-generated avatar:

```yaml
logo: |
  style=glass           # Required parameter
  radius=28             # Rounded corners
  backgroundType=gradientLinear
```

**Key Parameters:**
- `style`: Avatar style (mandatory)
- `radius`: Corner roundness (0-50)
- `backgroundColor`: Custom background color in hex
- `backgroundType`: Background type (solid or gradientLinear)

**Popular Styles:** adventurer, avataaars, bottts, funEmoji, personas, pixelArt, shapes

[Browse all styles](https://www.dicebear.com/styles/)

<details>
<summary>All DiceBear Core Options</summary>

- `style`: Avatar style name (required)
- `seed`: String to generate consistent avatars
- `flip`: Boolean to flip horizontally
- `rotate`: Degree of rotation (0-360)
- `scale`: Scale percentage (0-200)
- `radius`: Corner roundness (0-50)
- `size`: Output size in pixels
- `backgroundColor`: Hex color code(s) for background
- `backgroundType`: Background pattern type
- `backgroundRotation`: Degree range for gradient rotation
- `translateX`: Horizontal offset (-100 to 100)
- `translateY`: Vertical offset (-100 to 100)
- `clip`: Boolean to clip to shape boundary
- `randomizeIds`: Boolean to randomize SVG IDs

Additional options vary by avatar style. See the specific style's documentation for all available options.
</details>
</details>

## CLI Usage

*Note: GitHub Actions is the recommended way to use this tool. CLI usage is provided for local testing and advanced users.*

Generate cards locally:

```sh
scripts/generate.sh --repos "repo-cards dotfiles"
```

<details>
<summary>Advanced CLI Example</summary>

**Requirements:**
- bash
- jq
- gh (GitHub CLI)
- inkscape
- curl
- dicebear

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --overrides "DARK_BG=#181825 RADIUS=14" \
  --output assets/cards \
  --logo "style=glass radius=28" \
  --fonts 'head=inter:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf'
```

All GitHub Action options are available as CLI parameters with identical format.
</details>

## License

[MIT](LICENSE)
