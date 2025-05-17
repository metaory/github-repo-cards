# Repo Card Generator

Generate modern, GitHub-style PNG cards for your repositories. Minimal, fast, and themeable.

![Example Card](https://placehold.co/600x300/181825/cdd6f4?text=Example+Card)

**Why Repo Card Generator?**
No servers. No manual steps. No ugly cards. Just beautiful, automated, and fully customizable repo cards—committed directly to your repo, with zero third-party dependencies or network latency.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Use Cases](#use-cases)
- [Quick Start](#quick-start)
- [GitHub Actions Usage](#github-actions-usage)
  - [Configuration Options](#configuration-options)
- [Customization](#customization)
- [CLI Usage](#cli-usage)
- [Similar Tools](#similar-tools)
- [License](#license)

## Overview

This action generates beautiful, customizable PNG cards for your GitHub repositories that you can use in your profile, documentation, or anywhere else. The primary way to use this tool is through GitHub Actions.

> [!TIP]
> Showcase your repositories with beautiful, customizable cards for READMEs, wikis, blogs, and more—without relying on third-party servers.

The action handles the entire process: generating the cards, committing them, and pushing them to your repository in one seamless workflow.

## Features

- ⚡ **PNG output** at 300 DPI – paste straight into READMEs, wikis, blogs
- 🎨 **Theme-able** via dead-simple `KEY=value` overrides (light/dark aware)
- 🪄 **Zero dependencies** inside the cards – everything rendered to pixels
- 🏃 **One-shot** GitHub Action that commits the result back to the repository
- 🖥 **CLI parity** for local previews or fully-offline usage

> [!TIP]
> Every aspect—colors, fonts, logos, layout—can be customized with a single line.

<details>
<summary>Use Cases</summary>

- Add eye-catching repo cards to your GitHub profile README
- Showcase project stats in documentation or wikis
- Embed cards in personal blogs or websites
- Generate assets for social media or presentations
</details>

## Quick Start

> [!TIP]
> The fastest way to get started is by adding a GitHub workflow file to your repository.

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

> [!NOTE]
> All parameters can be provided as multi-line strings for better readability in your workflow files.

| Parameter     | Required | Description                                      |
|---------------|----------|--------------------------------------------------|
| `repositories`| Yes      | Newline-separated list of repository names       |
| `overrides`   | No       | Style overrides (colors, sizes, etc.)            |
| `fonts`       | No       | Custom font configurations                       |
| `logo`        | No       | Logo style and options                           |
| `output`      | No       | Output directory for generated cards (default: `cards`) |

<details>
<summary>Advanced GitHub Action Configuration</summary>

> [!IMPORTANT]
> Make sure to set `permissions: contents: write` in your workflow to allow committing generated cards.

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

<details>
<summary>Style Overrides</summary>

Simple color and layout adjustments:

```yaml
overrides: |
  BG=#ffffff  RADIUS=10  # Background & border radius
  FG=#000000  BORDER=2   # Text color & border width
```

> [!TIP]
> You can target specific color modes by prefixing variables with `LIGHT_` or `DARK_` for theme-specific styling.

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

<details>
<summary>Fonts</summary>

Custom TTF fonts for `head`, `body` and `stat` sections. Default fonts provided but easily overridden:

```yaml
fonts: |
  head=inter:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
  # Only specify sections you want to override - others will use defaults
```

> [!CAUTION]
> Only `.ttf` font format is supported. Using other formats may cause rendering issues.

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

<details>
<summary>Logo Options</summary>

> [!WARNING]
> The `style` parameter is required for logo generation. Without it, logos will not be created.

Set DiceBear avatar style (style parameter is required):

```yaml
logo: |
  style=glass  # Required parameter!
```

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

<details>
<summary>Customization Examples</summary>

```yaml
overrides: |
  DARK_BG=#22223b DARK_FG=#f8f8f2 RADIUS=16 BORDER=8
fonts: |
  head=fredoka:600@https://cdn.jsdelivr.net/fontsource/fonts/fredoka-one@latest/latin-400-normal.ttf
logo: |
  style=funEmoji radius=20 backgroundType=solid
```

- Try mixing and matching fonts, colors, and logo styles for unique cards.
- All options can be combined in your workflow or CLI usage.
</details>

## CLI Usage

> [!NOTE]
> GitHub Actions is the recommended way to use this tool. CLI usage is provided for local testing and advanced users.

Generate cards locally:

```sh
scripts/generate.sh --repos "repo-cards dotfiles"
```

<details>
<summary>Advanced CLI Example</summary>

> [!IMPORTANT]
> The CLI requires several system dependencies to be installed first.

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

## Similar Tools

**Repo Card Generator** is a modern, minimal, and fully customizable solution for generating and committing static PNG repo cards directly to your repository—no servers, no manual steps, no third-party dependencies, and no outdated visuals.

### Key Differences

- **No Server Dependency**: Most other tools (like [gh-card](https://github.com/nwtgck/gh-card)) require you to embed an image URL that points to their server. This:
  - Adds network latency and reliability issues
  - Creates a dependency on a third-party service
  - Raises privacy and security concerns
  - Can break if the service goes down or changes
- **Automated Workflow**: Our solution is a GitHub Action that runs on your repo, generates the cards, and commits them automatically. No manual steps, no external servers, no extra maintenance.
- **Extreme Customizability**: Style, fonts, logos, and layout are all configurable with simple overrides. Competing tools offer little or no customization.
- **Modern, Minimal, and Beautiful**: Many alternatives are visually outdated or cluttered. This project is designed for modern web-first aesthetics.
- **No Language Lock-in**: No need to install Python, Go, or Node.js libraries locally. Everything runs in the GitHub Actions environment or via a simple Bash CLI.

#### Notable Alternatives

- [gh-card](https://github.com/nwtgck/gh-card):
  - Web app, requires embedding a remote image URL
  - Minimal customization, limited to GitHub look
  - Server dependency, not workflow-integrated
- [GitHub-Repo-Cards-Generator](https://github.com/claitz/GitHub-Repo-Cards-Generator):
  - Manual, not maintained, limited customization
  - Outdated visuals
- [user-statistician](https://github.com/cicirello/user-statistician):
  - Python-based, does many things but not focused on repo cards
  - Visuals are cluttered and not modern
- [github-cards](https://github.com/lepture/github-cards):
  - JavaScript library, manual integration
  - No automation, limited style
- [github_link_creator](https://github.com/po3rin/github_link_creator):
  - Go CLI, manual, no customization, outdated visuals

| Tool                                    | Server Dependency | Approach              | Automation | Customization |
|----------------------------------------|-------------------|----------------------|------------|---------------|
| **Repo Card Generator (this)**          | None              | GitHub Action, Bash CLI | Full       | Full         |
| [gh-card]                              | Yes               | Web app/server       | Partial    | Minimal       |
| [GitHub-Repo-Cards-Generator]          | None              | Manual script        | None       | Minimal       |
| [user-statistician]                    | None              | Python Action        | Partial    | Minimal       |
| [github-cards]                         | None              | JS library           | None       | Minimal       |
| [github_link_creator]                  | None              | Go CLI               | None       | None          |

> [!TIP]
> If you want a card that is always available, fast, and fully under your control—with no reliance on third-party servers—**Repo Card Generator** is the clear choice.

## License

[MIT](LICENSE)
