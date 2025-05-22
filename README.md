<div align="center">
    <h3>GitHub Repo Cards</h3>
    <img src=".github/assets/logo.svg" alt="logo" height="128" />
    <p>
        <b>Generate beautiful, static PNG cards for your GitHub repositories</b><br>
        <i>Modern, minimal, and fully offline</i>
    </p>
    <img src="sample-cards/card_glitcher-app_dark.png" alt="card_glitcher-app-dark" width="40%" />
    <img src="sample-cards/card_glitcher-app_light.png" alt="card_glitcher-app-light" width="40%" />
</div>

---

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#avatar-customization">Avatar</a> •
  <a href="#license">License</a>
</p>

---

## Overview

**repo-cards** is a GitHub Action and CLI that generates sleek, static PNG cards for your repositories. Each card is rendered from a theme SVG, with all design and font choices locked in the theme. For every repository, two cards are generated: one light, one dark.

> [!IMPORTANT]
> All design, layout, and font choices are locked in the selected SVG theme. Users only need to pick a theme—no further configuration is required.

- No runtime, no embeds, no servers
- No configuration—just pick a theme
- Output: two PNGs per repo (light & dark)

---

## Quick Start

> [!NOTE]
> You must provide a GitHub token with repository read access via the `GITHUB_TOKEN` environment variable.

### Minimal Usage

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
      - uses: metaory/github-repo-cards@v1
        with:
          repositories: |
            repo-cards
            dotfiles
          theme: default   # Pick a theme SVG (default: default)
          output: cards    # Output directory (default: cards)
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

> [!TIP]
> For each listed repository, two PNG cards are generated: one for light mode and one for dark mode.

<details>
<summary>Advanced Usage</summary>

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
      - uses: metaory/github-repo-cards@v1
        with:
          repositories: |
            repo-cards
            dotfiles
            my-awesome-project
          theme: minimal      # Use a different theme SVG
          output: assets/cards
          avatar: |
            style=glass
            radius=28
            backgroundType=gradientLinear
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

</details>

---

## Avatar Customization

> [!IMPORTANT]
> The `style` key is required for avatar customization. See the [DiceBear styles documentation](https://www.dicebear.com/styles/) for available options.

You can customize the avatar using [DiceBear](https://www.dicebear.com/styles/) options. Provide newline-separated key-value pairs via the `avatar` input. The `style` key is required.

Example:

```yaml
avatar: |
  style=glass
  radius=28
  backgroundType=gradientLinear
```

---

## License

MIT