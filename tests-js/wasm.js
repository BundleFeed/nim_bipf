// Copyright 2023 Geoffrey Picron
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.




const { randomInt } = require('crypto');
const factory = require('../dist/nim_bipf_wasm_wrapper.js') 
const pkg = require('../package.json')

factory().then(instance => {

console.log('module:' + typeof instance);

for (var key in instance) {
    console.log(key);
}


var total = 0
var refs = []
function dumpMemory(i) {
    if (i % 100000 == 0) {
        console.log("------------------")
        console.log(`i : ${i}`);
        console.log(`Processed : ${Math.round(total / 1024 / 1024 * 100) / 100} MB`);
        const used = process.memoryUsage();
        for (let key in used) {
            console.log(`${key} : ${Math.round(used[key] / 1024 / 1024 * 100) / 100} MB`);
        }
        instance.dumpHeap();
        global.gc()
        console.log("   after GC")
        const used2 = process.memoryUsage();
        for (let key in used2) {
            console.log(`${key} : ${Math.round(used2[key] / 1024 / 1024 * 100) / 100} MB`);
        }
        instance.dumpHeap();
    }
}

const runs = 100000

for (var i = 0; i < runs; i++) {
    var b = instance.parseJson2Bipf(JSON.stringify(pkg));
    refs.push(b);
    refs.push(b.data());
    total += b.len();
    dumpMemory(i);
}

global.gc();

var buffers= [];
total = 0
const v8 =require('v8');

v8.writeHeapSnapshot('wasm.heapsnapshot');
dumpMemory(0);

setInterval(() => {
    dumpMemory(0);
    
    refs = [];
}, 5 * 1000);
/*
for (var i = 0; i < runs; i++) {
    var buffer = Buffer.from(JSON.stringify(pkg));
    var wasmBuffer = instance.loadBuffer(buffer);
    buffers.push(wasmBuffer);
    var b = instance.parseJson2Bipf(wasmBuffer);
    
    total += b.data().length;
    dumpMemory(i);
}

global.gc();

for (var i = 0; i < runs; i++) {
    var wasmBuffer = buffers[i]
    var b = instance.parseJson2Bipf(wasmBuffer);
    
    total += b.data().length;
    dumpMemory(i);
}
*/
});
