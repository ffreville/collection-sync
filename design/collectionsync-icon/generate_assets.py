"""Generates the app icon / adaptive icon / splash logo PNGs used by
flutter_launcher_icons and flutter_native_splash, matching the design drafted
in the Claude Design canvas (Main.dc.html / AdaptiveForeground.dc.html /
SplashLight.dc.html / SplashDark.dc.html next to this script).
"""

from PIL import Image, ImageDraw, ImageFont

TERRACOTTA = (193, 103, 62, 255)   # #C1673E — light theme accent
WHITE = (254, 253, 251, 255)       # #FEFDFB — light theme accent-contrast

FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def centered_text(draw, size, text, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size - w) / 2 - bbox[0]
    y = (size - h) / 2 - bbox[1]
    draw.text((x, y), text, font=font, fill=fill)


def make_flat_icon(path, size=1024):
    img = Image.new("RGBA", (size, size), TERRACOTTA)
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT_PATH, int(size * 0.40))
    centered_text(draw, size, "CS", font, WHITE)
    img.save(path)


def make_adaptive_foreground(path, size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Android adaptive icons crop roughly the outer 1/6 on each side —
    # keep the glyph comfortably inside that safe zone.
    font = ImageFont.truetype(FONT_PATH, int(size * 0.225))
    centered_text(draw, size, "CS", font, WHITE)
    img.save(path)


def make_splash_logo(path, size=512):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    margin = int(size * 0.12)
    radius = int(size * 0.27)
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=radius,
        fill=TERRACOTTA,
    )
    font = ImageFont.truetype(FONT_PATH, int(size * 0.20))
    centered_text(draw, size, "CS", font, WHITE)
    img.save(path)


if __name__ == "__main__":
    import os

    out_dir = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "icon")
    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)

    make_flat_icon(os.path.join(out_dir, "icon.png"))
    make_adaptive_foreground(os.path.join(out_dir, "icon_foreground.png"))
    make_splash_logo(os.path.join(out_dir, "splash_logo.png"))

    print("wrote assets to", out_dir)
