#!/bin/bash
set -euo pipefail
mkdir -p preview-app/CronixPreview.app previews
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
xcrun --sdk iphonesimulator clang -fobjc-arc -fmodules -isysroot "$SDK" \
  -target arm64-apple-ios15.0-simulator -framework UIKit -framework Foundation -framework QuartzCore \
  -I. preview.m -o preview-app/CronixPreview.app/CronixPreview
if [ "${1:-}" = "--compile-only" ]; then
  exit 0
fi
python3 - <<'PY'
import plistlib
from pathlib import Path
info = {'CFBundleIdentifier':'com.zenyical.CronixPreview', 'CFBundleExecutable':'CronixPreview',
        'CFBundleName':'CronixPreview', 'CFBundleVersion':'1', 'CFBundleShortVersionString':'1.0',
        'CFBundlePackageType':'APPL', 'MinimumOSVersion':'15.0', 'UIDesignRequiresCompatibility':True,
        'UIDeviceFamily':[1], 'UILaunchScreen':{}}
Path('preview-app/CronixPreview.app/Info.plist').write_bytes(plistlib.dumps(info))
PY
codesign --force --sign - preview-app/CronixPreview.app
RUNTIME=$(xcrun simctl list runtimes -j | python3 -c 'import sys,json; r=[r for r in json.load(sys.stdin)["runtimes"] if r["isAvailable"] and "iOS" in r["name"]]; r.sort(key=lambda x:tuple(map(int,x["version"].split(".")))); print(r[0]["identifier"])')
DEVICE=$(xcrun simctl create CronixPreview com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation "$RUNTIME")
echo "$DEVICE" > previews/simulator-id.txt
xcrun simctl boot "$DEVICE"
xcrun simctl bootstatus "$DEVICE" -b
sleep 15
xcrun simctl status_bar "$DEVICE" override --time '9:41' --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
xcrun simctl install "$DEVICE" preview-app/CronixPreview.app
for MODE in home activity settings logs; do
  xcrun simctl launch --terminate-running-process --console "$DEVICE" com.zenyical.CronixPreview "$MODE" > "previews/$MODE-console.log" 2>&1 &
  LAUNCH_PID=$!
  sleep 15
  xcrun simctl io "$DEVICE" screenshot "previews/$MODE.png"
  xcrun simctl terminate "$DEVICE" com.zenyical.CronixPreview || true
  wait "$LAUNCH_PID" || true
done
CONTAINER=$(xcrun simctl get_app_container "$DEVICE" com.zenyical.CronixPreview data)
cp "$CONTAINER"/Documents/render-*.png previews/ || true
xcrun simctl spawn "$DEVICE" log show --style compact --last 10m --predicate 'process == "CronixPreview"' > previews/runtime.log || true
find "$HOME/Library/Logs/DiagnosticReports" -maxdepth 1 -name 'CronixPreview*.ips' -exec cp {} previews/ \; || true
xcrun simctl shutdown "$DEVICE"
