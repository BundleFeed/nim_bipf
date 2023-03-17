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

var consoleLog = newConsoleLogger(levelThreshold=lvlWarn)
addHandler(consoleLog)

import nim_bipf
import std/jsffi
import jsExport

when not(defined(js)):
    {.fatal "This module is only for the JavaScript target.".}


converter jsToUTF8String*(s: JsObject): Utf8String = 
  assert jsTypeOf(s) == "string", "Expected a string, got " & $jsTypeOf(s)
  result = cast[cstring](s).toUTF8String

converter jsToUTF8String*(s: cstring): Utf8String = 
  result = s.toUTF8String

var internedUtf8Strings = newJsAssoc[cstring, Utf8String]()

proc jsToUTF8StringInterned(s: cstring): Utf8String =
  result = internedUtf8Strings[s]
  if isUndefined(result):
    result = s.toUTF8String()
    internedUtf8Strings[s] = result
  

func isUint8Array(s: JsObject): bool {.importjs: "(# instanceof Uint8Array)".}
func isArray(s: JsObject): bool {.importjs: "(Array.isArray(#))".}
func isSafeInteger(s: JsObject): bool {.importjs: "(Number.isSafeInteger(#))".}

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
    if isUndefined(arg0):
      this.procName()
    else:
      this.procName(arg0)

template dispatcher2(prototype: JsObject, procName: untyped): untyped =  
  prototype.procName = bindMethod proc (this: BipfBuilder, arg0: sink JsObject, arg1: sink JsObject) =
    if isUndefined(arg1):
      this.procName(arg0)
    else:
      this.procName(arg0, arg1)



func newBipfBuilder(): BipfBuilder =
  result = BipfBuilder()
  var prototype = cast[JsObject](result)
  
  dispatcher1(prototype, startArray)
  prototype.endArray = bindMethod endArray
  dispatcher1(prototype, startMap)
  prototype.endMap = bindMethod endMap
  dispatcher1(prototype, addNull)
  dispatcher2(prototype, addString)
  dispatcher2(prototype, addInt)
  dispatcher2(prototype, addDouble)
  dispatcher2(prototype, addBool)
  dispatcher2(prototype, addBuffer)
  dispatcher2(prototype, addExtended)
  prototype.finish = bindMethod finish

proc serialize*(obj: JsObject): ByteBuffer  =
  var builder = newBipfBuilder()

  proc recursiveEncodeKeyed(builder: BipfBuilder, key: sink cstring, obj: sink JsObject)

  proc recursiveEncode(builder: BipfBuilder, obj: sink JsObject) =
    let jsType = jsTypeOf(obj)
    if jsType == "undefined":
      discard
    elif jsType == "boolean":
      builder.addBool(obj)
    elif jsType == "number":
      if obj.isSafeInteger() and obj >= low(int32) and obj <= high(int32):
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
  
  proc recursiveEncodeKeyed(builder: BipfBuilder, key: sink cstring, obj: sink JsObject) =
    let jsType = jsTypeOf(obj)
    if jsType == "undefined":
      discard
    elif jsType == "boolean":
      builder.addBool(key.jsToUTF8StringInterned, obj)
    elif jsType == "number":
      if obj.isSafeInteger() and obj >= low(int32) and obj <= high(int32):
        builder.addInt(key.jsToUTF8StringInterned, obj)
      else:
        builder.addDouble(key.jsToUTF8StringInterned, obj)
    elif jsType == "string":
      builder.addString(key.jsToUTF8StringInterned, obj)
    elif jsType == "object":
      if isNull(obj):
        builder.addNull(key.jsToUTF8StringInterned)
      elif isUint8Array(obj):
        builder.addBuffer(key.jsToUTF8StringInterned, obj)
      elif isArray(obj):
        builder.startArray(key.jsToUTF8StringInterned)
        for value in obj:
          recursiveEncode(builder, value)
        builder.endArray()
      else:
        builder.startMap(key.jsToUTF8StringInterned)
        for key, value in pairs(obj):
          recursiveEncodeKeyed(builder, key, value)
        builder.endMap()
    else:
      raise newException(ValueError, "Unsupported type: " & $jsType)

  recursiveEncode(builder, obj)
  result = builder.finish()


## Backward compatibility with the bipf module

var lastObjectVisited: JsObject
var lastBufferProduced: ByteBuffer

proc encodingLength(obj: JsObject): int  =
  if obj != lastObjectVisited:
    lastBufferProduced = serialize(obj)
    lastObjectVisited = obj

    return
  result = lastBufferProduced.len

proc encode(obj: JsObject, buffer: ByteBuffer, offset: int = 0): int =
  if obj != lastObjectVisited:
    var builder = newBipfBuilder()
    lastBufferProduced = serialize(obj)
    lastObjectVisited = obj

  if buffer.len - offset < lastBufferProduced.len:
    raise newException(ValueError, "Buffer too small")

  var p = offset
  buffer.writeBuffer(lastBufferProduced, p)
  result = p - offset



jsExport:
  serialize
  encodingLength
  encode
  "allocAndEncode" = serialize

