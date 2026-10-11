import sys, zipfile, plistlib, hashlib, json
from pathlib import Path
ipa = Path(sys.argv[1])
with zipfile.ZipFile(ipa) as archive:
    assert archive.testzip() is None
    root = 'Payload/Dopamine.app/'
    info = plistlib.loads(archive.read(root + 'Info.plist'))
    assert info['RoseFrontendVersion'] == '2.0'
    assert tuple(map(int, info['MinimumOSVersion'].split('.'))) <= (15, 7, 7)
    assert info['CFBundleDisplayName'] == 'Dopamine Rose'
    binary = archive.read(root + 'Dopamine')
    assert len(binary) > 100000
    assert b'Rose.' in binary
    assert b'RoseProgressView' in binary
    assert b'RoseLibraryController' in binary
    assert len(archive.read(root + 'Assets.car')) > 10000
report = json.loads(Path('../asset-report.json').read_text())
assert any(item.get('Name') == 'RosePortrait' for item in report)
packaged = plistlib.loads(Path('../packaged-entitlements.plist').read_bytes())
original = plistlib.loads(Path('Application/Dopamine/Dopamine.entitlements').read_bytes())
assert all(packaged.get(key) == value for key, value in original.items())
print('PACKAGE_VERIFIED', info['MinimumOSVersion'], info['CFBundleExecutable'], ipa.stat().st_size, hashlib.sha256(ipa.read_bytes()).hexdigest())

