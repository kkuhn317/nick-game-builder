const fs=require('node:fs'),zlib=require('node:zlib'),assert=require('node:assert/strict');
const directory='gameBuilder110222/builder/medias/spongebob/gb_danimals/music';
const tracks=[];
for(const file of fs.readdirSync(directory).filter(f=>f.endsWith('.swf')).sort()) {
 const raw=fs.readFileSync(directory+'/'+file);
 if(file==='gs_sb_musicPack13New.swf') { assert.equal(raw.length,32); console.log(file+': excluded 32-byte placeholder'); continue; }
 const body=raw.toString('ascii',0,3)==='CWS'?zlib.inflateSync(raw.subarray(8)):raw.subarray(8);
 let pos=Math.ceil((5+4*(body[0]>>3))/8)+4,sounds=[],exports=[];
 while(pos+2<=body.length) {
  const h=body.readUInt16LE(pos);pos+=2;const type=h>>6;let len=h&63;
  if(len===63){len=body.readUInt32LE(pos);pos+=4;}
  const data=body.subarray(pos,pos+len);pos+=len;
  if(type===14)sounds.push({id:data.readUInt16LE(0),samples:data.readUInt32LE(3),bytes:len});
  if(type===76){let j=2;for(let i=0;i<data.readUInt16LE(0);i++){const id=data.readUInt16LE(j);j+=2;const end=data.indexOf(0,j);exports.push({id,name:data.toString('utf8',j,end)});j=end+1;}}
  if(type===0)break;
 }
 const music=exports.find(e=>e.name==='gameMusic');
 if(music){assert.ok(sounds.some(s=>s.id===music.id&&s.samples>0));tracks.push(file);}
 console.log(file+': '+(music?'gameMusic with embedded audio':'NO playable gameMusic export'));
}
assert.equal(tracks.length,13);
console.log('PASS: 13 archived tracks expose gameMusic backed by embedded sound.');
