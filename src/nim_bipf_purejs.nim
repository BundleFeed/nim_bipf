# Copyright 2023 Geoffrey Picron
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import std/logging
import nim_bipf/private/bytebuffer
import nim_bipf/private/logging as tracing

var consoleLog = newConsoleLogger(levelThreshold=lvlAll)
addHandler(consoleLog)

import nim_bipf
import std/jsffi
import jsExport


when not(defined(js)):
    {.fatal "This module is only for the JavaScript target.".}


converter toNativeString*(s: JsObject): NativeString = 
  result = NativeString(cast[cstring](s))


func isUint8Array(s: JsObject): bool {.importjs: "(# instanceof Uint8Array)".}
func isArray(s: JsObject): bool {.importjs: "(Array.isArray(#))".}
func isSafeInteger(s: JsObject): bool {.importjs: "(Number.isSafeInteger(#))".}

when defined(nodejs):
  func toBuffer(s: ByteBuffer): JsObject {.importjs: "Buffer.from(#)"}
else:
  func toBuffer(s: ByteBuffer): JsObject {.importjs: "(#)"}

converter jsToByteBuffer*(s: JsObject): ByteBuffer = 
  assert jsTypeOf(s) == "object" and isUint8Array(s)
  result = cast[ByteBuffer](s)

converter toInt32*(s: JsObject): int32 = 
  assert jsTypeOf(s) == "number"
  result = cast[int32](s)
  assert result >= low(int32) and result <= high(int32)

converter toFloat64*(s: JsObject): float64 = 
  assert jsTypeOf(s) == "number"
  result = cast[float64](s)

converter toBool*(s: JsObject): bool =
  assert jsTypeOf(s) == "boolean"
  result = cast[bool](s)

template dispatcher1(prototype: JsObject, procName: untyped): untyped =  
  prototype.procName = bindMethod proc (this: BipfBuilder, arg0: sink JsObject) =
    var that = this
    if isUndefined(arg0):
      that.procName()
    else:
      that.procName(arg0)

template dispatcher2(prototype: JsObject, procName: untyped): untyped =  
  prototype.procName = bindMethod proc (this: BipfBuilder, arg0: sink JsObject, arg1: sink JsObject) =
    var that = this
    if isUndefined(arg1):
      that.procName(arg0)
    else:
      that.procName(arg0, arg1)

func newBipfBuilder(): BipfBuilder =
  result = BipfBuilder()
  var prototype = cast[JsObject](result)
  
  dispatcher1(prototype, startArray)
  prototype.endArray = bindMethod proc (this: BipfBuilder) =
    var that = this
    that.endArray()
  dispatcher1(prototype, startMap)
  prototype.endMap = bindMethod proc (this: BipfBuilder) =
    var that = this
    that.endMap()
  dispatcher1(prototype, addNull)
  dispatcher2(prototype, addString)
  dispatcher2(prototype, addInt)
  dispatcher2(prototype, addDouble)
  dispatcher2(prototype, addBool)
  dispatcher2(prototype, addBuffer)
  dispatcher2(prototype, addExtended)
  prototype.finish = bindMethod proc (this: BipfBuilder): BipfBuffer =
    var that = this
    result = that.finish()

proc serialize*(obj: JsObject): BipfBuffer  =
  var builder = newBipfBuilder()

  proc recursiveEncodeKeyed(builder: var BipfBuilder, key: sink cstring, obj: sink JsObject)

  proc recursiveEncode(builder: var BipfBuilder, obj: sink JsObject) =
    let jsType = jsTypeOf(obj)
    if jsType == "undefined":
      discard
    elif jsType == "boolean":
      builder.addBool(obj)
    elif jsType == "number":
      if obj.isSafeInteger() and obj >= cast[JsObject](low(int32)) and obj <= cast[JsObject](high(int32)):
        builder.addInt(obj)
      else:
        builder.addDouble(obj)
    elif jsType == "string":
      builder.addString(obj)
    elif jsType == "object":
      if isNull(obj):
        builder.addNull()
      elif isUint8Array(obj):
        builder.addBuffer(obj)
      elif isArray(obj):
        builder.startArray()
        for value in obj:
          recursiveEncode(builder, value)
        builder.endArray()
      else:
        builder.startMap()
        for key, value in pairs(obj):
          recursiveEncodeKeyed(builder, key, value)
        builder.endMap()
    else:
      raise newException(ValueError, "Unsupported type: " & $jsType)
  
  proc recursiveEncodeKeyed(builder: var BipfBuilder, key: sink cstring, obj: sink JsObject) =
    let jsType = jsTypeOf(obj)
    if jsType == "undefined":
      discard
    elif jsType == "boolean":
      builder.addBool(key, obj)
    elif jsType == "number":
      if obj.isSafeInteger() and obj >= cast[JsObject](low(int32)) and obj <= cast[JsObject](high(int32)):
        builder.addInt(key, obj)
      else:
        builder.addDouble(key, obj)
    elif jsType == "string":
      builder.addString(key, obj)
    elif jsType == "object":
      if isNull(obj):
        builder.addNull(key)
      elif isUint8Array(obj):
        builder.addBuffer(key, obj)
      elif isArray(obj):
        builder.startArray(key)
        for value in obj:
          recursiveEncode(builder, value)
        builder.endArray()
      else:
        builder.startMap(key)
        for key, value in pairs(obj):
          recursiveEncodeKeyed(builder, key, value)
        builder.endMap()
    else:
      raise newException(ValueError, "Unsupported type: " & $jsType)

  recursiveEncode(builder, obj)
  result = builder.finish()

import std/deques

type 
  DynObjectType = enum
    Null, Bool, Int, Double, String, Buffer, Array, Map, Extended

func type(obj: JsObject): DynObjectType =
  let jsType = jsTypeOf(obj)
  if jsType == "undefined":
    result = Null
  elif jsType == "boolean":
    result = Bool
  elif jsType == "number":
    if obj.isSafeInteger() and obj >= low(int32) and obj <= high(int32):
      result = Int
    else:
      result = Double
  elif jsType == "string":
    result = String
  elif jsType == "object":
    if isNull(obj):
      result = Null
    elif isUint8Array(obj):
      result = Buffer
    elif isArray(obj):
      result = Array
    else:
      result = Map
  else:
    raise newException(ValueError, "Unsupported type: " & $jsType)



## Backward compatibility with the bipf module

var lastObjectVisited: JsObject = nil
var lastBufferProduced: BipfBuffer

proc encodingLength(obj: JsObject): int  =
  lastBufferProduced = serialize(obj)
  lastObjectVisited = obj
  result = ByteBuffer(lastBufferProduced).len

func isNodeJsBuffer(buffer: ByteBuffer): bool {.importjs: "( typeof Buffer !== 'undefined' && Buffer.isBuffer(#) )".}

proc encode(obj: JsObject, buffer: ByteBuffer, offset: int = 0): int =
  if obj != lastObjectVisited:
    lastBufferProduced = serialize(obj)
    lastObjectVisited = obj

  if buffer.len - offset < ByteBuffer(lastBufferProduced).len and not isNodeJsBuffer(buffer):
    raise newException(ValueError, "Buffer too small")

  var p = offset
  buffer.writeBuffer(ByteBuffer(lastBufferProduced), p)
  result = p - offset


let jsTrue {.importjs: "true", nodecl.} : JsObject
let jsFalse {.importjs: "false", nodecl.} : JsObject

proc decodeNext(buffer: BipfBuffer, p: var int = 0): JsObject

proc decodeObject(buffer: BipfBuffer, p: var int, size: int): JsObject =
  result = newJsObject()
  let endOffset = p + size
  while p < endOffset:
    let keyPrefix = buffer.readVaruint32(p)
    let keySize = int(keyPrefix shr 3)
    let keyTag = BipfTag(keyPrefix and 7)

    assert keyTag == BipfTag.STRING

    let key = buffer.readUtf8(p, keySize)
    let value = decodeNext(buffer, p)
    result[key] = value

proc decodeArray(buffer: BipfBuffer, p: var int, size: int): seq[JsObject] =
  result = newSeq[JsObject]()
  let endOffset = p + size
  while p < endOffset:
    result.add decodeNext(buffer, p)

proc decodeNext(buffer: BipfBuffer, p: var int = 0): JsObject =
  let prefix = buffer.readVaruint32(p)
  let size = int(prefix shr 3)
  let tag = BipfTag(prefix and 7)

  trace "decode ", $tag, " size: ", size

  return case tag
          of BipfTag.OBJECT:
            decodeObject(buffer, p, size)
          of BipfTag.ARRAY:
            decodeArray(buffer, p, size).toJs
          of BipfTag.STRING:
            buffer.readUtf8(p, size).toJs
          of BipfTag.BUFFER:
            buffer.readBuffer(p, size).toBuffer
          of BipfTag.INT:
            buffer.readInt32LittleEndian(p).toJs
          of BipfTag.DOUBLE:
            buffer.readFloat64LittleEndian(p).toJs
          of BipfTag.BOOLNULL:
            if size == 0:
              jsNull
            else:
              let v = (buffer[p] == 1)
              inc(p)
              if v:
                jsTrue
              else:
                jsFalse
            
          of BipfTag.EXTENDED:
            buffer.readBuffer(p, size).toBuffer

proc decode(buffer: BipfBuffer, start: int = 0): JsObject =
  var p = start
  result = decodeNext(buffer, p)


proc seekKey(buffer: ByteBuffer, start: int, key: NativeString): int =
  trace "seekKey key: ", key, " from:", start
  var p = start
  let prefix = buffer.readVaruint32(p)
  let tag = BipfTag(prefix and 7)


  if tag != BipfTag.OBJECT: return -1

  let size = int(prefix shr 3)

  let endOffset = p + size

  while p < endOffset:
    let keyPrefix = buffer.readVaruint32(p)
    let keySize = int(keyPrefix shr 3)
    let keyTag = BipfTag(keyPrefix and 7)

    let keyName = buffer.readUtf8(p, keySize)
    if keyName == key:
      return p

    let valuePrefix = buffer.readVaruint32(p)
    let valueSize = int(valuePrefix shr 3)
    p += valueSize
  return -1

proc seekPath(buffer: ByteBuffer, start: int, target: ByteBuffer, targetStart: int = 0): int =
  var p = start
  let ary : JsObject = decode(target, targetStart)
  
  trace "seeking path: ", ary.repr

  for i in 0..<ary.length:
    let key = ary[i]
    trace "seeking key: ", $key.cstring
    p = seekKey(buffer, p, key.cstring.NativeString)
    if (p == -1): return -1
  
  return p


jsExport:
  serialize

  encodingLength
  encode
  decode
  seekPath
  "allocAndEncode" = serialize

