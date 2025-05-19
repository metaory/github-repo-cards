<div align="center">
    <h3>GitHub Repo Cards</h3>
    <img src=".github/assets/logo.svg" alt="logo" height="128" />
    <p>
        GitHub Action
        <br>
         generating sleek · static
        <br>
        repository cards
        <br>
        rasterized · versioned · customizable
    </p>
    <img src="sample-cards/card_glitcher-app_dark.png" alt="card_glitcher-app-dark" width="40%" />
    <img src="sample-cards/card_glitcher-app_light.png" alt="card_glitcher-app-light" width="40%" />
    <img src="sample-cards/card_gradient-gl_dark.png" alt="card_gradient-gl_dark" width="40%" />
    <img src="sample-cards/card_gradient-gl_light.png" alt="card_gradient-gl_light.png" width="40%" />
</div>


github-repo-cards is a GitHub Action that renders customizable static cards for your repositories.
Cards are generated fully offline, styled with simple overrides, and committed directly to your repository, no servers, no embeds, no runtime dependencies.

Built for clean READMEs, wikis, blogs, or social previews.
Run it on a schedule or trigger it manually in your GitHub workflow—zero maintenance required.


No runtime. No APIs. No server. No embeds. Cards are generated and committed directly into your repository.

---

> [!CAUTION]
> DO NOT USE
> 🚧 NOT PRODUCTION READY

---

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
      - uses: metaory/github-repo-cards@v1
        with:
          repositories: |
            repo-cards
            dotfiles
          template: default  # Optional, picks SVG layout preset
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

| Parameter       | Required | Description                                             |
|-----------------|----------|---------------------------------------------------------|
| `repositories`  | Yes      | Newline-separated list of repository names              |
| `overrides`     | No       | Style overrides (colors, sizes, etc.)                   |
| `template`      | No       | SVG template/layout preset (default: `default`)         |
| `output`        | No       | Output directory for generated cards (default: `cards`) |
| `fonts`         | No       | Custom font configurations                              |
| `logo`          | No       | Logo style and options                                  |

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

      - uses: metaory/github-repo-cards@v1
        with:
          repositories: |
            repo-cards
            dotfiles
            my-awesome-project
          overrides: |
            DARK_BG=#181825 DARK_FG=#cdd6f4  # Dark mode colors
            RADIUS=14       BORDER=6         # Card shape properties
          fonts: |
            head=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
            body=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
            lang=https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
            stat=https://cdn.jsdelivr.net/fontsource/fonts/monofett@latest/latin-400-normal.ttf
          logo: |
            style=glass
            radius=28
            backgroundType=gradientLinear
          output: assets/cards   # Cards will be generated, committed and pushed to this directory
          template: default  # Optional, picks SVG layout preset
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
  LIGHT_BG=#FFEEDD  LIGHT_HL=#4477DD
  LIGHT_FG=#221133  LIGHT_AC=#22AA44

  # Dark mode
  DARK_BG=#112233   DARK_HL=#FF88AA
  DARK_FG=#CCDDFF   DARK_AC=#44BBFF

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

Custom TTF fonts for `head`, `body`, `lang`, and `stat` sections. Default fonts provided but easily overridden:

```yaml
fonts: |
  head=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  body=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  lang=https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
  stat=https://cdn.jsdelivr.net/fontsource/fonts/monofett@latest/latin-400-normal.ttf
```

> [!CAUTION]
> Only `.ttf` font format is supported. Using other formats may cause rendering issues.

Format: `section=url-to-ttf`

**Key Points:**
- All sections (`head`, `body`, `lang`, `stat`) support custom fonts
- Font size and weight are locked for layout stability
- Only font family (as a TTF URL) is customizable
- `lang` is used for the language label
- `stat` is used for numeric stats (stars, forks)

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
  head=https://cdn.jsdelivr.net/fontsource/fonts/comic-neue@latest/latin-700-normal.ttf
  body=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  lang=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-600-normal.ttf
  stat=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
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
  DARK_BG=#221133 DARK_FG=#FFDDEE RADIUS=16 BORDER=8
fonts: |
  head=https://cdn.jsdelivr.net/fontsource/fonts/fredoka-one@latest/latin-400-normal.ttf
  body=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  lang=https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
  stat=https://cdn.jsdelivr.net/fontsource/fonts/monofett@latest/latin-400-normal.ttf
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
scripts/generate.sh --repos "repo-cards dotfiles" --template default
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
  --overrides "DARK_BG=#221133 RADIUS=14" \
  --output assets/cards \
  --logo "style=glass radius=28" \
  --fonts 'head=https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf' \
  --template default
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

| Tool                                 | Server Dependency | Approach             | Automation | Customization |
|--------------------------------------|-------------------|----------------------|------------|---------------|
| **Repo Card Generator (this)**           | None              | GitHub Action, CLI   | Full       | Full          |
| [gh-card]                              | Yes               | Web app/server       | Partial    | Minimal       |
| [GitHub-Repo-Cards-Generator]          | None              | Manual script        | None       | Minimal       |
| [user-statistician]                    | None              | Python Action        | Partial    | Minimal       |
| [github-cards]                         | None              | JS library           | None       | Minimal       |
| [github_link_creator]                  | None              | Go CLI               | None       | None          |

---

## License

[MIT](LICENSE)

## Templates

You can select a card layout preset using the `template` option. The default is `default`, which uses `templates/default.svg`.

```yaml
template: default
```

More templates (e.g., `compact`, `modern`, etc.) can be added in the future. To use a custom template, add your SVG to the `templates/` directory and set `template` to its name (without `.svg`).
