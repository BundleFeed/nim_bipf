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

var fs = require('fs')


// generate a large dataset of messages using ssb fixtures
const os = require('os');
const path = require('path');
const OffsetLog = require('flumelog-offset');
const codec = require('flumecodec');
const Flume = require('flumedb');
const rimraf = require('rimraf');
const pull = require('pull-stream');
const generate = require('ssb-fixtures');

generateUsingSSBFixture({outputDir: 'tests-js', authors:500, messages:80000}, (err, msgs, cleanup, outputDir) => {
    if (err) throw err;
    console.log('ssb-fixtures msgs length:', msgs.length)
    
    var f = fs.openSync('tests-js/test-bench-fixture.json', 'w')
    for (m in msgs) {
        
        var jsonLine = JSON.stringify(msgs[m]) + '\n'
        fs.writeSync(f, jsonLine)
    }
    fs.closeSync(f)

    console.log('ssb-fixtures size:', fs.statSync('tests-js/test-bench-fixture.json').size, "bytes/", Math.round(fs.statSync('tests-js/test-bench-fixture.json').size/1024/1024), "MB");
    cleanup();
});

function generateUsingSSBFixture(opts, cb) {
    const outputDir = fs.mkdtempSync(path.join(os.tmpdir(), opts.outputDir));
  
    generate({...opts, outputDir}).then(() => {
      console.log('ssb-fixtures outputDir:', outputDir)
      const logOffset = path.join(outputDir, 'flume', 'log.offset');
      const db = Flume(OffsetLog(logOffset, {codec: codec.json}));
  
      pull(
        db.stream({keys: true, values: true}),
        pull.collect((err, arr) => {
          function cleanup(cb) {
            rimraf.sync(outputDir);
            
          }
          const msgs = arr.map((x) => x.value);
          db.close(() => {
            cb(err, msgs, cleanup, outputDir);
          });
        }),
      );
    });
  }

