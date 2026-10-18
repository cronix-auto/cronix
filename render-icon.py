"""Rasterize the app's code-defined flat eye for the launcher asset catalog."""
from PIL import Image, ImageDraw

size = 1024
image = Image.new('RGB', (size, size), (232, 233, 236))
draw = ImageDraw.Draw(image)

def point(x, y):
    return (150 + x * 724 / 160, 275 + y * 453 / 100)

def curve(start, control1, control2, end):
    points = []
    for step in range(41):
        t = step / 40
        x = (1-t)**3*start[0] + 3*(1-t)**2*t*control1[0] + 3*(1-t)*t*t*control2[0] + t**3*end[0]
        y = (1-t)**3*start[1] + 3*(1-t)**2*t*control1[1] + 3*(1-t)*t*t*control2[1] + t**3*end[1]
        points.append(point(x, y))
    return points

ink = (41, 41, 41)
background = (232, 233, 236)
draw.polygon(curve((7,74),(49,27),(95,20),(151,31)) + curve((151,31),(107,95),(56,96),(7,74)), fill=ink)
draw.polygon(curve((27,69),(65,43),(100,34),(132,43)) + curve((132,43),(100,80),(66,87),(27,69)), fill=background)
draw.polygon(curve((83,40),(94,50),(90,67),(81,79)) + curve((81,79),(73,64),(74,51),(83,40)), fill=ink)
draw.polygon([point(*p) for p in [(10,62),(48,20),(43,34),(85,9),(76,23),(129,5),(115,21),(153,17)]] + curve((153,17),(116,34),(64,25),(10,62)), fill=ink)
image.save('CronixIcon.png')
