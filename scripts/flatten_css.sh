#!/bin/bash
# Flattens one-level nested CSS blocks inside <style>...</style> in an SVG, leaves the rest untouched
awk '
  BEGIN {instyle=0; inparent=0; parent=""; copying=0;}
  /<style>/ { print; instyle=1; next }
  /<\/style>/ { instyle=0; print; next }
  !instyle { print; next }
  # Only below runs inside <style> ...
  /^[ \t]*:root[ \t]*\{/ || /^[ \t]*\.[a-zA-Z0-9_-]+[ \t]*\{/ {
    if (!inparent && !copying) {
      # Peek ahead to see if this is a nested block or a normal block
      line=$0;
      pos=NR;
      getline nextline;
      if (nextline ~ /^[ \t]*\.[a-zA-Z0-9_-]+[ \t]*\{/) {
        # This is a parent for nested children
        parent=$1; sub(/\{/, "", parent);
        inparent=1;
        # Immediately process the peeked child line
        $0 = nextline;
        # fall through to process as child
      } else {
        # Not a nested block, start copying mode and print current line
        print line;
        copying=1;
        print nextline;
        next;
      }
    }
  }
  copying {
    if (/^[ \t]*\}/) {
      print;
      copying=0;
      next;
    }
    print;
    next;
  }
  inparent && /^[ \t]*\.[a-zA-Z0-9_-]+[ \t]*\{[^}]*\}/ {
    # Single-line child block: .child { ... }
    match($0, /^[ \t]*\.[a-zA-Z0-9_-]+/);
    child=substr($0, RSTART, RLENGTH);
    rest=substr($0, RLENGTH+1);
    gsub(/^ *\{/, "", rest);
    gsub(/} *$/, "", rest);
    printf "%s %s { %s }\n", parent, child, rest;
    next
  }
  inparent && /^[ \t]*\.[a-zA-Z0-9_-]+[ \t]*\{/ {
    # Multi-line child block
    child=$1; sub(/\{/, "", child);
    printf "%s %s {\n", parent, child;
    inchild=1;
    next
  }
  inparent && inchild && /^[ \t]*\}/ {
    print "}";
    inchild=0;
    next
  }
  inparent && inchild {
    print;
    next
  }
  inparent && !inchild && /^[ \t]*\}/ {
    inparent=0;
    parent="";
    next
  }
  !inparent && !inchild && /\S/ {
    print;
    next
  }
' | sed '/^\s*$/d'
