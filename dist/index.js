const addon = require("bindings")("nim_bipf");
addon.hello("George");


var r = addon.serialize(["George"]);

console.log(r);

var d = addon.deserialize(r);
console.log(d);

exports.serialize = addon.serialize
exports.deserialize = addon.deserialize
exports.parseJson2Bipf = addon.parseJson2Bipf
exports.compileSimpleBPath = addon.compileSimpleBPath
exports.runBPath = addon.runBPath

exports.loadDB = addon.loadDB
exports.searchContacts = addon.searchContacts