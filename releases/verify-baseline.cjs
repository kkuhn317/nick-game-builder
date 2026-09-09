const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const baseline=path.join(__dirname,'editor-music4');
const manifest=JSON.parse(fs.readFileSync(path.join(baseline,'manifest.json'),'utf8'));
for(const item of manifest.files){
 const file=path.resolve(root,item.path);
 assert.ok(file.startsWith(root+path.sep));
 const data=fs.readFileSync(file);
 assert.equal(data.length,item.bytes,item.path+' size');
 assert.equal(crypto.createHash('sha256').update(data).digest('hex'),item.sha256,item.path+' SHA-256');
}
console.log('PASS: '+manifest.files.length+' baseline files match their recorded hashes.');
