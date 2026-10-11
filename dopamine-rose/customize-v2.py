"""Install Rose's replacement UIKit frontend; leave the jailbreak engine untouched."""
from pathlib import Path
import json
import plistlib
import shutil
from PIL import Image

ROOT = Path('Application/Dopamine')
PATCH = Path(__file__).resolve().parent
ui = ROOT / 'UI'
assert ROOT.exists()
original = (ui / 'DOMainViewController.m').read_text()
flow = original[original.index('- (void)startJailbreak'):original.index('-(void)setupUpdateAvailable:')]
for name in ['DOMainViewController.m', 'DOJailbreakButton.m', 'DONavigationController.m', 'RoseUI.h']:
    source = (PATCH / 'ui' / name).read_text()
    if name == 'DOMainViewController.m':
        source = source.replace('/* ROSE_PRESERVED_JAILBREAK_FLOW */', flow)
    (ui / name).write_text(source)

project = ROOT.parent / 'Dopamine.xcodeproj/project.pbxproj'
source = project.read_text()
source = source.replace('/* Begin PBXFileReference section */', '/* Begin PBXFileReference section */\n\t\tD0A05E000000000000000001 /* RoseUI.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = RoseUI.h; sourceTree = "<group>"; };')
source = source.replace('042479812B66916B0082581B /* DOUIManager.h */,', '042479812B66916B0082581B /* DOUIManager.h */,\n\t\t\t\tD0A05E000000000000000001 /* RoseUI.h */,')
project.write_text(source)

# The custom log renderer honors the same verbose preference as the original views.
manager = ui / 'DOUIManager.m'
source = manager.read_text().replace('BOOL isDebug = self.logView.class == DODebugLogView.class;', 'BOOL isDebug = self.logView.class == DODebugLogView.class || [self isDebug];')
source = source.replace('NSString *log = [self.logRecord componentsJoinedByString:@"\\n"];', 'NSString *log = [[self roseLogSnapshot] componentsJoinedByString:@"\\n"];')
source = source.replace('- (void)shareLogRecordFromView:', '''- (NSArray<NSString *> *)roseLogSnapshot
{
    [_logLock lock];
    NSArray *snapshot = self.logRecord.copy;
    [_logLock unlock];
    return snapshot;
}

- (void)shareLogRecordFromView:''')
manager.write_text(source)
header = ui / 'DOUIManager.h'
header.write_text(header.read_text().replace('- (BOOL)isDebug;', '- (BOOL)isDebug;\n- (NSArray<NSString *> *)roseLogSnapshot;'))

# Full-screen lists share the new navigation, opaque surfaces and readable separators.
style = ui / 'Settings/PSLists/DOPSListController.m'
source = style.read_text().replace('#import "DOThemeManager.h"', '#import "DOThemeManager.h"\n#import "RoseUI.h"')
source = source.replace('vc.view.backgroundColor = theme.windowColor;', 'vc.view.backgroundColor = RoseInk();')
source = source.replace('vc.view.layer.cornerRadius = 16;', 'vc.view.layer.cornerRadius = 0;')
source = source.replace('[UIColor colorWithRed: 71.0/255.0 green: 169.0/255.0 blue: 135.0/255.0 alpha: 1.0]', 'RosePink()')
source = source.replace('[_table setSeparatorColor:[UIColor clearColor]];', '[_table setSeparatorColor:[UIColor colorWithWhite:0.16 alpha:1]];')
source = source.replace('_table.frame = CGRectMake(12, 5, self.view.bounds.size.width - 24, self.view.bounds.size.height - 10);', '''UIEdgeInsets safe = self.view.safeAreaInsets;
    _table.frame = CGRectMake(12, safe.top, self.view.bounds.size.width - 24, self.view.bounds.size.height - safe.top - safe.bottom);
    _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;''')
style.write_text(source)

# General configuration precedes exploit selection; all original specifiers and handlers survive.
settings = ui / 'Settings/DOSettingsController.m'
source = settings.read_text()
needle = '        _specifiers = specifiers;'
assert needle in source
source = source.replace(needle, '''        NSMutableArray *exploitSection = [NSMutableArray new];
        BOOL inExploitSection = NO;
        for (PSSpecifier *specifier in specifiers.copy) {
            if (specifier.cellType == PSGroupCell) {
                inExploitSection = [specifier.name isEqualToString:DOLocalizedString(@"Section_Exploits")];
            }
            if (inExploitSection) {
                [exploitSection addObject:specifier];
                [specifiers removeObject:specifier];
            }
        }
        [specifiers addObjectsFromArray:exploitSection];
''' + needle)
settings.write_text(source)

art = Image.open(PATCH / 'assets/reference.jpg').convert('RGB')
# Asset preparation only: retain the user's actual illustration and its texture.
portrait = art.crop((185, 870, 495, 1280))
catalog = ROOT / 'Assets.xcassets'
dest = catalog / 'RosePortrait.imageset'
dest.mkdir(exist_ok=True)
portrait.save(dest / 'portrait.png', optimize=True)
(dest / 'Contents.json').write_text(json.dumps({'images': [{'filename':'portrait.png','idiom':'universal','scale':'2x'}], 'info':{'version':1,'author':'xcode'}}))
icons = catalog / 'AppIcon.appiconset'
contents = json.loads((icons / 'Contents.json').read_text())
icon = art.crop((280, 870, 510, 1100))
for item in contents['images']:
    if 'filename' not in item: continue
    size = round(float(item['size'].split('x')[0]) * float(item.get('scale', '1x')[:-1]))
    icon.resize((size,size), Image.Resampling.LANCZOS).save(icons / item['filename'])
info = ROOT / 'Info.plist'
data = plistlib.loads(info.read_bytes())
data['CFBundleDisplayName'] = 'Dopamine Rose'
data['RoseFrontendVersion'] = '2.0'
info.write_bytes(plistlib.dumps(data))
shutil.copy(PATCH / 'assets/reference.jpg', ROOT / 'Resources/RoseReference.jpg')
print('ROSE_V2_OK: replacement home, navigation, live progress, logs, device, recovery, retained settings')

