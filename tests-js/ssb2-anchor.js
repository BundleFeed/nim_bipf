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

// 1 link to previous anchor (32 bytes)
// 1 identity id (32 bytes) (but you store it only once)
// 1 previous link per tip message (32 bytes) (generally only one, there is more only if there was a fork in the same device which is not supposed to happen)
// 1 signature (32 bytes)
// 1 timestamp (8 bytes)
// 1 author pu key (32 bytes but you don't have to store it for all anchors)

var fs = require('fs')
var bipf = require('bipf')


var feeds = {
    "arj": 'tests-js/test-arj.json',
    "cel": 'tests-js/test-cel.json',
    "andre": 'tests-js/test-andre.json'
}

var feedInJsObjects = {}
var feedInBipf = {}
var anchorsInBipf = {}

for (key in feeds) {
    var feedFile = feeds[key]

    console.log('----------------------------------------')
    console.log('feed dump:', feedFile)

    var messages = fs.readFileSync(feedFile, 'utf8')
        .split('\n')
        .filter(line => line.trim().length > 0) 
        .map(line => JSON.parse(line))
        .filter(msg => msg != null)

    feedInJsObjects[key] = messages

    console.log('feed Messages length:', messages.length)

    var size = roughSizeOfObject(messages)
    console.log('size for Array of JS objects :', size, "bytes/", Math.round(size/1024), "KB/", Math.round(size/1024/1024), "MB")
    console.log(" average message size as JS Object:", size/messages.length, " bytes")

    var encodedArrayOfBipf = messages.map(msg => bipf.allocAndEncode(msg))

    var sizeBipf = roughSizeOfObject(encodedArrayOfBipf)
    console.log('size for Array of BIPF :', sizeBipf, "bytes/", Math.round(sizeBipf/1024), "KB/", Math.round(sizeBipf/1024/1024), "MB")
    console.log(" average message size as BIPF:", sizeBipf/messages.length, " bytes")

    console.log('ratio BIPF/JS:', Math.round(sizeBipf/size * 100), "%")

    var encodedAsBipfArray = bipf.allocAndEncode(messages)
    feedInBipf[key] = encodedAsBipfArray
    var sizeBipfArray = roughSizeOfObject(encodedAsBipfArray)
    console.log('size for BIPF Array :', sizeBipfArray, "bytes/", Math.round(sizeBipfArray/1024), "KB/", Math.round(sizeBipfArray/1024/1024), "MB")
    console.log(" average message size as BIPF Array:", sizeBipfArray/messages.length, " bytes")

    console.log('ratio BIPF Array/JS:', Math.round(sizeBipfArray/size * 100), "%")
}

console.log('----------------------------------------')

console.log('Inserting anchors with the following rules:')
console.log(' - 1 anchor when size of messages since last anchor is > 500 KB in BIPF')
console.log(' - 1 anchor when duration since last anchor is > 3 months')

for (key in feeds) {
    var messages = feedInJsObjects[key]
    var encodedArrayOfBipf = feedInBipf[key]

    var anchors = []
    var lastAnchor = null

    var sizeSinceLastAnchor = 0
    var timestampLastAnchor = 0

    for (var i = 0; i < messages.length; i++) {
        var msg = messages[i]
        var msgBipf = encodedArrayOfBipf[i]

        var size = msgBipf.byteLength
        sizeSinceLastAnchor += size

        var timestamp = msg.value.timestamp

        if (timestamp - timestampLastAnchor > 3 * 30 * 24 * 60 * 60 * 1000 || sizeSinceLastAnchor > 500 * 1024) {
            var naiveAnchor = {
                "previous": lastAnchor == null ? null : Buffer.alloc(32),
                "identity": Buffer.alloc(32),
                "previous_tip": [Buffer.alloc(32)],
                "signature": Buffer.alloc(32),
                "timestamp": timestamp,
                "author": Buffer.alloc(32)
            }
            timestampLastAnchor = timestamp
            sizeSinceLastAnchor = bipf.allocAndEncode(naiveAnchor).byteLength

            anchors.push(naiveAnchor)
        }
    }

    console.log('----------------------------------------')
    console.log('feed anchors for ', key)
    console.log('anchors :', anchors.length)
    var feedAnchor = {
        "identity": Buffer.alloc(32),
        "anchors": anchors.
            reverse(). // it is more interesting to have the oldest anchors first
            map(anchor => {
                // keep only the non redundant fields
                var optimized = {
                    "previous": anchor.previous == null ? null : Buffer.alloc(32),
                    // no need to store it: "identity": Buffer.alloc(32),
                    "previous_tip": [Buffer.alloc(32)],
                    "signature": Buffer.alloc(32),
                    "timestamp": anchor.timestamp,
                    "author": Buffer.alloc(32)
                }
                return optimized
            })
    }

    var anchorArray = bipf.allocAndEncode(feedAnchor)
    anchorsInBipf[key] = anchorArray
    console.log('size for Array of anchors :', anchorArray.byteLength, "bytes/", Math.round(anchorArray.byteLength/1024), "KB/", Math.round(anchorArray.byteLength/1024/1024), "MB")
}


console.log('----------------------------------------')

console.log('')

console.log('Worst case scenario: using the arj feed as a reference * 500 users')
console.log('----------------------------------------')

var arjFeed = feedInJsObjects['arj']
var arjFeedBipf = feedInBipf['arj']
var arjAnchors = anchorsInBipf['arj']

var sizeOfFeedFor500Users = roughSizeOfObject(arjFeedBipf) * 500
var sizeOfFeedInJSFor500Users = roughSizeOfObject(arjFeed) * 500
var sizeOfAnchorsFor500Users = roughSizeOfObject(arjAnchors) * 500

console.log('size of feed in BIPF (default) for 500 followed :', sizeOfFeedFor500Users, "bytes/", Math.round(sizeOfFeedFor500Users/1024), "KB/", Math.round(sizeOfFeedFor500Users/1024/1024), "MB")
console.log('size of feed in JS for 500 followed :', sizeOfFeedInJSFor500Users, "bytes/", Math.round(sizeOfFeedInJSFor500Users/1024), "KB/", Math.round(sizeOfFeedInJSFor500Users/1024/1024), "MB")
console.log('size of anchors for 500 followed :', sizeOfAnchorsFor500Users, "bytes/", Math.round(sizeOfAnchorsFor500Users/1024), "KB/", Math.round(sizeOfAnchorsFor500Users/1024/1024), "MB")

estimationOfSizeAfterTruncation(12)
estimationOfSizeAfterTruncation(24)

function estimationOfSizeAfterTruncation(months) {
    console.log('')

    console.log('If only keeping last '+ months +' months of messages based on anchors:')
    
    var anchors = bipf.decode(arjAnchors)
    
    // find the first anchor that is older than 'months' months
    var firstAnchor = null
    for (var i = 0; i < anchors.anchors.length; i++) {
        var anchor = anchors.anchors[i]
        if (anchor.timestamp < Date.now() - months * 30 * 24 * 60 * 60 * 1000) {
            firstAnchor = anchor
            break
        }
    }
    
    // keep only the messages that are after the first anchor
    var messagesSinceFirstAnchor = arjFeed.filter(msg => msg.value.timestamp > firstAnchor.timestamp)
    console.log(' - number of messages since first anchor older than '+months+' months:', messagesSinceFirstAnchor.length)
    var sizeOfMessagesSinceFirstAnchor = roughSizeOfObject(messagesSinceFirstAnchor)
    var messagesSinceFirstAnchorBipf = messagesSinceFirstAnchor.map(msg => bipf.allocAndEncode(msg))
    
    var sizeOfMessagesSinceFirstAnchorInBipf = roughSizeOfObject(messagesSinceFirstAnchorBipf)
    console.log(' - size of messages since first anchor:', sizeOfMessagesSinceFirstAnchor, "bytes/", Math.round(sizeOfMessagesSinceFirstAnchor/1024), "KB/", Math.round(sizeOfMessagesSinceFirstAnchor/1024/1024), "MB")
    
    console.log('')
    console.log(' projection for 500 followed users:')
    console.log(' - size of messages since first anchor in BIPF:', sizeOfMessagesSinceFirstAnchorInBipf * 500, "bytes/", Math.round(sizeOfMessagesSinceFirstAnchorInBipf * 500/1024), "KB/", Math.round(sizeOfMessagesSinceFirstAnchorInBipf * 500/1024/1024), "MB")
    console.log(' - size of messages since first anchor in JS:', sizeOfMessagesSinceFirstAnchor * 500, "bytes/", Math.round(sizeOfMessagesSinceFirstAnchor * 500/1024), "KB/", Math.round(sizeOfMessagesSinceFirstAnchor * 500/1024/1024), "MB")
    
    
}



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

            bytes+= 8; // an assumed existence overhead for referencing the object
            if (Buffer.isBuffer(value)) {
                bytes += value.byteLength
            } else {
                for( i in value ) {
                    bytes+= recurse( value[i] )
                }    
            }
        }

        return bytes;
    }

    return recurse( object );
}

