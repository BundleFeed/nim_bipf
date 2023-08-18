# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/logging

var consoleLog = newConsoleLogger(levelThreshold=lvlAll)
addHandler(consoleLog)


import unittest

import nim_bipf/private/backend/c


import nim_bipf/common
import nim_bipf/builder
import nim_bipf/serde_json

import std/json
import stew/byteutils


let fixtures = parseFile("tests/spec-fixtures.json")

type
  Fixture = object
    name: string
    jsonHexString: string
    json: JsonNode
    binary: seq[byte]

var tests = newSeqOfCap[Fixture](fixtures.elems.len)

proc toString(bytes: openarray[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

for e in fixtures.elems:
  when defined(tinySSB):
    if not (e{"tinySSB"}.getBool(true)):
      continue
  else:
    if e{"tinySSB"}.getBool(false):
      continue
  tests.add(Fixture(
    name: e["name"].str,
    jsonHexString: e["json"].str,
    json: parseJson(toString(hexToSeqByte(e["json"].str))),
    binary: hexToSeqByte(e["binary"].str)
  ))




suite "BIPF":
  test "encode fixtures":
    for fixture in tests:
        debug "encoding fixture: ", fixture.name
        var builder = newBipfBuilder[NimContext](DEFAULT_CONTEXT)
        check builder != nil

        builder.addJsonNode(fixture.json)

        var encoded = builder.finish()
        
        let len = encoded.len

        let bb = cast[seq[byte]]((encoded.buffer))

        check len == fixture.binary.len              
        check bb == fixture.binary
        check toHex(bb) == toHex(fixture.binary)

  test "decode fixtures":
    for fixture in tests:
        debug "decoding fixture: ", fixture.name

        let json = deserializeToJsonNode(BipfBuffer[seq[byte]](buffer: fixture.binary))

        check json == fixture.json

  test "atom demo":
    var builder = newBipfBuilder[NimContext](DEFAULT_CONTEXT)
    check builder != nil

    builder.startMap()
    builder.addString("key1", "Foo")
    builder.addString("key2", "Bar")
    builder.endMap()

    var encoded = builder.finish()


    debug "encoded without keyDict: ", encoded.repr
    debug "length: ", encoded.len

    var builder2 = newBipfBuilder[NimContext](DEFAULT_CONTEXT)
    check builder2 != nil

    builder2.startMap()
    builder2.addString(AtomValue(3), "Foo")
    builder2.addString(AtomValue(4), "Bar")
    builder2.endMap()

    var encoded2 = builder2.finish()

    debug "encoded using a keyDict: ", encoded2.repr
    debug "length: ", encoded2.len

