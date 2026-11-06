#!/usr/bin/env bash
# Generate badged OpenCode notification icons.
#
# The source logo is a 2-bit colormap PNG, so it is converted to sRGB+alpha
# before compositing or the coloured badges get quantised to the logo palette.
#
# Badge colours are the `bright` variants from ~/.config/alacritty/alacritty.toml
# so notifications match the terminal palette.
set -euo pipefail

# The logo ships alongside this script so icon generation does not depend on
# anything outside the plugin directory.
SOURCE="${SOURCE:-$(dirname "$(readlink -f "$0")")/logo.png}"
OUT_DIR="${OUT_DIR:-$HOME/.local/share/icons/opencode}"
SIZE=128

BLUE="#42A5F5"   # colors.bright.blue   - question
YELLOW="#FFCA28" # colors.bright.yellow - permission
RED="#EF5350"    # colors.bright.red    - error

# Badge geometry, as a fraction of SIZE.
BADGE_SCALE=0.42
OUTLINE="#080808" # colors.primary.background

[[ -f "$SOURCE" ]] || { echo "source not found: $SOURCE" >&2; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick 'magick' not found" >&2; exit 1; }

mkdir -p "$OUT_DIR"

badge_px=$(awk "BEGIN{printf \"%d\", $SIZE * $BADGE_SCALE}")
font_px=$(awk "BEGIN{printf \"%d\", $badge_px * 0.78}")
stroke_px=$(awk "BEGIN{printf \"%.1f\", $badge_px * 0.08}")

# Flatten onto sRGB with an alpha channel and normalise the canvas.
magick "$SOURCE" \
  -colorspace sRGB -alpha on \
  -resize "${SIZE}x${SIZE}" \
  "$OUT_DIR/opencode.png"

# $1 output name, $2 badge fill, $3 glyph
make_badged() {
  local name="$1" fill="$2" glyph="$3"

  # Badge drawn separately so the glyph can carry its own outline, which keeps
  # it legible against both light and dark notification backgrounds.
  magick -size "${badge_px}x${badge_px}" xc:none \
    -fill "$fill" -stroke "$OUTLINE" -strokewidth "$stroke_px" \
    -draw "circle $((badge_px / 2)),$((badge_px / 2)) $((badge_px / 2)),2" \
    -gravity center \
    -font DejaVu-Sans-Bold -pointsize "$font_px" \
    -fill "$OUTLINE" -stroke none \
    -annotate 0 "$glyph" \
    "miff:-" |
    magick "$OUT_DIR/opencode.png" "miff:-" \
      -gravity southeast -composite \
      "$OUT_DIR/$name"
}

make_badged "opencode-question.png" "$BLUE" "?"
make_badged "opencode-warning.png" "$YELLOW" "!"
# U+00D7 multiplication sign: centred on the maths axis, unlike a lowercase "x"
# which sits on the text baseline and reads as visibly offset in a small badge.
make_badged "opencode-error.png" "$RED" "×"

echo "wrote to $OUT_DIR:"
ls -1 "$OUT_DIR"
