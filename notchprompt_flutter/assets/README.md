# Tray icon assets

Place the following files in this directory before building:

| File | Platform | Format | Size |
|---|---|---|---|
| `tray_icon_template.png` | macOS | PNG, template image | 18×18 @1x, 36×36 @2x |
| `tray_icon.png` | Linux | PNG, full-colour | 22×22 |
| `tray_icon.ico` | Windows | ICO | 16×16, 32×32 multi-res |

## macOS Template Images

On macOS, tray icons must be provided as *template images* — monochrome PNGs
where non-transparent areas define the icon shape. The system colors them
automatically for light/dark mode.

Name the file `tray_icon_template.png` (the `_template` suffix is what tells
macOS to treat it as a template).

## Placeholder generation (dev only)

```bash
# Requires ImageMagick
magick -size 18x18 xc:black -fill white -draw "font-size 10 text 2,13 'NP'" \
  assets/tray_icon.png
cp assets/tray_icon.png assets/tray_icon_template.png
```
