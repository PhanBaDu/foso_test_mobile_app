// Requires @resvg/resvg-js (npm install --prefix /tmp/foso-tab-icons @resvg/resvg-js).
// NODE_PATH=/tmp/foso-tab-icons/node_modules node tools/export_tabbar_icons.cjs
// Then run python3 tools/sync_ios_resources.py to update native image sets.
const { Resvg } = require('@resvg/resvg-js');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const source = path.join(root, 'assets/icons/tabbar');
for (const file of fs.readdirSync(source).filter(file => file.endsWith('.svg'))) {
  const svg = fs.readFileSync(path.join(source, file));
  const name = 'ic_tab_' + path.basename(file, '.svg').replaceAll('-', '_');
  for (const scale of [1, 2, 3]) {
    const folder = path.join(root, 'assets/images', scale === 1 ? '' : `${scale}.0x`);
    fs.mkdirSync(folder, { recursive: true });
    const image = new Resvg(svg, { fitTo: { mode: 'width', value: 24 * scale } }).render();
    fs.writeFileSync(path.join(folder, name + '.png'), image.asPng());
  }
}
// Header icons share the same density export and native sync pipeline.
for (const group of ['header', 'common']) {
const header = path.join(root, 'assets/icons', group);
for (const file of fs.readdirSync(header).filter(file => file.endsWith('.svg'))) {
  const svg = fs.readFileSync(path.join(header, file));
  for (const scale of [1, 2, 3]) {
    const folder = path.join(root, 'assets/images', scale === 1 ? '' : `${scale}.0x`);
    fs.mkdirSync(folder, { recursive: true });
    const size = file === 'notification.svg' ? 40 : 24;
    const image = new Resvg(svg, { fitTo: { mode: 'width', value: size * scale } }).render();
    fs.writeFileSync(path.join(folder, 'ic_' + path.basename(file, '.svg') + '.png'), image.asPng());
  }
}
}
