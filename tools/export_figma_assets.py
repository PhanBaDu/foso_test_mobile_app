import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    'home': ROOT / 'design/figma/Home@3x.png',
    'category': ROOT / 'design/figma/Category@3x.png',
}
images = {name: Image.open(path).convert('RGBA') for name, path in SOURCES.items()}
assert images['home'].size == (1179, 9192)
assert images['category'].size == (1179, 2925)
output = ROOT / 'assets/images'
(output / '3.0x').mkdir(parents=True, exist_ok=True)
manifest = []

def save(name, source, bounds, background=None, foreground=None):
    image = images[source].crop(tuple(round(v * 3) for v in bounds))
    if background is not None:
        pixels = image.load()
        for y in range(image.height):
            for x in range(image.width):
                p = pixels[x, y][:3]
                if foreground is not None:
                    delta = [foreground[i] - background[i] for i in range(3)]
                    alpha = max(0, min(1, sum((p[i] - background[i]) * delta[i] for i in range(3)) / sum(v*v for v in delta)))
                    if name == 'ic_cart' and p[0] > p[1] + 20:
                        alpha = 0
                    pixels[x, y] = (*foreground, round(alpha * 255))
                elif max(abs(p[i] - background[i]) for i in range(3)) <= 2:
                    pixels[x, y] = (*p, 0)
    image.save(output / '3.0x' / f'{name}.png')
    image.resize((round(bounds[2]-bounds[0]), round(bounds[3]-bounds[1])), Image.Resampling.LANCZOS).save(output / f'{name}.png')
    manifest.append({'asset': name, 'source': str(SOURCES[source].relative_to(ROOT)), 'bounds_at_1x': bounds, 'export_scale': 3, 'pixels_3x': image.size})

home = {
    'welcome_banner': (12,127,381,192), 'offer_banner': (12,401,381,571),
    'product': (20,682,152,798), 'promo_red': (13,1585,191,1715),
    'promo_yellow': (13,1726,191,1855), 'promo_blue': (202,1585,380,1855),
    'recommend_banner': (12,1916,162,2207),
    'article_0': (16,2657,136,2738), 'article_1': (16,2761,136,2842),
    'article_2': (16,2865,136,2946), 'category_air': (25,264,78,305),
    'category_oil': (108,264,162,305), 'category_fuel': (190,264,246,305),
    'category_cabin': (272,264,327,305),
}
for name, bounds in home.items():
    save(name, 'home', bounds)
for i in range(10):
    x, y = 12 + (i % 5) * 75, 1069 + (i // 5) * 61
    save(f'brand_{i}', 'home', (x,y,x+69,y+53))
for i, bounds in enumerate([(102,215,174,285),(207,215,278,285),(310,215,381,285),(102,350,174,420),(207,350,278,420),(310,350,381,420),(102,455,174,525),(207,455,278,525),(310,455,381,525)]):
    save(f'filter_{i}', 'category', bounds)

white, blue, grey = (255,255,255), (2,95,202), (196,205,213)
for name, bounds, foreground in [
    ('home',(33,2978,58,3003),(3,122,255)),
    ('cart',(108,2978,134,3003),grey),
    ('category',(184,2978,209,3003),grey),
    ('news',(260,2978,285,3003),grey),
    ('account',(335,2978,360,3003),grey),
]:
    save(f'ic_{name}', 'home', bounds, white, foreground)
save('ic_search','home',(24,62,44,82),white,(145,158,171))
save('ic_camera','home',(295,60,320,83),white,(0,61,128))
save('ic_notification','home',(347,54,377,85),blue)
save('ic_back','category',(20,59,38,83),blue,white)
save('ic_right','category',(365,127,381,143),(247,249,250),(28,37,46))
save('ic_chevrons','home',(369,1212,381,1225),(247,249,250),(2,95,202))
for name, bounds in {
    'brand':(12,1032,36,1056), 'bestseller':(12,1203,36,1227),
    'recommend':(12,1877,36,1901), 'new_arrivals':(12,2240,36,2264),
    'article':(12,2606,36,2630), 'flash':(12,619,36,643),
    'fire':(92,917,110,937),
}.items():
    bg = blue if name == 'new_arrivals' else (247,249,250) if name not in ['flash','fire'] else white if name == 'fire' else None
    save(f'ic_{name}', 'home', bounds, bg)
(ROOT / 'design/figma/asset_manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
print(f'Exported {len(manifest)} assets at original 3× density; no upscaling.')
