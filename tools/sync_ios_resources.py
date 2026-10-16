"""Generate native resources from the same canonical assets Flutter consumes."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
resources = root / 'ios/Runner/NativeResources'
images = root / 'ios/Runner/Assets.xcassets/Figma'

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists() or path.read_bytes() != data:
        path.write_bytes(data)

for source in sorted((root / 'assets/images').glob('*.png')):
    folder = images / (source.stem + '.imageset')
    entries = []
    for scale, source_path in [('1x', source), ('3x', source.parent / '3.0x' / source.name)]:
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        name = f'{source.stem}@{scale}.png'
        write(folder / name, source_path.read_bytes())
        entries.append({'idiom': 'universal', 'filename': name, 'scale': scale})
    two_x = source.parent / '2.0x' / source.name
    if two_x.exists():
        name = f'{source.stem}@2x.png'
        write(folder / name, two_x.read_bytes())
        entries.append({'idiom': 'universal', 'filename': name, 'scale': '2x'})
    write(folder / 'Contents.json', json.dumps({'images': entries, 'info': {'author': 'xcode', 'version': 1}}, indent=2).encode())
write(images / 'Contents.json', b'{"info":{"author":"xcode","version":1}}\n')
write(resources / 'catalog.json', (root / 'assets/data/catalog.json').read_bytes())
for font in (root / 'assets/fonts').iterdir():
    if font.is_file():
        write(resources / 'fonts' / font.name, font.read_bytes())

for animation in (root / 'assets/animations').glob('*.json'):
    write(resources / 'animations' / animation.name, animation.read_bytes())
