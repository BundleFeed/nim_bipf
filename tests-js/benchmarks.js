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

var BenchTable = require('benchtable');
var faker = require('faker')
var nim_bipf = require('../')
var bipf = require('bipf')
var fs = require('fs')
var nim_bipf_node = require('../dist/nim_bipf_node.js')



const Benchmarkify = require("benchmarkify");

function getNonNested() {
    switch (faker.datatype.number(7)) {
        case 0:
            return Buffer.from(faker.random.words(faker.datatype.number(5) + 1))
        case 1:
            return faker.datatype.number(300)
        case 2:
            return faker.datatype.float()
        case 3:
            return faker.datatype.boolean()
        case 4:
            return null
        case 5:
            return null
        case 6:
        default:
            return faker.random.words(faker.datatype.number(5) + 1)
    }
}

function getRandomArray(level) {
    return new Array(faker.datatype.number(10) + 1).fill(1).map(function () {
        return buildStructure(level + 1)
    })
}

function buildStructure(level) {
    var selection
    if (level < 1) selection = faker.datatype.number(1)
    else if (level > 3) selection = 2
    else selection = faker.datatype.number(2)
    switch (selection) {
        case 0:
            return getRandomArray(level).reduce(function (agg, e) {
                agg[faker.random.word()] = e
                return agg
            }, {})
        case 1:
            return getRandomArray(level)
        default:
            return getNonNested()
    }
}


faker.seed(348230432)
console.log('Generating JSON structure...')
const genDate = new Date()
var fakeData = buildStructure(0)
console.log('Structure generated in ' + (new Date() - genDate) + 'ms')
const pkg = require('../package.json')

// loading ssb messsages from json lines file

var arjMessages = fs.readFileSync('tests-js/test-arj.json', 'utf8')
    .split('\n')
    .filter(line => line.trim().length > 0) 
    .map(line => JSON.parse(line))
    .filter(msg => msg != null)

console.log('arjMessages length:', arjMessages.length)

var celMessages = fs.readFileSync('tests-js/test-cel.json', 'utf8')
    .split('\n')
    .filter(line => line.trim().length > 0) 
    .map(line => JSON.parse(line))
    .filter(msg => msg != null)

console.log('celMessages length:', celMessages.length)

var andreMessages = fs.readFileSync('tests-js/test-andre.json', 'utf8')
    .split('\n')
    .filter(line => line.trim().length > 0) 
    .map(line => JSON.parse(line))
    .filter(msg => msg != null)

console.log('andreMessages length:', andreMessages.length)


var fixtureMessages = fs.readFileSync('tests-js/test-bench-fixture.json', 'utf8')
    .split('\n')
    .filter(line => line.trim().length > 0)
    .map(line => JSON.parse(line))
    .filter(msg => msg != null)

console.log('fixtureMessages length:', fixtureMessages.length)

var keyDict = nim_bipf.newKeyDict()


console.log('fixtureMessages (500 authors) of ' + fixtureMessages.length + ' messages')
var encodedSsbMessages = fixtureMessages.map(msg => bipf.allocAndEncode(msg))


var b = bipf.allocAndEncode(fakeData)
var json = JSON.stringify(fakeData)
var jsonBuffer = Buffer.from(json)

var arjMessagesEncoded = arjMessages.map(msg => bipf.allocAndEncode(msg))

var dataIndex = 0
while (false) {
    let j = dataIndex++ % arjMessagesEncoded.length
    bipf.decode(arjMessagesEncoded[j])
}


const tape = require('tape')
/*
tape('bipf#encode/decode', function (t) {
    var  encodeDecode = bipf.decode(bipf.allocAndEncode(fakeData))
    t.deepEqual(encodeDecode, fakeData)
    t.end()
})

tape('bipf#encode/nim_bipf#decode', function (t) {
    var  encodeDecode = nim_bipf.decode(bipf.allocAndEncode(fakeData))
    t.deepEqual(encodeDecode, fakeData)
    t.end()
})


tape('nim_bipf#encode/bipf#decode', function (t) {
    var  encodeDecode = bipf.decode(nim_bipf.allocAndEncode(fakeData))
    t.deepEqual(encodeDecode, fakeData)
    t.end()
})

tape('nim_bipf_node#encode/bipf#decode', function (t) {
    var  encodeDecode = bipf.decode(nim_bipf_node.serialize(fakeData))
    t.deepEqual(encodeDecode, fakeData)
    var  encodeDecode = bipf.decode(nim_bipf_node.serialize(arjMessages[0]))
    t.deepEqual(encodeDecode, arjMessages[0])

    t.end()
})

tape('bipf#encode/nim_bipf_node#decode', function (t) {
    var  encodeDecode = nim_bipf_node.deserialize(bipf.allocAndEncode(fakeData))
    t.deepEqual(encodeDecode, fakeData)
    t.end()
})


tape('bipf#encode(Json.parse(string))/nim_bipf_node#parseJson2Bipf(string)', function (t) {
    pkgString = JSON.stringify(fakeData)
    var  bipfFromNodeModule = nim_bipf_node.parseJson2Bipf(pkgString)
    var  jsOnly = bipf.allocAndEncode(JSON.parse(pkgString))
    t.deepEqual(bipf.decode(bipfFromNodeModule), bipf.decode(jsOnly))

    t.end()
})

tape('bipf#encode(Json.parse(string))/nim_bipf_node#parseJson2Bipf(buffer)', function (t) {
    pkgString = JSON.stringify(fakeData)
    pkgUTF8Buffer = Buffer.from(pkgString)
    var  bipfFromNodeModule = nim_bipf_node.parseJson2Bipf(pkgUTF8Buffer)
    var  jsOnly = bipf.allocAndEncode(JSON.parse(pkgString))
    t.deepEqual(bipf.decode(bipfFromNodeModule), bipf.decode(jsOnly))

    t.end()
})
*/


const bench = new Benchmarkify("Nim Bipf - JS Backend").printHeader();

var suites = []

let data = {}
//data["large data"] = [...Array(100).keys()].map(i => buildStructure(0)).filter(i => i != null)
//data["medium data"] = [...Array(100).keys()].map(i => buildStructure(1))
//data["small data (always same)"] = [pkg]
var ssbMessages = arjMessages.concat(celMessages).concat(andreMessages)
data["ssb messages from arj,cel,andre"] = ssbMessages
data["ssb messages from ssb-fixture"] = fixtureMessages

console.log('ssbMessages sample of ' + ssbMessages.length + ' messages')

function roughSizeOfObject( object ) {

    var objectList = [];

    var recurse = function( value )
    {
        var bytes = 0;

        if ( typeof value === 'boolean' ) {
            bytes = 4;
        }
        else if ( typeof value === 'string' ) {
            bytes = value.length * 2;
        }
        else if ( typeof value === 'number' ) {
            bytes = 8;
        }
        else if
        (
            typeof value === 'object'
            && objectList.indexOf( value ) === -1
        )
        {
            objectList[ objectList.length ] = value;

            for( i in value ) {
                bytes+= 8; // an assumed existence overhead
                bytes+= recurse( value[i] )
            }
        }

        return bytes;
    }

    return recurse( object );
}

var dataIndex = 0

for (let i in data) {
    let b = data[i]

    var suite = bench.createSuite("Encoding data " + i + "");
    suite.setup(function () {
        dataIndex = 0
    })
    suite.ref('bipf#encode/' + i, function () {
        let j = dataIndex++ % b.length
        bipf.allocAndEncode(b[j])
    })
    suite.add('nim_bipf#serialize/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.serialize(b[j])
    })
    suite.add('nim_bipf#serializeWithKeyDict/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.serialize(b[j], keyDict)
    })
    suite.add('nim_bipf_node#serialize/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf_node.serialize(b[j])
    })
    suite.add('json#stringify/' + i, function () {
        let j = dataIndex++ % b.length
        JSON.stringify(b[j])
    })
    suites.push(suite)
}





let bipfData = {}
for (let i in data) {
    bipfData[i] = data[i].map(e => nim_bipf.serialize(e))
}

let bipfDataWithKeyDict = {}
for (let i in data) {
    bipfDataWithKeyDict[i] = data[i].map(e => nim_bipf.serialize(e, keyDict))
}

let jsonStrings = {}
for (let i in data) {
    jsonStrings[i] = data[i].map(e => JSON.stringify(e))
}

let jsonBuffers = {}
for (let i in data) {
    jsonBuffers[i] = data[i].map(e => Buffer.from(JSON.stringify(e)))
}

for (let i in bipfData) {
    let b = bipfData[i]
    let bk = bipfDataWithKeyDict[i]
    let json = jsonStrings[i]
    let jb = jsonBuffers[i]


    var suite = bench.createSuite("Decoding data " + i + "");
    suite.setup(function () {
        dataIndex = 0
    })

    suite.ref('bipf#decode/' + i, function () {
        let j = dataIndex++ % b.length
        bipf.decode(b[j])
    })
    suite.add('nim_bipf#deserialize/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.deserialize(b[j])
    })
    suite.add('nim_bipf#deserializeWithKeyDict/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.deserialize(bk[j], keyDict)
    })
    suite.add('nim_bipf_node#deserialize/' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf_node.deserialize(b[j])
    })

    suite.add('json#parse(string)/' + i, function () {
        let j = dataIndex++ % b.length
        JSON.parse(json[j])
    })
    suite.add('json#parse(buffer)/' + i, function () {
        let j = dataIndex++ % b.length
        JSON.parse(jb[j].toString())
    })
    suites.push(suite)
}

for (let i in bipfData) {
    let b = bipfData[i]
    let json = jsonStrings[i]
    let jb = jsonBuffers[i]

    var suite = bench.createSuite("JSON 2 Bipf " + i + "");
    suite.setup(function () {
        dataIndex = 0
    })

    suite.ref('json#parse(string)/bipf#allocAndEncode' + i, function () {
        let j = dataIndex++ % b.length
        bipf.allocAndEncode(JSON.parse(json[j]))
    })

    suite.add('json#parse(buffer)/bipf#allocAndEncode' + i, function () {
        let j = dataIndex++ % b.length
        bipf.allocAndEncode(JSON.parse(jb[j].toString()))
    })

    suite.add('json#parse(string)/nim_bipf#serialize' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.serialize(JSON.parse(json[j]))
    })

    suite.add('json#parse(buffer)/nim_bipf#serialize' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf.serialize(JSON.parse(jb[j].toString()))
    })

    suite.add('nim_bipf_node#parseJson2Bipf(string)' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf_node.parseJson2Bipf(json[j])
    })

    suite.add('nim_bipf_node#parseJson2Bipf(buffer)' + i, function () {
        let j = dataIndex++ % b.length
        nim_bipf_node.parseJson2Bipf(jb[j])
    })

    suites.push(suite)
}




var b = bipf.allocAndEncode(pkg)
var _devDependenciesBuf = Buffer.from('devDependencies')
var _fakerBuf = Buffer.from('faker')
var _devDependencies = nim_bipf.serialize('devDependencies')
var _faker = nim_bipf.serialize('faker')


var suite2 = bench.createSuite("Seeking data");
suite2.ref('bipf#seekPathBy2SeekKey(string)', function () {
    bipf.seekKey(b, bipf.seekKey(b, 0, 'devDependencies'), 'faker')
})
suite2.add('bipf#seekPathBy2SeekKey(buffer)', function () {
    bipf.seekKey(b, bipf.seekKey(b, 0, _devDependenciesBuf), _fakerBuf)
})
suite2.add('bipf#seekPathBy2SeekKey2', function () {
    bipf.seekKey2(b, bipf.seekKey2(b, 0, _devDependencies), _faker)
})
suite2.add('bipf#seekPathBy2SeekKeyCached', function () {
    bipf.seekKeyCached(b, bipf.seekKeyCached(b, 0, 'devDependencies'), 'faker')
})
suite2.add('nim_bipf#seekPathBy2SeekKey(string)', function () {
    nim_bipf.seekKey(b, nim_bipf.seekKey(b, 0, 'devDependencies'), 'faker')
})
suite2.add('nim_bipf#seekPathBy2SeekKey(buffer)', function () {
    nim_bipf.seekKey(b, nim_bipf.seekKey(b, 0, _devDependenciesBuf), _fakerBuf)
})
suite2.add('nim_bipf#seekPathBy2SeekKey2', function () {
    nim_bipf.seekKey2(b, nim_bipf.seekKey2(b, 0, _devDependencies), _faker)
})
suite2.add('nim_bipf#seekPathBy2SeekKeyCached', function () {
    nim_bipf.seekKeyCached(b, nim_bipf.seekKeyCached(b, 0, 'devDependencies'), 'faker')
})
    
//suites.push(suite2)


var encodedPath = nim_bipf.serialize(['devDependencies', 'faker'])

var suite3 = bench.createSuite("Seeking path");
var x = 0

suite3.ref('bipf#seekPath(encoded)', function () {
    x += bipf.seekPath(b, 0, encodedPath, 0)
})

var compiled = bipf.createSeekPath(['devDependencies', 'faker'])

suite3.add('bipf#seekPath(compiled)', function () {
    x += compiled(b, 0)
})

suite3.add('nim_bipf#seekPath(encoded)', function () {
    x += nim_bipf.seekPath(b, 0, encodedPath, 0)
})

var compiledNim = nim_bipf.createSeekPath(['devDependencies', 'faker'])

suite3.add('nim_bipf#seekPath(compiled)', function () {
    x += compiledNim(b, 0)
})

var pPath = nim_bipf_node.compileSimpleBPath(['devDependencies', 'faker'])

suite3.add('nim_bipf_node#seekPath(compiled)', function () {
    x += nim_bipf_node.runBPath(b, pPath, 0)
})

suites.push(suite3)

var suite4 = bench.createSuite("Scanning in memory db (first 100 message of type 'contact')");

suite4.ref('bipf#jsArray[js objects]/scan and match', function () {
    var count = 0
    var result = []
    var i = 0
    while (count < 100 && i < encodedSsbMessages.length) {
        if (ssbMessages[i].value.content.type === 'contact') {
            count++
            result.push(ssbMessages[i])
        }
        i++
    }
})


var compiled = bipf.createSeekPath(['value', 'content', 'type'])
var contactInBipf = bipf.allocAndEncode('contact')

suite4.add('bipf#jsArray[bipf]/seekPath(compiled)', function () {
    var count = 0
    var result = []
    var i = 0
    while (count < 100 && i < encodedSsbMessages.length) {
        var p = compiled(encodedSsbMessages[i], 0)
        if (p != -1) {
            var match = contactInBipf.compare(encodedSsbMessages[i], p, p + contactInBipf.length) === 0    
            if (match) {
                count++
                result.push(encodedSsbMessages[i])
            }
        }
        i++
    }
})



var compiledNim = nim_bipf.createSeekPath(['value', 'content', 'type'])

suite4.add('nim_bipf#jsArray[bipf]/seekPath(compiled)', function () {
    var count = 0
    var result = []
    var i = 0
    while (count < 100 && i < encodedSsbMessages.length) {
        var p = compiledNim(encodedSsbMessages[i], 0)
        if (p != -1) {
            var match = contactInBipf.compare(encodedSsbMessages[i], p, p + contactInBipf.length) === 0    
            if (match) {
                count++
                result.push(encodedSsbMessages[i])
            }
        }
        i++
    }
    //console.log(result.length)
})

var pPath = nim_bipf_node.compileSimpleBPath(['devDependencies', 'faker'])


suite4.add('nim_bipf_node#jsArray[bipf]/seekPath(compiled)', function () {
    var count = 0
    var result = []
    var i = 0
    while (count < 100 && i < encodedSsbMessages.length) {
        var p = nim_bipf_node.runBPath(encodedSsbMessages[i], pPath, 0)
        if (p != -1) {
            var match = contactInBipf.compare(encodedSsbMessages[i], p, p + contactInBipf.length) === 0    
            if (match) {
                count++
                result.push(encodedSsbMessages[i])
            }
        }
        i++
    }
})

nim_bipf_node.loadDB(encodedSsbMessages)

suite4.add('nim_bipf_node#inModuleMemory', function () {
    nim_bipf_node.searchContacts()
})

suites.push(suite4)





bench.run(suites)
