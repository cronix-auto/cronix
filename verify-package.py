import hashlib
import json
import plistlib
from pathlib import Path
import struct
import sys
import zipfile

path = Path(sys.argv[1])
with zipfile.ZipFile(path) as archive:
    assert archive.testzip() is None, 'Corrupt IPA archive'
    info = plistlib.loads(archive.read('Payload/Dopamine.app/Info.plist'))
    assert info['CFBundleDisplayName'] == 'Cronix', info
    assert info['CFBundleIdentifier'] == 'com.zenyical.Cronix'
    assert info['CronixFrontendVersion'] == '1.0'
    assert float(info['MinimumOSVersion']) <= 15.0
    binary = archive.read('Payload/Dopamine.app/' + info['CFBundleExecutable'])
    assert struct.unpack_from('<II', binary) == (0xFEEDFACF, 0x0100000C), 'Expected thin ARM64 Mach-O'
    for token in [b'Cronix', b'Made by: Zenyical (creds also: oppa334)', b'cronixLogSnapshot']:
        assert token in binary, token
    names = archive.namelist()
    assert any(n.endswith('/basebin.tar') for n in names), 'Missing jailbreak basebin'
    assert any(n.endswith('/LICENSE.md') for n in names), 'Missing upstream licence'
    assert any(n.endswith('/Assets.car') for n in names), 'Missing compiled artwork'
    entitlements = Path('entitlements.plist')
    if entitlements.exists():
        expected = plistlib.loads(Path('source/Application/Dopamine/Dopamine.entitlements').read_bytes())
        actual = plistlib.loads(entitlements.read_bytes())
        assert actual == expected, 'Signed entitlements differ from upstream'
    report = {
        'name':info['CFBundleDisplayName'], 'bundle_id':info['CFBundleIdentifier'],
        'minimum_ios':info['MinimumOSVersion'], 'engine_version':info['CFBundleShortVersionString'],
        'frontend_version':info['CronixFrontendVersion'], 'upstream_commit':info['CronixUpstreamCommit'],
        'bytes':path.stat().st_size, 'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'device_jailbreak_tested':False,
    }
    Path('verification.json').write_text(json.dumps(report, indent=2))
    print('CRONIX_PACKAGE_VERIFIED', json.dumps(report))
