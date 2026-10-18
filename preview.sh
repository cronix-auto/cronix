#!/bin/bash
set -euo pipefail
mkdir -p preview-app/CronixPreview.app previews
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
xcrun --sdk iphonesimulator clang -fobjc-arc -fmodules -isysroot "$SDK" \
  -target arm64-apple-ios15.0-simulator -framework UIKit -framework Foundation -framework QuartzCore \
  -I. preview.m -o preview-app/CronixPreview.app/CronixPreview
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
RUNTIME=$(xcrun simctl list runtimes -j | python3 -c 'import sys,json; r=[r for r in json.load(sys.stdin)["runtimes"] if r["isAvailable"] and "iOS" in r["name"]]; print(r[-1]["identifier"])')
DEVICE=$(xcrun simctl create CronixPreview com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation "$RUNTIME")
echo "$DEVICE" > previews/simulator-id.txt
xcrun simctl boot "$DEVICE"
xcrun simctl bootstatus "$DEVICE" -b
xcrun simctl status_bar "$DEVICE" override --time '9:41' --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
xcrun simctl install "$DEVICE" preview-app/CronixPreview.app
for MODE in home activity settings logs; do
  xcrun simctl launch "$DEVICE" com.zenyical.CronixPreview "$MODE"
  sleep 2
  xcrun simctl io "$DEVICE" screenshot "previews/$MODE.png"
  xcrun simctl terminate "$DEVICE" com.zenyical.CronixPreview
done
CONTAINER=$(xcrun simctl get_app_container "$DEVICE" com.zenyical.CronixPreview data)
cp "$CONTAINER/Documents/CronixIcon.png" CronixIcon.png
xcrun simctl shutdown "$DEVICE"
