"""Generate the text-free Outta Pocket SVG UI kit.

The output is deterministic so colors, outlines, stitching, and optical padding
stay consistent across every control state. Run from the Godot project root.
"""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "ui"

INK = "#151515"
INK_2 = "#292727"
RED = "#E52620"
RED_HOVER = "#F23A32"
RED_PRESS = "#B91817"
IVORY = "#F7F2E8"
IVORY_HOVER = "#FFFDF7"
IVORY_PRESS = "#D9D3C8"
MUTED = "#746F69"


def write(relative: str, body: str, view_box: str = "0 0 320 112") -> None:
    path = OUT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view_box}">\n'
        f'{body}\n</svg>\n',
        encoding="utf-8",
    )


def pocket(fill: str, stitch: str = INK, opacity: float = 1.0) -> str:
    return f'''  <g opacity="{opacity}">
    <path d="M24 7 H296 Q310 7 310 21 V74 Q310 86 298 89 L160 106 22 89 Q10 86 10 74 V21 Q10 7 24 7Z" fill="{INK}"/>
    <path d="M26 15 H294 Q302 15 302 23 V72 Q302 78 294 80 L160 97 26 80 Q18 78 18 72 V23 Q18 15 26 15Z" fill="{fill}"/>
    <path d="M31 25 H289 Q293 25 293 30 V67 Q293 71 288 72 L160 87 32 72 Q27 71 27 67 V30 Q27 25 31 25Z" fill="none" stroke="{stitch}" stroke-width="4" stroke-dasharray="11 8" stroke-linecap="round"/>
  </g>'''


def rounded(
    fill: str,
    stitch: str = INK,
    opacity: float = 1.0,
    radius: int = 18,
    width: int = 320,
    height: int = 112,
) -> str:
    outer_x = 5
    inner_x = 14
    stitch_x = 25
    outer_width = width - outer_x * 2
    inner_width = width - inner_x * 2
    stitch_width = width - stitch_x * 2
    outer_height = height - outer_x * 2
    inner_height = height - inner_x * 2
    stitch_height = height - stitch_x * 2
    return f'''  <g opacity="{opacity}">
    <rect x="{outer_x}" y="{outer_x}" width="{outer_width}" height="{outer_height}" rx="{radius + 5}" fill="{INK}"/>
    <rect x="{inner_x}" y="{inner_x}" width="{inner_width}" height="{inner_height}" rx="{radius}" fill="{fill}"/>
    <rect x="{stitch_x}" y="{stitch_x}" width="{stitch_width}" height="{stitch_height}" rx="{max(radius - 7, 4)}" fill="none" stroke="{stitch}" stroke-width="4" stroke-dasharray="11 8" stroke-linecap="round"/>
  </g>'''


def panel(fill: str, header: str | None = None) -> str:
    header_markup = ""
    if header:
        header_markup = f'''<path d="M16 16 H304 V76 H16Z" fill="{header}"/>
    <path d="M28 66 H292" stroke="{INK}" stroke-width="5"/>'''
    return f'''  <rect x="5" y="5" width="310" height="310" rx="26" fill="{INK}"/>
  <rect x="15" y="15" width="290" height="290" rx="18" fill="{fill}"/>
  {header_markup}
  <rect x="28" y="28" width="264" height="264" rx="10" fill="none" stroke="{INK}" stroke-width="4" stroke-dasharray="12 9" stroke-linecap="round"/>'''


def icon_frame(inner: str, fill: str = INK_2) -> str:
    return rounded(fill, IVORY) + f'\n  <g fill="{IVORY}" stroke="{IVORY}" stroke-linecap="round" stroke-linejoin="round">{inner}</g>'


def generate_buttons() -> None:
    palettes = {
        "primary": [(RED, 1), (RED_HOVER, 1), (RED_PRESS, 1), (MUTED, .55)],
        "secondary": [(INK_2, 1), ("#3A3737", 1), ("#0B0B0B", 1), (MUTED, .5)],
        "danger": [(IVORY, 1), (IVORY_HOVER, 1), (IVORY_PRESS, 1), (MUTED, .42)],
    }
    states = ("default", "hover", "pressed", "disabled")
    for family, values in palettes.items():
        for state, (fill, opacity) in zip(states, values):
            write(f"buttons/{family}_{state}.svg", pocket(fill, INK, opacity))
    for state, (fill, opacity) in zip(states, palettes["secondary"]):
        write(
            f"buttons/small_{state}.svg",
            rounded(fill, IVORY, opacity, radius=11, width=192, height=72),
            "0 0 192 72",
        )


def generate_players() -> None:
    states = {
        "default": (INK_2, IVORY, 1),
        "current_turn": (RED, INK, 1),
        "selected": (IVORY, INK, 1),
        "disabled": (MUTED, INK, .45),
        "eliminated": ("#343131", "#766F6A", .55),
        "leader": (RED_HOVER, INK, 1),
    }
    for state, (fill, stitch, opacity) in states.items():
        write(f"players/name_{state}.svg", pocket(fill, stitch, opacity))
        write(
            f"players/score_{state}.svg",
            rounded(fill, stitch, opacity, width=112, height=112),
            "0 0 112 112",
        )
    crown = f'''<path d="M22 55 34 27 53 49 76 19 99 49 118 27 130 55 123 93H29Z" fill="{RED}" stroke="{INK}" stroke-width="9" stroke-linejoin="round"/>
  <path d="M38 69H114" fill="none" stroke="{INK}" stroke-width="6" stroke-dasharray="10 7"/>'''
    write("players/leader_crown.svg", crown, "0 0 152 112")


def generate_panels() -> None:
    write("panels/popup.svg", panel(IVORY, RED), "0 0 320 320")
    write("panels/confirmation.svg", panel(IVORY, None), "0 0 320 320")
    write("panels/round_summary.svg", panel(IVORY, RED), "0 0 320 320")
    write("panels/settings.svg", panel(INK_2, RED), "0 0 320 320")
    write("panels/scrollable_list.svg", panel(INK_2, None), "0 0 320 320")
    write("panels/information.svg", panel(IVORY, None), "0 0 320 320")
    write("panels/header_bar.svg", rounded(RED), "0 0 320 88")
    write("panels/section_divider.svg", f'<path d="M12 28H308" stroke="{RED}" stroke-width="8" stroke-dasharray="20 14" stroke-linecap="round"/>', "0 0 320 56")


def generate_controls() -> None:
    write("controls/text_input.svg", rounded(IVORY), "0 0 320 88")
    write("controls/dropdown.svg", rounded(INK_2, IVORY), "0 0 320 88")
    write("controls/tooltip.svg", rounded(INK_2, RED), "0 0 320 112")
    write(
        "controls/icon_frame.svg",
        rounded(INK_2, RED, width=112, height=112),
        "0 0 112 112",
    )
    write(
        "controls/notification_badge.svg",
        rounded(RED, width=88, height=88, radius=13),
        "0 0 88 88",
    )
    write("controls/banner.svg", pocket(RED), "0 0 320 112")
    ribbon = f'''<path d="M8 12H292L270 56 292 100H8L30 56Z" fill="{INK}"/>
  <path d="M20 22H275L258 56 275 90H20L39 56Z" fill="{RED}"/>
  <path d="M35 32H258" stroke="{INK}" stroke-width="4" stroke-dasharray="11 8"/>'''
    write("controls/ribbon.svg", ribbon)
    for state, x in (("off", 72), ("on", 248)):
        fill = RED if state == "on" else INK_2
        markup = rounded(fill, IVORY) + f'<circle cx="{x}" cy="56" r="31" fill="{IVORY}" stroke="{INK}" stroke-width="8"/>'
        write(f"controls/toggle_{state}.svg", markup)
    checkbox_off = rounded(IVORY, width=88, height=88, radius=13)
    write("controls/checkbox_off.svg", checkbox_off, "0 0 88 88")
    check = rounded(RED, width=88, height=88, radius=13) + f'<path d="M25 46 41 63 68 27" fill="none" stroke="{IVORY}" stroke-width="11" stroke-linecap="round" stroke-linejoin="round"/>'
    write("controls/checkbox_on.svg", check, "0 0 88 88")
    scrollbar = f'<rect x="20" y="4" width="24" height="312" rx="12" fill="{INK}"/><rect x="13" y="76" width="38" height="112" rx="19" fill="{RED}" stroke="{INK}" stroke-width="7"/>'
    write("controls/scroll_bar.svg", scrollbar, "0 0 64 320")


def generate_icons() -> None:
    icons = {
        "players": '<circle cx="160" cy="43" r="18"/><circle cx="118" cy="52" r="14"/><circle cx="202" cy="52" r="14"/><path d="M127 91Q127 65 160 65T193 91ZM91 91Q91 70 118 70h6v21Zm138 0h-33V70h6q27 0 27 21Z" stroke="none"/>',
        "cards": '<rect x="122" y="28" width="77" height="67" rx="8" stroke-width="8" fill="none" transform="rotate(-8 160 61)"/><rect x="143" y="19" width="77" height="67" rx="8" stroke-width="8" fill="#292727"/>',
        "settings": '<path d="M160 24v12m0 40v12M128 56h12m40 0h12m-55-23 9 9m28 28 9 9m0-46-9 9m-28 28-9 9" fill="none" stroke-width="10"/><circle cx="160" cy="56" r="20" fill="none" stroke-width="10"/>',
        "audio": '<path d="M117 46h20l24-20v60l-24-20h-20Z"/><path d="M178 41q17 15 0 30m15-45q32 30 0 60" fill="none" stroke-width="9"/>',
        "help": '<path d="M139 40q2-20 23-20 22 0 22 18 0 13-13 20-10 5-10 16" fill="none" stroke-width="10"/><circle cx="160" cy="90" r="6" stroke="none"/>',
        "warning": '<path d="M160 18 217 94H103Z" fill="none" stroke-width="9"/><path d="M160 43v25" fill="none" stroke-width="9"/><circle cx="160" cy="82" r="5" stroke="none"/>',
        "exit": '<path d="M177 28h31v56h-31M188 56h-72m0 0 23-21m-23 21 23 21" fill="none" stroke-width="10"/>',
        "back": '<path d="M205 30h-45l-40 26 40 26h45" fill="none" stroke-width="11"/>',
        "checkmark": '<path d="M112 56 145 84 210 25" fill="none" stroke-width="13"/>',
        "x": '<path d="m126 25 68 62m0-62-68 62" fill="none" stroke-width="13"/>',
    }
    for name, markup in icons.items():
        write(f"icons/{name}.svg", icon_frame(markup), "0 0 320 112")


def main() -> None:
    generate_buttons()
    generate_players()
    generate_panels()
    generate_controls()
    generate_icons()
    print(f"Generated {len(list(OUT.rglob('*.svg')))} SVG assets in {OUT}")


if __name__ == "__main__":
    main()
