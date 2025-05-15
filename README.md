# repo-cards

Generate modern, GitHub-style PNG cards for your repositories. Minimal, fast, and themeable.

---

## Quick Start

**Basic GitHub Action:**
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
<details><summary>Customized GitHub Action</summary>

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
          output: assets/cards
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
</details>

- **repositories:** Newline-separated repo names
- **overrides:** Style overrides (see below)
- **logo:** Logo options (see below)
- **fonts:** Font options (see below)
- **output:** Output directory (default: `cards`)

---

**Basic CLI:**
```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles"
```
<details><summary>Customized CLI</summary>

```sh
scripts/generate.sh \
  --repos "repo-cards dotfiles" \
  --overrides "DARK_BG=#181825 DARK_FG=#cdd6f4 RADIUS=14 BORDER=6" \
  --output assets/cards \
  --logo "style=adventurer radius=28 backgroundColor=181825,313244 baseColor=89b4fa,f38ba8" \
  --fonts 'head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf'
```
</details>

---

**Basic Overrides:**
- Universal: `BG=#fff RADIUS=10`
- Light only: `LIGHT_BG=#f0f0f0`
- Dark only: `DARK_BG=#181825`

<details><summary>Advanced Overrides</summary>

- Use `RADIUS`, `BORDER`, `BG`, `FG`, `HL`, `AC` for border radius, border width, background, foreground, highlight, accent.
- Any SVG placeholder can be overridden.
- Example: `DARK_HL=#f38ba8 DARK_AC=#89b4fa`

</details>

---

**Basic Fonts:**
```yaml
fonts: |
  head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
```
<details><summary>Advanced Fonts</summary>

```yaml
fonts: |
  head=inter-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-800-normal.ttf
  body=inter-regular:400@https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.ttf
  stat=nabla:400@https://cdn.jsdelivr.net/fontsource/fonts/nabla@latest/latin-400-normal.ttf
```
- `section`: head, body, stat
- `alias`: any short name
- `weight`: font weight (e.g. 400, 800)
- `url-to-ttf`: direct link to a .ttf file
- Omitted sections use the default font.
- [Google Fonts](https://fonts.google.com/), [Fontsource](https://fontsource.org/), [Font Library](https://fontlibrary.org/)

</details>

---

**Basic Logo:**
```yaml
logo: |
  style=bottts
```
<details><summary>Advanced Logo</summary>

```yaml
logo: |
  style=adventurer
  radius=28
  backgroundColor=181825,313244
  baseColor=89b4fa,f38ba8
```
- `style`: see list below
- All other options: see [DiceBear Options](https://github.com/dicebear/dicebear/blob/9.x/packages/%40dicebear/core/src/schema.ts)
- The `seed` is set automatically for each repo.

**Available styles:**
adventurer, adventurerNeutral, avataaars, avataaarsNeutral, bigEars, bigEarsNeutral, bigSmile, bottts, botttsNeutral, croodles, croodlesNeutral, dylan, funEmoji, glass, icons, identicon, initials, lorelei, loreleiNeutral, micah, miniavs, notionists, notionistsNeutral, openPeeps, personas, pixelArt, pixelArtNeutral, rings, shapes, thumbs

<details><summary>Show all DiceBear options</summary>

style, radius, backgroundType, backgroundColor, baseColor, colorful, lineColor, flip, rotate, scale, size, backgroundRotation, translateX, translateY, clip, randomizeIds, accessories, accessoriesColor, accessoriesProbability, base, clothesColor, clothing, clothingGraphic, eyebrows, eyes, facialHair, facialHairColor, facialHairProbability, hairColor, hatColor, mouth, nose, skinColor, top, topProbability

</details>

[DiceBear Styles](https://www.dicebear.com/styles/)

</details>

---

## Requirements

- Bash, jq, gh, inkscape

---

## License

[MIT](LICENCE)
