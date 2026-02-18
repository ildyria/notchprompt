# Notchprompt Windows App Manifest
#
# This file is embedded in the runner executable by windows/runner/Runner.rc.
# It declares the app as DPI-aware (per-monitor v2) so the overlay and
# settings window render crisply on HiDPI displays.
#
# Flutter's default manifest already sets dpiAwareness, but this file
# documents the values explicitly so they can be reviewed and changed.
#
# The actual manifest XML is in windows/runner/runner.exe.manifest — Flutter
# generates it with <dpiAwareness>PerMonitorV2</dpiAwareness> which is correct.
# No changes needed.
