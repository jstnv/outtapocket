# Outta Pocket UI Kit

Text-free SVG controls derived from the Outta Pocket pocket-patch identity. The
kit uses flat color, a 9 px near-black keyline, a 4 px inset dashed stitch, and
consistent optical padding. Godot Labels supply all UI text.

## Palette

- Ink: `#151515`
- Surface ink: `#292727`
- Action red: `#E52620`
- Hover red: `#F23A32`
- Pressed red: `#B91817`
- Ivory: `#F7F2E8`
- Disabled: `#746F69` with reduced opacity

## Godot 4 setup

Use each SVG as a `StyleBoxTexture`. Enable texture-region stretching and use
axis stretch mode `Stretch`. Recommended patch margins:

- Pocket buttons/name frames: 48 px left/right, 34 px top/bottom
- Rounded controls/header bars: 32 px on every side
- Panels: 40 px on every side

Use the four state files as a Button's `normal`, `hover`, `pressed`, and
`disabled` styleboxes. Keep text in a child Label or the Button's `text` field.
Use at least 16 px inner horizontal content padding and 12 px vertical padding.

Player rows intentionally use two siblings in an `HBoxContainer`:

1. `score_<state>.svg` at a fixed 88-112 px width.
2. `name_<state>.svg` with horizontal `Expand + Fill`.

This keeps the score stable while the name region scales. Place the optional
`leader_crown.svg` in a non-intercepting overlay (`mouse_filter = IGNORE`).

SVGs remain resolution-independent for desktop and mobile. If raster PNGs are
needed for a specific export target, import/render them at 1x, 2x, and 3x from
these sources rather than editing geometry independently.

Regenerate the kit from the project root with:

```text
python tools/generate_ui_kit.py
```
