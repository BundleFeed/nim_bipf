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

import nim_bipf

import std/json
import stew/byteutils
import std/strutils

let fixtures = parseFile("tests/spec-fixtures.json")

type
  Fixture = object
    name: string
    json: JsonNode
    binary: seq[byte]

var tests = newSeqOfCap[Fixture](fixtures.elems.len)

proc toString(bytes: openarray[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

for e in fixtures.elems:
  tests.add(Fixture(
    name: e["name"].str,
    json: parseJson(toString(hexToSeqByte(e["json"].str))),
    binary: hexToSeqByte(e["binary"].str)
  ))


suite "BIPF":
  test "encode fixtures":
    for fixture in tests:
      var builder = newBipfBuilder()
      check builder != nil

      echo $fixture.json

      builder.addJson(fixture.json)
      
      let encoded = builder.finish()

      
      
      check encoded.len == fixture.binary.len
      check toBin((encoded[0]).int64, 8) == toBin(fixture.binary[0].int64, 8)
      check seq[byte](encoded) == fixture.binary

