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

import node_binding
import std/endians
import std/logging

var consoleLog = newConsoleLogger(levelThreshold=lvlAll)
addHandler(consoleLog)

import ../../nim_bipf/common
import ../../nim_bipf/builder
import ../../nim_bipf/serde_json
import ../../nim_bipf/private/deser
import ../../nim_bipf/private/varint
import ../../nim_bipf/private/logging as traceLogging
import ../../nim_bipf/bpath

# Napi helpers for encoding Bipf

converter toInt(n: napi_value): int32            {.inline.} = n.getInt32()
converter toDouble(n: napi_value): float64       {.inline.} = n.getFloat64()
converter toString(n: napi_value): string        {.inline.} = n.getStr()
converter toBool(n: napi_value): bool            {.inline.} = n.getBool()
converter toBuffer(n: napi_value): ByteBuffer    {.inline.} = 
  let (arrType, length, data, arrayBuffer, byteOffset) = getTypedArrayInfo(n)
  
  result = ByteBuffer(newSeq[byte](length))
  let target = addr seq[byte](result)[0]
  copyMem(target, data, length)
converter toAtom(n: napi_value): AtomValue       {.inline.} = raise newException(ValueError, "not implemented")


converter toBipfBuffer(n: napi_value): BipfBuffer {.inline.} = cast[BipfBuffer](n)


template dnItems(n: napi_value): napi_value = n.items

iterator dnPairs(n: napi_value): (string, napi_value) =
  for key in n.getAllPropertyNames():
    let kStr = key.getStr
    yield (kStr, n.getPropertyUnsafe(key))

proc dnKind(obj: napi_value): DynNodeKind {.inline.} =
  block:
    let kind = obj.kind
    case kind
    of napi_undefined: result = nkUndefined
    of napi_null: result = nkNull
    of napi_boolean: result = nkBool
    of napi_number: 
      let longValue = obj.getInt64()
      if longValue == low(int64):
        raise newException(ValueError, "non finite number")
      else:
        result = nkDouble
        if longValue >= low(int32) and longValue <= high(int32):
          let doubleValue = obj.getFloat64()
          if float64(longValue) == doubleValue:
            result = nkInt
    of napi_string: result = nkString
    of napi_object: 
      if isTypedArray(obj):
        let (arrType, x, y, z, zz) = getTypedArrayInfo(obj)

        if arrType == napi_uint8_array:
          result = nkBuffer
        else:
          raise newException(ValueError, "unsupported typed array type:" & $arrType)
      elif isArray(obj):
        result =  nkArray
      else:
        result =  nkMap
    of napi_bigint: result =  nkDouble
    of napi_symbol: result =  nkString

    else: raise newException(ValueError, "unsupported kind:" & $kind)
    
    
proc addNapiValue*(b: var BipfBuilder, key: sink string, node: sink napi_value) {.inline.} =
  addNodeWithKey(b, key, node, NOKEYDICT)

proc addNapiValue*(b: var BipfBuilder, node: sink napi_value) {.inline.} =
  addNode(b, node, string, NOKEYDICT)

# Napi helper for decoding Bipf

type 
  JsObjectFactory = napi_env
template bufferType(ctx: JsObjectFactory): typedesc = NapiBuffer
template nodeType(ctx: JsObjectFactory): typedesc = napi_value
  

template newMap(factory: JsObjectFactory): napi_value = factory.createObject()
template newArray(factory: JsObjectFactory, arr: sink seq[napi_value]): napi_value = factory.create(arr)
template setEntry(factory: JsObjectFactory, map: napi_value, key: napi_value, value: napi_value) = factory.setProperty(map, key, value)
template setElement(factory: JsObjectFactory, arr: napi_value, idx: int, value: napi_value) = factory.setElement(arr, idx.uint32, value)

template readPrefix*(buffer: NapiBuffer, p: var int): BipfPrefix = BipfPrefix(readVaruint32(buffer, p))    
template readPrefix*(buffer: openArray[byte], p: var int): BipfPrefix = BipfPrefix(readVaruint32(buffer, p))    

template readStringNode*(factory: JsObjectFactory, source: NapiBuffer, p: var int, l: int): napi_value =
  let start = p
  p += l
  factory.createString(source.view(start, l))

template readBufferNode*(factory: JsObjectFactory, source: NapiBuffer, p: var int, l: int): napi_value =
  let start = p
  p += l
  factory.createBuffer(source.view(start, l))

template readIntNode*(factory: JsObjectFactory, source: NapiBuffer, p: var int, l: int): napi_value =
  let pInt = source.address(p)
  var i : int32
  littleEndian32(addr i, cast[ptr uint32](pInt))
  p += l
  factory.create(i)

template readDoubleNode*(factory: JsObjectFactory, source: NapiBuffer, p: var int, l: int): napi_value =
  let pDouble = source.address(p)
  var d : float64
  littleEndian64(addr d, cast[ptr float64](pDouble))
  p += l
  factory.create(d)

template readAtomNode*(factory: JsObjectFactory, source: NapiBuffer, p: var int, l: int): napi_value =
  if (l == 0):
    factory.getNull()
  elif (l == 1):
    let pByte = source.address(p)
    inc p
    case cast[ptr byte](pByte)[]
    of 0: factory.create(false)
    of 1: factory.create(true)
    else: raise newException(ValueError, "invalid bool null node (formelly 'invalid boolnull, length must = 1')")
  else:
    raise newException(ValueError, "invalid bool null node (formelly 'invalid boolnull, length must = 1')")

func equals(a: NapiBuffer, b: string, p: int): bool =
  if a.len - p < b.len:
    return false
  for i in 0 ..< b.len:
    if a[p + i] != byte(b[i]):
      return false
  return true

func equals(a: openArray[byte], b: string, p: int): bool =
  trace "equals(a: openArray[byte], b: string, p: int) ", a.repr, " ", b.repr, " ", $p
  if a.len - p < b.len:
    return false
  for i in 0 ..< b.len:
    if a[p + i] != byte(b[i]):
      return false
  return true
  
  
proc deserialize(factory: var JsObjectFactory, buffer: NapiBuffer, start: int): napi_value =
  deserialize[JsObjectFactory](factory, buffer, start)



var db : seq[seq[byte]] = @[]

template match(msg: seq[byte], value: BipfBuffer, at: int): bool =
  var result = true
  for j in 0..<value.len:
    if msg[at + j] != value[j]:
      result = false
      break;
  result


init proc(exports: Module) =
  exports.registerFn(1, "hello"):
    let toGreet = args[0].getStr; # Getting the first and only argument as a string
    echo "Hello " & toGreet

  exports.registerFn(1, "serialize"):
    try:
      let node = args[0]
      var b = BipfBuilder()
      b.addNapiValue(node)
      let size = b.encodingSize()
      var sharedBuffer = SharedBuffer(data: newSeq[byte](size))
      
      b.finish(ByteBuffer(sharedBuffer.data))
      
      return napiCreateSharedBuffer(sharedBuffer)
    except Exception as e:
      error "error in serialize:", e.msg, e.getStackTrace() 
      napiThrowError(e)

  exports.registerFn(2, "deserialize"):
    try:
      let buffer = args[0].getBuffer()
      
      let start = if args.len > 1:
                    let kind = args[1].kind
                    if kind == napi_undefined: 0 else: args[1].getInt32()
                  else: 0

      var jsObjectFactory = `env$`
      return jsObjectFactory.deserialize(buffer, start)
    except Exception as e:
      napiThrowError(e)
  
  exports.registerFn(1, "parseJson2Bipf"):
    try:
      assert args.len == 1

      var builder = newBipfBuilder()
      if args[0].kind == napi_string:                    
        builder.addJson(args[0].getStr)
      elif isBuffer(args[0]):
        let input = args[0].getBuffer()
        var x: ptr UncheckedArray[char] = cast[ptr UncheckedArray[char]](input.data)
        builder.addJson(x.toOpenArray(0, input.len - 1))
      else:
        raise newException(ValueError, "invalid input type")
    
      
      let size = builder.encodingSize()
      var sharedBuffer = SharedBuffer(data: newSeq[byte](size))

      builder.finish(ByteBuffer(sharedBuffer.data))

      return napiCreateSharedBuffer(sharedBuffer)
    except Exception as e:
      napiThrowError(e)


  exports.registerFn(1, "compileSimpleBPath"):
    try:
      assert args.len == 1
      var path = newSeqOfCap[string](5)
      
      for e in args[0].items:
        path.add e.getStr

      let compiled = compileSimplePath(path)
      var r = new BPathRef[string]
      r[] = compiled
      
      return napiCreateRef(r)
    except Exception as e:
      napiThrowError(e)

  exports.registerFn(2, "runBPath"):
    try:
      assert args.len == 2 or args.len == 3
      let buffer = args[0].getBuffer()
      var path : BPathRef[string]
      args[1].getRef(path)
      let start = if args.len == 3: args[2].getInt32() else: 0

      let r = runBPath(buffer, path[], start)      
      return napiCreate(r)
    
    except Exception as e:
      napiThrowError(e)
      
  exports.registerFn(1, "loadDB"):
    try:
      assert args.len == 1

      let arrLen = args[0].len
      db = newSeq[seq[byte]](arrLen)
      for i in 0 ..< arrLen:
        let b = args[0].getElement(i).getBuffer()
        var stored = newSeq[byte](b.len)
        for i in 0 ..< b.len:
          stored[i] = b[i]

        db[i] = stored
    
    except Exception as e:
      napiThrowError(e)
      
  exports.registerFn(1, "searchContacts"):
    try:
      var b = BipfBuilder()
      b.addString("contact")
      let contactVal = b.finish()

      let pathToType : BPath[string] = compileSimplePath(@["value", "content", "type"])

      var count = 0
      
      for msg in db:

        let r = runBPath(msg, pathToType, 0)
        if r == -1:
          continue

        if match(msg, contactVal, r):
          count.inc
          if count == 100:
            break

      return napiCreate(count)

    except Exception as e:
      napiThrowError(e)



    
    