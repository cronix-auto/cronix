from pathlib import Path
import json
import plistlib
import re
import shutil
import sys

overlay = Path(__file__).resolve().parent
source = Path(sys.argv[1]).resolve()
ui = source / 'Application/Dopamine/UI'
original = (ui / 'DOMainViewController.m').read_text()
start = original.index('- (void)startJailbreak\n')
end = original.index('-(void)setupUpdateAvailable:', start)
engine_flow = original[start:end]
# Keep the upstream workarounds, mutex, engine call, errors, and finalization.
# Alerts must be presented by the visible activity screen after navigation.
engine_flow = engine_flow.replace('[self presentViewController:', '[self.navigationController.topViewController presentViewController:')
(ui / 'DOMainViewController.m').write_text((overlay / 'main-prefix.m').read_text() + '\n' + engine_flow + '\n' + (overlay / 'main-suffix.m').read_text())
for name in ['CronixStyle.h', 'CronixUI.h', 'CronixUI.inc', 'DONavigationController.m', 'DOJailbreakButton.m']:
    shutil.copy2(overlay / name, ui / name)
shutil.copy2(overlay / 'DOLogCrashViewController.m', ui / 'Log/DOLogCrashViewController.m')

manager = ui / 'DOUIManager.m'
text = manager.read_text()
text = text.replace('if (!self.logView || !log)', 'if (!log)')
needle = '    [self.logRecord addObject:log];'
assert text.count(needle) == 1
text = text.replace(needle, needle + '''
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CronixLogChanged" object:nil];
    });''')
snapshot = '''
- (NSArray<NSString *> *)cronixLogSnapshot
{
    [_logLock lock];
    NSArray *snapshot = [self.logRecord copy];
    [_logLock unlock];
    return snapshot;
}

'''
text = text.replace('- (void)shareLogRecordFromView:', snapshot + '- (void)shareLogRecordFromView:')
manager.write_text(text)
header = ui / 'DOUIManager.h'
header.write_text(header.read_text().replace('- (BOOL)isDebug;', '- (BOOL)isDebug;\n- (NSArray<NSString *> *)cronixLogSnapshot;'))

info_path = source / 'Application/Dopamine/Info.plist'
info = plistlib.loads(info_path.read_bytes())
info['CFBundleDisplayName'] = 'Cronix'
info['CFBundleName'] = 'Cronix'
info['CronixFrontendVersion'] = '1.0'
info['CronixUpstreamCommit'] = '448ff1a83d2bb807346f1f3d36332e4afbf9794a'
info['UIDesignRequiresCompatibility'] = True
info_path.write_bytes(plistlib.dumps(info))
project = source / 'Application/Dopamine.xcodeproj/project.pbxproj'
project.write_text(project.read_text().replace('PRODUCT_BUNDLE_IDENTIFIER = com.opa334.Dopamine;', 'PRODUCT_BUNDLE_IDENTIFIER = com.zenyical.Cronix;'))

# Every launcher icon size gets the same native vector identity.
icon_path = overlay / 'CronixIcon.png'
if icon_path.exists():
    from PIL import Image
    icon = Image.open(icon_path).convert('RGB')
    assets = source / 'Application/Dopamine/Assets.xcassets'
    for directory in assets.glob('AppIcon*.appiconset'):
        manifest = json.loads((directory / 'Contents.json').read_text())
        for image in manifest['images']:
            if not image.get('filename'):
                continue
            scale = float(image.get('scale', '1x').removesuffix('x'))
            size = round(float(image['size'].split('x')[0]) * scale)
            icon.resize((size, size), Image.Resampling.LANCZOS).save(directory / image['filename'])

print('CRONIX_FRONTEND_INSTALLED')
