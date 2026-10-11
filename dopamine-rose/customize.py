#!/usr/bin/env python3
"""Dopamine Rose visual patch. Keeps upstream jailbreak and entitlements unchanged."""
from pathlib import Path
import json, math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path("Application/Dopamine")
CAT = ROOT / "Assets.xcassets"
assert ROOT.exists(), "Run in a Dopamine 3.x source checkout"
INK=(15,12,20); PANEL=(31,23,35); ROSE=(239,149,185); GOLD=(203,143,135); LIGHT=(255,226,232)
def font(sz,bold=True):
    paths=[
      "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
      "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
      "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    for p in paths:
        if Path(p).exists(): return ImageFont.truetype(p,sz)
    return ImageFont.load_default()
def replace(rel, old, new):
    path=ROOT/rel
    text=path.read_text(encoding="utf-8")
    if old not in text: raise RuntimeError("Patch context missing: "+str(path))
    path.write_text(text.replace(old,new,1),encoding="utf-8")
def face(draw, cx, cy, r):
    # Original stylized candy-villain emblem, inspired by Majin Buu's silhouette.
    sc=r/500
    def b(a): return tuple(int(cx+(x-500)*sc) if i%2==0 else int(cy+(x-500)*sc) for i,x in enumerate(a))
    draw.ellipse(b((80,70,920,910)),outline=GOLD,width=max(2,int(17*sc)))
    draw.ellipse(b((126,112,874,858)),fill=ROSE)
    # Crest and curled antenna, kept crisp and geometric.
    draw.polygon([(int(cx+x*sc),int(cy+y*sc)) for x,y in [(-115,-360),(-80,-500),(-42,-563),(10,-578),(75,-550),(112,-480),(65,-460),(12,-490),(-20,-478),(-50,-425),(-40,-350)]],fill=ROSE)
    draw.arc(b((420,-95,850,350)),200,345,fill=GOLD,width=max(3,int(16*sc)))
    # Slanted eyes and cheek cuts.
    draw.polygon([(int(cx+x*sc),int(cy+y*sc)) for x,y in [(-255,-32),(-85,16),(-115,72),(-248,19)]],fill=INK)
    draw.polygon([(int(cx+x*sc),int(cy+y*sc)) for x,y in [(255,-32),(85,16),(115,72),(248,19)]],fill=INK)
    draw.ellipse(b((465,110,485,130)),fill=(111,51,82))
    draw.ellipse(b((515,110,535,130)),fill=(111,51,82))
    draw.arc(b((355,120,645,370)),17,161,fill=INK,width=max(3,int(21*sc)))
    draw.arc(b((385,154,615,340)),17,161,fill=GOLD,width=max(2,int(11*sc)))

# Pure dark editorial background. No gradients, translucency tricks, or Liquid Glass.
W,H=1170,2532
bg=Image.new("RGB",(W,H),INK)
d=ImageDraw.Draw(bg)
for k in range(7):
    pad=k*34
    d.arc((615-pad,60-pad,1530+pad,975+pad),80,278,fill=(45+4*k,31+2*k,45+3*k),width=2)
d.line([(105,115),(105,2330)],fill=(62,40,53),width=3)
d.rectangle((105,110,198,119),fill=ROSE)
d.line([(955,2080),(955,2290),(850,2290)],fill=(77,50,62),width=4)
d.arc((760,2000,1120,2360),185,345,fill=GOLD,width=4)
d.text((110,2365),"R O S E  /  I O S   1 5",font=font(27),fill=(125,87,102))
dest=CAT/"Background"/"Background_Rose.imageset"
dest.mkdir(parents=True,exist_ok=True)
bg.save(dest/"rose.jpg",quality=94,optimize=True)
(dest/"Contents.json").write_text(json.dumps({"images":[{"filename":"rose.jpg","idiom":"universal","scale":"3x"}],"info":{"author":"xcode","version":1}},indent=2))

# Header wordmark, always rendered with a crisp bitmap and no iOS 16+ API.
for suffix,scale in [("",1),("@2x",2),("@3x",3)]:
    im=Image.new("RGBA",(960*scale,212*scale),(0,0,0,0))
    g=ImageDraw.Draw(im)
    g.ellipse((15*scale,33*scale,156*scale,174*scale),outline=GOLD,width=7*scale)
    g.ellipse((42*scale,60*scale,129*scale,147*scale),fill=ROSE)
    g.polygon([(53*scale,107*scale),(98*scale,116*scale),(87*scale,136*scale)],fill=INK)
    g.polygon([(118*scale,107*scale),(76*scale,116*scale),(86*scale,136*scale)],fill=INK)
    g.text((194*scale,37*scale),"DOPAMINE",font=font(90*scale),fill=LIGHT)
    g.text((203*scale,141*scale),"R O S E   E D I T I O N",font=font(31*scale),fill=ROSE)
    im.save(CAT/"Dopamine.imageset"/("Dopamine"+suffix+".png"))

# Consistent app icon in each asset-catalog size.
appicons=CAT/"AppIcon.appiconset"
contents=json.loads((appicons/"Contents.json").read_text())
for entry in contents["images"]:
    filename=entry.get("filename")
    if not filename: continue
    sz=int(round(float(entry["size"].split("x")[0])*float(entry.get("scale","1x").rstrip("x"))))
    R=1024
    icon=Image.new("RGB",(R,R),INK)
    g=ImageDraw.Draw(icon)
    g.ellipse((68,68,956,956),outline=GOLD,width=20)
    face(g,512,538,395)
    icon=icon.resize((sz,sz),Image.Resampling.LANCZOS)
    icon.save(appicons/filename)

# Bootlogo uses same personal mark, with transparency.
boot=CAT/"DopamineLogo.imageset"
if boot.exists():
    info=json.loads((boot/"Contents.json").read_text())
    for entry in info["images"]:
        fn=entry.get("filename")
        if not fn: continue
        s={"1x":400,"2x":800,"3x":1200}.get(entry.get("scale"),400)
        image=Image.new("RGBA",(s,s),(0,0,0,0))
        draw=ImageDraw.Draw(image)
        face(draw,s/2,s/2,s*0.41)
        image.save(boot/fn)

plist=ROOT/"UI/Themes/Themes.plist"
s=plist.read_text()
pos=s.index("\t<dict>",s.index("<array>"))
theme="""\t<dict>
        <key>key</key><string>rose</string>
        <key>name</key><string>Rose Edition</string>
        <key>image</key><string>Background_Rose.jpg</string>
        <key>actionMenuColor</key><string>FF211923</string>
        <key>windowColor</key><string>EE1F1723</string>
        <key>blur</key><integer>0</integer>
        <key>titleShadow</key><false/>
    </dict>
"""
if '<string>rose</string>' not in s: plist.write_text(s[:pos]+theme+s[pos:])

replace("UI/DOJailbreakButton.m",
"""        self.backgroundColor = [DOThemeManager menuColorWithAlpha:1.0];
        self.layer.cornerRadius = 14;
        self.layer.masksToBounds = YES;""",
"""        self.backgroundColor = [UIColor colorWithRed:0.937 green:0.584 blue:0.725 alpha:1];
        self.layer.cornerRadius = 18;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:0.985 green:0.785 blue:0.780 alpha:1].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:0.92 green:0.45 blue:0.62 alpha:1].CGColor;
        self.layer.shadowOpacity = 0.23;
        self.layer.shadowRadius = 15;
        self.layer.shadowOffset = CGSizeMake(0, 6);
        self.layer.masksToBounds = NO;""")
replace("UI/DOJailbreakButton.m",
"""        self.button = [DOActionMenuButton buttonWithAction:actions chevron:NO];""",
"""        self.button = [DOActionMenuButton buttonWithAction:actions chevron:NO];
        UIButtonConfiguration *roseButton = self.button.configuration;
        roseButton.baseForegroundColor = [UIColor colorWithRed:0.09 green:0.05 blue:0.10 alpha:1];
        self.button.configuration = roseButton;""")
replace("UI/ActionMenu/DOActionMenuView.m",
"""        self.layer.cornerRadius = 14;
        self.layer.masksToBounds = YES;""",
"""        self.layer.cornerRadius = 18;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:0.78 green:0.49 blue:0.56 alpha:0.28].CGColor;
        self.layer.masksToBounds = YES;""")
replace("UI/ActionMenu/DOActionMenuButton.m",
"""_separator.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.3];""",
"""_separator.backgroundColor = [UIColor colorWithRed:0.78 green:0.49 blue:0.56 alpha:0.22];""")
replace("UI/DOGlobalAppearance.m",
"""NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.60],""",
"""NSForegroundColorAttributeName: [UIColor colorWithRed:0.85 green:0.61 blue:0.66 alpha:1],""")

# A real live compatibility plate with dynamic OS version and support state.
plate="""    // Rose Edition status plate. Pure UIKit, supports iOS 15 and compact A9 displays.
    BOOL roseSupported = [[DOEnvironmentManager sharedManager] isSupported];
    UIView *rosePlate = [[UIView alloc] init];
    rosePlate.translatesAutoresizingMaskIntoConstraints = NO;
    rosePlate.backgroundColor = [UIColor colorWithRed:0.125 green:0.088 blue:0.137 alpha:1];
    rosePlate.layer.cornerRadius = 12;
    rosePlate.layer.borderWidth = 1;
    rosePlate.layer.borderColor = [UIColor colorWithRed:0.78 green:0.49 blue:0.56 alpha:0.36].CGColor;
    UILabel *roseLabel = [[UILabel alloc] init];
    roseLabel.translatesAutoresizingMaskIntoConstraints = NO;
    roseLabel.text = [NSString stringWithFormat:@"  %@  ·  iOS %@  /  ROSE EDITION",
                      roseSupported ? @"SUPPORTED" : @"UNSUPPORTED",
                      [UIDevice currentDevice].systemVersion];
    roseLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    roseLabel.textColor = [UIColor colorWithRed:0.94 green:0.68 blue:0.72 alpha:1];
    roseLabel.adjustsFontSizeToFitWidth = YES;
    roseLabel.minimumScaleFactor = 0.75;
    [rosePlate addSubview:roseLabel];
    [stackView addArrangedSubview:rosePlate];
    [NSLayoutConstraint activateConstraints:@[
        [rosePlate.heightAnchor constraintEqualToConstant:42],
        [rosePlate.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor],
        [rosePlate.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor],
        [roseLabel.leadingAnchor constraintEqualToAnchor:rosePlate.leadingAnchor constant:12],
        [roseLabel.trailingAnchor constraintEqualToAnchor:rosePlate.trailingAnchor constant:-12],
        [roseLabel.centerYAnchor constraintEqualToAnchor:rosePlate.centerYAnchor]
    ]];

"""
replace("UI/DOMainViewController.m","    //Action Menu\n",plate+"    //Action Menu\n")
info=ROOT/"Info.plist"
s=info.read_text()
if "CFBundleDisplayName" not in s:
    info.write_text(s.replace("<dict>","<dict>\n    <key>CFBundleDisplayName</key>\n    <string>Dopamine Rose</string>",1))

print("ROSE_PATCH_OK: theme, icons, wordmark, wallpaper, status plate, controls")
