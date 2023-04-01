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
import std/options
import sequtils

var consoleLog = newConsoleLogger(levelThreshold=lvlAll)
addHandler(consoleLog)

import std/jsffi
import ../../../jsExport.nim/src/jsExport
import nodebuffer

when not(defined(js)) or not(defined(nodejs)):
    {.fatal "This module is only for the JavaScript target on nodejs.".}

func isUint8Array(s: JsObject): bool {.importjs: "(# instanceof Uint8Array)".}
func isArray(s: JsObject): bool {.importjs: "(Array.isArray(#))".}
func isSafeInteger(s: JsObject): bool {.importjs: "(Number.isSafeInteger(#))".}
func isFinite(s: JsObject): bool {.importjs: "(Number.isFinite(#))".}
func declareSymbol(s: cstring): cstring {.importjs: "Symbol(#)".}

  

var bipfBufferSymbol = declareSymbol("nim_bipf_buffer")
var BipfBufferTool {.exportc : "BipfBuffer".} = newJsObject()

func isBipfBuffer(s: JsObject): bool  =
  {.noSideEffect.}:
    result = jsTypeOf(s) == "object" and s.hasOwnProperty(bipfBufferSymbol)

BipfBufferTool.isBipfBuffer = isBipfBuffer

template equals(source: BipfBuffer; target: NodeJsBuffer; p: int): bool =
  compare(cast[NodeJsBuffer](source), target, 0, target.len, p, p+target.len) == 0


converter toInt(n: JsObject): int32             = cast[int32](n)
converter toDouble(n: JsObject): float64        = cast[float](n).float64
converter toString(n: JsObject): cstring        = cast[cstring](n)
converter toBool(n: JsObject): bool             = cast[bool](n) 
converter toBuffer(n: JsObject): ByteBuffer     = cast[ByteBuffer](n)
converter toBipfBuffer(n: JsObject): BipfBuffer = cast[BipfBuffer](n)

var valueAtomsMap = newJsAssoc[cstring, AtomValue]()
var valueAtoms = newSeq[cstring]()

converter toAtom(n: JsObject): AtomValue =
  result = valueAtomsMap[n.cstring]
  if isUndefined(result):
    result = AtomValue(valueAtoms.len.uint32)
    valueAtomsMap[n.cstring] = result
    valueAtoms.add(n.cstring)


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

type 
  CStringAtomDict = object of JsObject
    values: seq[cstring]
    map: JsAssoc[cstring, AtomValue]

  CStringAtomDictRef = ref CStringAtomDict

proc newKeyDict*(): CStringAtomDictRef =
  result = CStringAtomDictRef(
    values: newSeq[cstring](),
    map: newJsAssoc[cstring, AtomValue]()
  )
  ## add 2 nil values to the dict for true and false
  result.values.add(jsNull)
  result.values.add(jsNull)

template atomFor*(dict: CStringAtomDictRef; value: cstring): AtomValue =
  var result = dict.map[value]
  if isUndefined(result):
    result = AtomValue(dict.values.len.uint32)
    dict.map[value] = result
    dict.values.add(value)
  result

template valueFor*(dict: CStringAtomDictRef; atom: AtomValue): JsObject = dict.values[atom.uint32].toJs()


proc addJsObject*(b: var BipfBuilder, key: sink cstring, node: sink JsObject) {.inline.} =
  addNodeWithKey(b, key, node, NOKEYDICT)

proc addJsObject*(b: var BipfBuilder, node: sink JsObject) {.inline.} =
  addNode(b, node, cstring, NOKEYDICT)

proc addJsObjectWithKeyDict*(b: var BipfBuilder, key: sink cstring, node: sink JsObject, keyDict: CStringAtomDictRef) {.inline.} =
  addNodeWithKey(b, key, node, keyDict)

proc addJsObjectWithKeyDict*(b: var BipfBuilder, node: sink JsObject, keyDict: CStringAtomDictRef) {.inline.} =
  addNode(b, node, cstring, keyDict)


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

type 
  BuilderCtxWithoutKeyDict = distinct int
  BuilderCtxWithKeyDict = object
    keyDict: CStringAtomDictRef
  BuilderCtx = BuilderCtxWithoutKeyDict | BuilderCtxWithKeyDict

var defaultBuilderContext = BuilderCtxWithoutKeyDict(0)


func newBipfBuilder(): BipfBuilder[BuilderCtxWithoutKeyDict] =
  result = newBipfBuilder(defaultBuilderContext)
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



proc serialize*(obj: JsObject, maybeKeyDict: CStringAtomDictRef): BipfBuffer  =
  var builder = newBipfBuilder()
  if isUndefined(maybeKeyDict):
    builder.addJsObject(obj)
  else:
    builder.addJsObjectWithKeyDict(obj, maybeKeyDict)
  result = builder.finish()
  markAsBipfBuffer(result)


import std/deques

## Backward compatibility with the bipf module

var lastObjectVisited: JsObject = nil
var lastBufferProduced: BipfBuffer

proc encodingLength(obj: JsObject): int  =
  lastBufferProduced = serialize(obj, nil)
  lastObjectVisited = obj
  result = ByteBuffer(lastBufferProduced).len

func isNodeJsBuffer(buffer: JsObject): bool {.importjs: "( typeof Buffer !== 'undefined' && Buffer.isBuffer(#) )".}

proc encode(obj: JsObject, buffer: NodeJsBuffer, offset: int = 0): int =
  let offset = if isUndefined(offset): 0 else: offset

  if obj != lastObjectVisited:
    lastBufferProduced = serialize(obj, nil)
    lastObjectVisited = obj

  if buffer.len - offset < ByteBuffer(lastBufferProduced).len and not isNodeJsBuffer(buffer.toJs()):
    raise newException(ValueError, "Buffer too small")

  var p = offset
  ByteBuffer(buffer).writeBuffer(ByteBuffer(lastBufferProduced), p)
  result = p - offset


let jsTrue {.importjs: "true", nodecl.} : JsObject
let jsFalse {.importjs: "false", nodecl.} : JsObject


type 
  DeserCtxWithoutKeyDict = distinct int
  DeserCtxWithKeyDict = object
    keyDict: CStringAtomDictRef
  DeserCtx = DeserCtxWithoutKeyDict | DeserCtxWithKeyDict

var jsObjectFactory = DeserCtxWithoutKeyDict(0)

template bufferType(ctx: DeserCtx): typedesc = NodeJsBuffer
template nodeType(ctx: DeserCtx): typedesc = JsObject

template keyFor(ctx: DeserCtxWithKeyDict; atom: AtomValue): JsObject = valueFor(ctx.keyDict, atom).toJs()

template newMap(factory: DeserCtx): JsObject = newJsObject()
template newArray(factory: DeserCtx, arr: seq[JsObject]): JsObject = arr.toJs
template setEntry(factory: DeserCtx, map: JsObject, key: cstring, value: JsObject) = map[key] = value
template setElement(factory: DeserCtx, arr: JsObject, idx: int, value: JsObject) = arr[idx] = value
template readPrefix*(buffer: NodeJsBuffer, p: var int): BipfPrefix = BipfPrefix(readVaruint32(buffer, p)) 
template readStringNode*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let pend = p + l
    let result = toString(source, p, pend).toJs
    p = pend
    result

template readBufferNode*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let pend = p + l
    let result = source.subarray(p, pend).toJs
    p = pend
    result

template readIntNode*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let result = source.readInt32LE(p).toJs
    p += l
    result

template readDoubleNode*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let result = source.readDoubleLE(p).toJs
    p += l
    result

template readAtomValue*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): AtomValue =
  let len = l
  var result = case len
              of 0: AtomValue(-1)
              of 1: AtomValue(source[p].uint32)
              of 2: AtomValue(source.readUInt16LE(p).uint32)
              of 3: AtomValue((source[p].uint32 shl 16) or (source[p+1].uint32 shl 8) or source[p+2].uint32)
              of 4: AtomValue(source.readUInt32LE(p))
              else:
                raise newException(ValueError, "Invalid length for Atom value (must be 0, 1, 2, 3 or 4). Got: " & $len)
  p += len
  result

template readAtomNode*(factory: DeserCtx, source: NodeJsBuffer, p: var int, l: int): JsObject =
  block:
    let result = readAtomValue(factory, source, p, l)
    case result.int:
    of -1: jsNull
    of 0: jsFalse
    of 1: jsTrue
    else: result.toJs

proc deserialize(buffer: BipfBuffer, maybeStartOrKeyDict: JsObject, maybeKeyDict: CStringAtomDictRef): JsObject =
  var start = 0
  if jsTypeOf(maybeStartOrKeyDict) == "number":
    start = toInt(maybeStartOrKeyDict)
    if isUndefined(maybeKeyDict):
      deserialize[DeserCtxWithoutKeyDict](jsObjectFactory, NodeJsBuffer(buffer.toJs), start)
    else:
      var ctx = DeserCtxWithKeyDict(keyDict: maybeKeyDict)
      deserialize[DeserCtxWithKeyDict](ctx, NodeJsBuffer(buffer.toJs), start)
  elif isUndefined(maybeStartOrKeyDict):
    deserialize[DeserCtxWithoutKeyDict](jsObjectFactory, NodeJsBuffer(buffer.toJs), start)
  else:
    var ctx = DeserCtxWithKeyDict(keyDict:CStringAtomDictRef(maybeStartOrKeyDict))
    deserialize[DeserCtxWithKeyDict](ctx, NodeJsBuffer(buffer.toJs), start)


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
  if not isNodeJsBuffer(target.toJs):
    raise newException(ValueError, "Unsupported target type (formely 'path must be encoded array'): " & $jsTypeOf(target.toJs))

  var path : seq[NodeJsBuffer] = newSeq[NodeJsBuffer]()
  var pTarget =  if isUndefined(targetStart): 0 else: targetStart
  let arrPrefix = target.readPrefix(pTarget)

  assert arrPrefix.tag == BipfTag.Array, "Unsupported target type (formely 'path must be encoded array')"

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


proc encodeIdempotent(obj: JsObject, buffer: NodeJsBuffer, offset: int = 0): int =
  result = encode(obj, buffer, offset)
  markAsBipfBuffer(result)

proc markIdempotent(buffer: BipfBuffer): BipfBuffer =
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




var typesConstants = newJsAssoc[cstring, BipfTag]()
typesConstants["object"] = BipfTag.OBJECT
typesConstants["array"] = BipfTag.ARRAY
typesConstants["string"] = BipfTag.STRING
typesConstants["buffer"] = BipfTag.BUFFER
typesConstants["int"] = BipfTag.INT
typesConstants["double"] = BipfTag.DOUBLE
typesConstants["boolnull"] = BipfTag.ATOM
typesConstants["atom"] = BipfTag.ATOM
typesConstants["extended"] = BipfTag.EXTENDED

proc compareCompat(b1: BipfBuffer, v1: int, b2: BipfBuffer,  v2: int): int =
  ### this function is a compatibility wrapper for the old compare function
  result = compare(b1, b2, v1, v2)

import ../nim_bipf/serde_json


jsExportTypes:
  NodeJsBuffer
  BipfBuffer
  CStringAtomDict
  

jsExport:
  serialize
  deserialize

  newKeyDict

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

