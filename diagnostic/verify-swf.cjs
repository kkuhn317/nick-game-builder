const fs = require('node:fs');
const zlib = require('node:zlib');
const assert = require('node:assert/strict');
const path = require('node:path');
const root = path.resolve(__dirname, '..');

function parse(file) {
  const raw = fs.readFileSync(path.join(root, file));
  assert.equal(raw.toString('ascii', 0, 3), 'CWS');
  const body = zlib.inflateSync(raw.subarray(8));
  assert.equal(body.length + 8, raw.readUInt32LE(4));
  const headerLength = Math.ceil((5 + 4 * (body[0] >> 3)) / 8) + 4;
  let offset = headerLength;
  const tags = [];
  while (offset + 2 <= body.length) {
    const header = body.readUInt16LE(offset);
    offset += 2;
    const type = header >> 6;
    let length = header & 63;
    if (length === 63) { length = body.readUInt32LE(offset); offset += 4; }
    assert.ok(offset + length <= body.length);
    const data = body.subarray(offset, offset + length);
    offset += length;
    tags.push({ type, data });
    if (type === 0) break;
  }
  return { header: body.subarray(0, headerLength), tags };
}

const original = parse('BuilderMain unmodified.swf');
const diagnostic = parse('BuilderMain-diagnostic.swf');
assert.deepEqual(diagnostic.header, original.header);
assert.equal(diagnostic.tags.length, original.tags.length);
let changes = 0;
const expected = new Map([
  ['BuilderMain', 'DIAGNOSTIC BUILD v3'],
  ['ui.screens.LoadedScreen', 'All four loading stages completed; starting application.'],
  ['services.ProxyManager', 'ProxyModule downloaded; checking root.proxy.']
]);
original.tags.forEach((tag, i) => {
  const updated = diagnostic.tags[i];
  assert.equal(updated.type, tag.type);
  if (!updated.data.equals(tag.data)) {
    assert.equal(tag.type, 82, 'Only ActionScript bytecode may change');
    const name = tag.data.toString('utf8', 4, tag.data.indexOf(0, 4));
    const normalized = name.replaceAll('/', '.');
    assert.ok(expected.has(normalized), 'Unexpected changed script: ' + name);
    assert.ok(updated.data.includes(Buffer.from(expected.get(normalized))));
    expected.delete(normalized);
    changes++;
  }
});
assert.equal(changes, 3, 'Exactly three script blocks must change');
assert.equal(expected.size, 0);
console.log('PASS: BuilderMain, LoadedScreen and ProxyManager changed; stage header and all other tags preserved.');
