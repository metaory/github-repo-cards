#!/bin/bash
# Inlines CSS variables from the :root { ... } block as var(--name) in the SVG

input=$(mktemp)
cat > "$input"

# Remove the first :root { ... } block and save to tmpfile
awk '
  /:root[[:space:]]*\{/ {inroot=1; next}
  inroot && /\}/ {inroot=0; next}
  !inroot
' "$input" > "$input.out"

# Extract variable definitions from the first :root { ... } block
awk '
  /:root[[:space:]]*\{/ {inroot=1; next}
  inroot && /\}/ {exit}
  inroot && /^ *--[a-zA-Z0-9_-]+:/ {print}
' "$input" | while IFS=: read -r key val; do
  key=$(echo "$key" | sed -E 's/^ *--([a-zA-Z0-9_-]+)$/\1/')
  val=$(echo "$val" | sed -E 's/^[[:space:]]*//; s/;[[:space:]]*$//')
  [ -z "$key" ] && continue
  sed -i -e "s|var(--$key)|$val|g" "$input.out"
done

cat "$input.out"
rm -f "$input" "$input.out"
