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
import ../nim_bipf/private/bytebuffer
import ../nim_bipf/private/deser
import ../nim_bipf/private/varint
import ../nim_bipf/private/logging as tracing

import ../nim_bipf/common
import ../nim_bipf/builder
import ../nim_bipf/reader
import ../nim_bipf/seeker
import ../nim_bipf/bpath
import sequtils

var consoleLog = newConsoleLogger(levelThreshold=lvlAll)
addHandler(consoleLog)

import std/jsffi
import jsExport


when not(defined(js)):
    {.fatal "This module is only for the JavaScript target.".}

func isUint8Array(s: JsObject): bool {.importjs: "(# instanceof Uint8Array)".}
func isArray(s: JsObject): bool {.importjs: "(Array.isArray(#))".}
func isSafeInteger(s: JsObject): bool {.importjs: "(Number.isSafeInteger(#))".}
func isFinite(s: JsObject): bool {.importjs: "(Number.isFinite(#))".}
func declareSymbol(s: cstring): cstring {.importjs: "Symbol(#)".}

type 
  NodeJsBuffer = distinct JsObject

func fromCString*(s: cstring): NodeJsBuffer {.importjs: "Buffer.from(#)".}
func len*(buffer: NodeJsBuffer): int {.importjs: "#.length".}
func toString*(buffer: NodeJsBuffer, start:int = 0, endExclusive: int = buffer.len): cstring {.importjs: "#.toString('utf8', @)".}
func subarray*(buffer: NodeJsBuffer, start:int = 0, endExclusive: int = buffer.len): NodeJsBuffer {.importjs: "#.subarray(@)".}
func readInt8(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readInt8(@)".}
func readUInt8(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readUInt8(@)".}
func readInt16LE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readInt16LE(@)".}
func readInt16BE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readInt16LE(@)".}
func readUInt16LE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readUInt16LE(@)".}
func readUInt16BE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readUInt16LE(@)".}
func readInt32LE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readInt32LE(@)".}
func readInt32BE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readInt32LE(@)".}
func readUInt32LE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readUInt32LE(@)".}
func readUInt32BE(buffer: NodeJsBuffer, offset: int=0): int {.importjs: "#.readUInt32LE(@)".}
func readFloatLE(buffer: NodeJsBuffer, offset: int=0): float {.importjs: "#.readFloatLE(@)".}
func readFloatBE(buffer: NodeJsBuffer, offset: int=0): float {.importjs: "#.readFloatLE(@)".}
func readDoubleLE(buffer: NodeJsBuffer, offset: int=0): float {.importjs: "#.readDoubleLE(@)".}
func readDoubleBE(buffer: NodeJsBuffer, offset: int=0): float {.importjs: "#.readDoubleLE(@)".}
func compare(source: NodeJsBuffer, target: NodeJsBuffer, targetStart: int, targetEnd: int, sourceStart: int, sourceEnd: int): int {.importjs: "#.compare(@)".}      

func `[]`*(buffer: NodeJsBuffer, p: int): byte {.importjs: "#[#]".}


template equals(source: BipfBuffer; target: NodeJsBuffer; p: int): bool =
  compare(cast[NodeJsBuffer](source), target, 0, target.len, p, p+target.len) == 0
  

var bipfBufferSymbol = declareSymbol("nim_bipf_buffer")
var BipfBufferTool {.exportc : "BipfBuffer".} = newJsObject()

func isBipfBuffer(s: JsObject): bool  =
  {.noSideEffect.}:
    result = jsTypeOf(s) == "object" and s.hasOwnProperty(bipfBufferSymbol)

BipfBufferTool.isBipfBuffer = isBipfBuffer



converter toInt(n: JsObject): int32             = cast[int32](n)
converter toDouble(n: JsObject): float64        = cast[float](n).float64
converter toString(n: JsObject): cstring        = cast[cstring](n)
converter toBool(n: JsObject): bool             = cast[bool](n) 
converter toBuffer(n: JsObject): ByteBuffer     = cast[ByteBuffer](n)
converter toBipfBuffer(n: JsObject): BipfBuffer = cast[BipfBuffer](n)

func dnKind(obj: JsObject): DynNodeKind  =
    let jsType = jsTypeOf(obj)
    if jsType == "undefined":
      result = nkUndefined
    elif jsType == "boolean":
      result = nkBool
    elif jsType == "number":
      if obj.isSafeInteger() and (obj.toInt >= low(int32)) and (obj.toInt <= high(int32)):
        result = nkInt
      elif obj.isFinite():
        result = nkDouble
      else:
        raise newException(ValueError, "Unsupported number (formely 'unknown type' error)" )
    elif jsType == "string":
      result = nkString
    elif jsType == "object":
      if isNull(obj):
        result = nkNull
      elif isUint8Array(obj):
        if isBipfBuffer(obj):
          result = nkBipfBuffer
        else:
          result = nkBuffer
      elif isArray(obj):
        result = nkArray
      else:
        result = nkMap
    else:
      raise newException(ValueError, "Unsupported type (formely 'unknown type'): " & $jsType)

template dnItems(node:JsObject): JsObject = node.items()
iterator dnPairs(node:JsObject): (cstring,JsObject) = 
  for key, value in node.pairs():
    yield (key, value.toJs())

proc addJsObject*(b: var BipfBuilder, key: sink cstring, node: sink JsObject) {.inline.} =
  addNodeWithKey(b, key, node)

proc addJsObject*(b: var BipfBuilder, node: sink JsObject) {.inline.} =
  addNode(b, node)


template markAsBipfBuffer(s: typed)  =
  {.noSideEffect.}:
    s.toJs()[bipfBufferSymbol] = true

when defined(nodejs):
  func toBuffer(s: ByteBuffer): JsObject {.importjs: "Buffer.from(#)"}
else:
  func toBuffer(s: ByteBuffer): JsObject {.importjs: "(#)"}

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
    markAsBipfBuffer(result)



proc serialize*(obj: JsObject): BipfBuffer  =
  var builder = newBipfBuilder()
  try:
    builder.addJsObject(obj)
    result = builder.finish()
    markAsBipfBuffer(result)
  except Exception as e:
    raise newException(ValueError, "Error while serializing object: " & $e.msg & " obj:" & obj.repr)

import std/deques

## Backward compatibility with the bipf module

var lastObjectVisited: JsObject = nil
var lastBufferProduced: BipfBuffer

proc encodingLength(obj: JsObject): int  =
  lastBufferProduced = serialize(obj)
  lastObjectVisited = obj
  result = ByteBuffer(lastBufferProduced).len

func isNodeJsBuffer(buffer: ByteBuffer): bool {.importjs: "( typeof Buffer !== 'undefined' && Buffer.isBuffer(#) )".}

proc encode(obj: JsObject, buffer: ByteBuffer, offset: int = 0): int =
  let offset = if isUndefined(offset): 0 else: offset

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


type JsObjectFactory = distinct int

template newMap(factory: JsObjectFactory): JsObject = newJsObject()
template newArray(factory: JsObjectFactory, arr: seq[JsObject]): JsObject = arr.toJs
template setEntry(factory: JsObjectFactory, map: JsObject, key: cstring, value: JsObject) = map[key] = value
template setElement(factory: JsObjectFactory, arr: JsObject, idx: int, value: JsObject) = arr[idx] = value

var jsObjectFactory = JsObjectFactory(0)



template readPrefix*(buffer: NodeJsBuffer, p: var int): BipfPrefix = BipfPrefix(readVaruint32(buffer, p)) 
template readStringNode*(factory: JsObjectFactory, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let pend = p + l
    let result = toString(source, p, pend).toJs
    p = pend
    result

template readBufferNode*(factory: JsObjectFactory, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let pend = p + l
    let result = source.subarray(p, pend).toJs
    p = pend
    result

template readIntNode*(factory: JsObjectFactory, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let result = source.readInt32LE(p).toJs
    p += l
    result

template readDoubleNode*(factory: JsObjectFactory, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let result = source.readDoubleLE(p).toJs
    p += l
    result

template readBoolNullNode*(factory: JsObjectFactory, source: NodeJsBuffer, p: var int, l: int): JsObject =
  if l == 0: 
    jsNull
  elif l == 1:
    case source[p]
      of 0: 
        inc p
        jsFalse
      of 1: 
        inc p
        jsTrue
      else: raise newException(ValueError, "Invalid value for bool/null node (compat 'invalid boolnull')")
  else:
    raise newException(ValueError, "Invalid length for bool/null node (compat 'invalid boolnull, length must = 1')")


proc deserialize(buffer: BipfBuffer, start: int): JsObject =
  result = deserialize[JsObjectFactory, JsObject, NodeJsBuffer](jsObjectFactory, NodeJsBuffer(buffer.toJs), if isUndefined(start): 0 else: start)


func `$`(obj: JsObject): string =
  let jsType = jsTypeOf(obj)
  if jsType == "string":
    return $cast[cstring](obj)
  elif 
    jsType == "boolean" or
    jsType == "number" or
    jsType == "undefined" or
    jsType == "null":
    return $obj
  elif jsType == "object":
    if isNull(obj):
      return "null"
    elif isArray(obj):
      var res = "["
      for i in 0..<obj.length:
        if i > 0:
          res.add(", ")
        res.add($obj[i])
      return res & "]"
    else:
      var res = "{"
      var first = true
      for key, value in pairs(obj):
        if not first:
          res.add(", ")
        first = false
        res.add($key & ": " & $value)
      return res & "}"
  else:
    raise newException(ValueError, "Unsupported type: " & $jsType)

proc seekKey(buffer: BipfBuffer, start: int, key: JsObject): int =
  var keyBuffer = if jsTypeOf(key) == "string": newByteBuffer(key.cstring)
                  elif jsTypeOf(key) == "object" and isNodeJsBuffer(key): ByteBuffer(key)
                  else: raise newException(ValueError, "Unsupported key type: " & $jsTypeOf(key))
  
  result = buffer.findKey(keyBuffer, start)

proc seekKey2(buffer: BipfBuffer, start: int, key: BipfBuffer, keyStart: int): int =
  result = buffer.findKey(key, start, if isUndefined(keyStart): 0 else: keyStart)


var seekKeyCache = newJsAssoc[cstring, ByteBuffer]()

proc seekKeyCached(buffer: BipfBuffer, start: int, key: cstring): int =
  if jsTypeOf(key.toJs) != "string":
    raise newException(ValueError, "Unsupported key type (formely 'seekKeyCached only supports string target'): " & $jsTypeOf(key.toJs))
  
  var keyBuffer = seekKeyCache[key]
  if isUndefined(keyBuffer):
    keyBuffer = newByteBuffer(key)
    seekKeyCache[key] = keyBuffer

  result = buffer.findKey(keyBuffer, start)


proc seekPath(buffer: BipfBuffer, start: int, target: BipfBuffer, targetStart: int): int =
  var path : seq[NodeJsBuffer] = newSeq[NodeJsBuffer]()
  var pTarget =  if isUndefined(targetStart): 0 else: targetStart
  let arrPrefix = target.readPrefix(pTarget)
  assert arrPrefix.tag == BipfTag.Array
  while (pTarget < target.len):
    let prefix = target.readPrefix(pTarget)

    assert prefix.tag == BipfTag.String, "Invalid path (formely 'seekPath only supports string target'): "    
    path.add(cast[NodeJsBuffer](target.readBufferValue(pTarget, prefix.size)))

  let bpath = compileSimplePath(path)

  result = buffer.runBPath(bpath, start)

type
  SeekFunction = proc (buffer: BipfBuffer, start: int): int

proc compileSimplePath(path: openArray[cstring]) : BPath[NodeJsBuffer] =
  var bufArr = newSeq[NodeJsBuffer](path.len)
  for i, p in path:
    bufArr[i] = fromCString(p)
  result = compileSimplePath(bufArr)

proc createSeekPath(path: openArray[cstring]) : SeekFunction =
  let bpath = compileSimplePath(path)

  result = proc (buffer: BipfBuffer, start: int): int =
    buffer.runBPath(bpath, start)
  
type 
  CompareFunction = proc (b1: BipfBuffer, b2: BipfBuffer): int

proc createCompareAt(paths: seq[seq[cstring]]) : CompareFunction =
  var bPathArray = newSeq[BPath[NodeJsBuffer]](paths.len)
  var i = 0
  for path in paths:
    bPathArray[i] = compileSimplePath(path)
    inc i
  
  result = proc (b1: BipfBuffer, b2: BipfBuffer): int =
    for pPath in bPathArray:
      let v1 = b1.runBPath(pPath, 0)
      let v2 = b2.runBPath(pPath, 0)

      result = compare(b1, b2, v1, v2)
      if result != 0:
        return result
    return 0

proc slice(buffer: BipfBuffer, start: int): JsObject =
  ## this function return the value buffer
  ## without the prefix
  var p = start
  let prefix = buffer.readPrefix(p)
  let size = prefix.size
  
  result = buffer.readBufferValue(p, size).toBuffer

proc  pluck(buffer: BipfBuffer, start: int): JsObject =
  ## this function return the value buffer
  ## without the prefix
  var p = start
  let prefix = buffer.readPrefix(p)
  let size = prefix.size + (p - start)
  p = start
  
  result = buffer.readBufferValue(p, size).toBuffer


proc encodeIdempotent(obj: JsObject, buffer: ByteBuffer, offset: int = 0): int =
  result = encode(obj, buffer, offset)
  markAsBipfBuffer(result)

proc markIdempotent(buffer: sink BipfBuffer): BipfBuffer =
  result = buffer
  markAsBipfBuffer(result)

type 
  IterateCallback = proc (buffer: BipfBuffer, valuePointer: int, keyPointerOrIndex: int) : bool

proc iterate(objBuf: BipfBuffer, start: int, callback: IterateCallback) : int =
  var p = start
  let prefix = objBuf.readPrefix(p)
  let size = prefix.size
  let tag = prefix.tag
  let endOffset = p + size
  

  if tag == BipfTag.OBJECT:
    while p < endOffset:
      let keyPointer = p
      let keyPrefix = objBuf.readPrefix(p)
      p += keyPrefix.size
      let valuePointer = p
      let valuePrefix = objBuf.readPrefix(p)
      p += valuePrefix.size

      if callback(objBuf, valuePointer, keyPointer):
        break
    return start
  elif tag == BipfTag.ARRAY:
    var i = 0
    while p < endOffset:
      let valuePointer = p
      let valuePrefix = objBuf.readPrefix(p)
      p += valuePrefix.size

      if callback(objBuf, valuePointer, i):
        break
      inc i
    return start
  else:
    return -1

func getEncodedLength(obj: BipfBuffer, start: int): int =
  var p = if isUndefined(start): 0 else: start

  let prefix = obj.readPrefix(p)
  return prefix.size

func getEncodedType(obj: BipfBuffer, start: int): BipfTag =
  var p = if isUndefined(start): 0 else: start

  let prefix = obj.readPrefix(p)
  return prefix.tag




var typesConstants = newJsObject()
typesConstants["object"] = BipfTag.OBJECT
typesConstants["array"] = BipfTag.ARRAY
typesConstants["string"] = BipfTag.STRING
typesConstants["buffer"] = BipfTag.BUFFER
typesConstants["int"] = BipfTag.INT
typesConstants["double"] = BipfTag.DOUBLE
typesConstants["boolnull"] = BipfTag.BOOLNULL
typesConstants["extended"] = BipfTag.EXTENDED

proc compareCompat(b1: BipfBuffer, v1: int, b2: BipfBuffer,  v2: int): int =
  result = compare(b1, b2, v1, v2)

import ../nim_bipf/serde_json




jsExport:
  serialize
  deserialize

  encodingLength
  encode
  "allocAndEncode" = serialize
  "decode" = deserialize
  seekPath
  seekKey
  seekKey2
  seekKeyCached
  slice
  pluck
  encodeIdempotent
  markIdempotent
  getEncodedLength
  getEncodedType
  "allocAndEncodeIdempotent" = serialize
  "isIdempotent" = isBipfBuffer
  iterate
  "types" = typesConstants
  createSeekPath
  createCompareAt
  "compare" = compareCompat

