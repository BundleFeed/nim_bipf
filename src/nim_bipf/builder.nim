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

import common
import private/bytebuffer
import private/varint
import private/logging

import std/json
import tables

type

  StackValueTag = enum
    svtSTRING   = 0, # (000) // utf8 encoded string
    svtBUFFER   = 1, # (001) // raw binary buffer
    svtINT      = 2, # (010) // little endian 32 bit integer
    svtDOUBLE   = 3, # (011) // little endian 64 bit float
    svtARRAY    = 4, # (100) // sequence of any other value
    svtOBJECT   = 5, # (101) // sequence of alternating bipf encoded key and value
    svtBOOLNULL = 6, # (110) // 1 = true, 0 = false, no value means null
    svtEXTENDED = 7 # (111)  // custom type. Specific type should be indicated by varint at start of buffer

    svtBIPF_BUFFER,
    svtCSTRING

  StackValue = object
    encodedSize : int
    case tag: StackValueTag
    of svtSTRING:
      str: string
    of svtCSTRING:
      cstr: cstring
    of svtBUFFER, svtBIPF_BUFFER:
      buf: ByteBuffer
    of svtINT:
      i: int32
    of svtDOUBLE:
      d: float64
    of svtBOOLNULL:
      b: BoolNullValue
    of svtEXTENDED:
      ext: ByteBuffer
    of svtARRAY, svtOBJECT:
      size: int

  BipfBuilderObj = object
    stack    : seq[StackValue]
    pointers : seq[int]
  
  BipfBuilder* = ref BipfBuilderObj

type
  DynNodeKind* = enum
      nkUndefined,
      nkNull, 
      nkBool, 
      nkInt, 
      nkDouble, 
      nkString, 
      nkBuffer,
      nkBipfBuffer, 
      nkArray, 
      nkMap
  
  MapDynNodeKey* = concept n

  BaseDynNode* = concept n
    n.dnKind is DynNodeKind

  ArrayDynNode* = concept n, v
    for v in n.dnItems:
      v is BaseDynNode

  MapDynNode* = concept n, e
    for e in n.dnPairs:
      e is (MapDynNodeKey, BaseDynNode)

  DynNode* {.explain.} = concept n
      n is BaseDynNode
      n is ArrayDynNode
      n is MapDynNode


template tagLen(v: int): int =
  assert v >= 0 and v <= high(int32)
  
  let u = v.uint32 shl 3
  if u < 0x80:
    1
  elif u < 0x4000:
    2
  elif u < 0x200000:
    3
  elif u < 0x10000000:
    4
  else:
    5

template toStackValue(value: typed): StackValue =
  when typeof(value) is string:
    StackValue(tag: svtSTRING, str: value, encodedSize: value.len)    
  elif typeof(value) is cstring:
    StackValue(tag: svtCSTRING, cstr: value, encodedSize: lenUtf8(value))
  elif typeof(value) is ByteBuffer:
    StackValue(tag: svtBUFFER, buf: value, encodedSize: value.len)
  elif typeof(value) is int32:
    StackValue(tag: svtINT, i: value, encodedSize: 4)
  elif typeof(value) is float64:
    StackValue(tag: svtDOUBLE, d: value, encodedSize: 8)
  elif typeof(value) is BoolNullValue:
    StackValue(tag: svtBOOLNULL, b: value, encodedSize: if (value == NULL): 0 else: 1)
  elif (typeof(value) is StackValueTag):
    when value == svtARRAY or value == svtOBJECT:
      StackValue(tag: value, size: 0, encodedSize: 0) ## size is set when the array/map is closed
  elif (typeof(value) is BipfBuffer):
    StackValue(tag: svtBIPF_BUFFER, buf: ByteBuffer(value), encodedSize: ByteBuffer(value).len)
  elif typeof(value) is StackValue:
    value
  else:
    raise newException(BipfValueError, "Unsupported type: " & $typeof(value))


template addValueToStack(b: BipfBuilder, value: typed) =
  trace "addValueToStack (",typeof(value), "):", value.repr

  var v = toStackValue(value)
  trace "  stack value: ", v.repr

  if unlikely(b.pointers.len == 0):
    if unlikely(b.stack.len > 0):
      raise newException(BipfValueError, "Cannot add value at root when root is not empty")
    when typeof(value) is StackValueTag:
      when (value == svtOBJECT or value == svtARRAY):
        b.pointers.add(b.stack.len)
    b.stack.add(move(v))
  else:
    let p = b.pointers[^1]
  
    if b.stack[p].tag == svtARRAY:
      b.stack[p].size += 1
      var added = v.encodedSize
      when typeof(value) is StackValueTag:
        when (value == svtOBJECT or value == svtARRAY):
          b.pointers.add(b.stack.len)
        else:
          {.fatal: "Unreachable".}
      elif not (typeof(value) is BipfBuffer):
        added += tagLen(v.encodedSize)
      b.stack[p].encodedSize += added
      b.stack.add(move(v))
    else:
      raise newException(BipfValueError, "Cannot add a value in a map without a key")

template addKeyedValueToStack(b: BipfBuilder, key: cstring | string, value: typed) =
  trace "addKeyedValueToStack (",typeof(value), "):", value.repr, " key:", key, " (", typeof(key), ")"

  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot add value with a key at root")
  else:
    let p = b.pointers[^1]
    
    if b.stack[p].tag == svtOBJECT:
      b.stack[p].size += 1
      
      var k = toStackValue(key)
      var v = toStackValue(value)

      var added = k.encodedSize + v.encodedSize + tagLen(k.encodedSize)
      b.stack.add(move(k))

      when typeof(value) is StackValueTag:
        when value == svtOBJECT or value == svtARRAY:
          b.pointers.add(b.stack.len)
        else:
          {.fatal: "Unreachable".}
      elif not (typeof(value) is BipfBuffer):
        added += tagLen(v.encodedSize)

      b.stack[p].encodedSize += added
      b.stack.add(move(v))
    else:
      raise newException(BipfValueError, "Cannot add a value with a key in an array")
  

func newBipfBuilder*(): BipfBuilder =
  ## Creates a new BipfWriter.
  
  new(result)

func startMap*(b: var BipfBuilder)  {.inline.} =
  ## Starts a new map at root or in an array.
  addValueToStack(b, svtOBJECT)

func startMap*(b: var BipfBuilder, key: sink string | cstring)  {.inline.} =
  ## Starts a new map in a map.
  addKeyedValueToStack(b, key, svtOBJECT)

func startArray*(b: var BipfBuilder) {.inline.} =
  ## Starts a new array.
  addValueToStack(b, svtARRAY)

func startArray*(b: var BipfBuilder, key: sink string | cstring) {.inline.}  =
  ## Starts a new array in a map.
  addKeyedValueToStack(b, key, svtARRAY)

func addInt*(b: var BipfBuilder, i: sink int32) {.inline.} =
  ## Adds an integer to the current array.
  addValueToStack(b, i)

func addDouble*(b: var BipfBuilder, d: sink float64)  {.inline.} =
  ## Adds a double to the current array.
  addValueToStack(b, d)

func addString*(b: var BipfBuilder, s: sink string | cstring)  {.inline.} =
  ## Adds a NativeString to the current array.
  addValueToStack(b, s)

func addBuffer*(b: var BipfBuilder, buff: sink ByteBuffer)  {.inline.} =
  ## Adds a buffer to the current array.
  addValueToStack(b, buff)

func addBipfBuffer*(b: var BipfBuilder, buff: sink BipfBuffer)  {.inline.} =
  ## Adds a buffer to the current array.
  addValueToStack(b, buff)

func addBool*(b: var BipfBuilder, v: sink bool) {.inline.} =
  ## Adds a boolean to the current array.
  addValueToStack(b, if v: TRUE else: FALSE)

func addNull*(b: var BipfBuilder)  {.inline.} =
  ## Adds a null to the current array.
  addValueToStack(b, NULL)

func addExtended*(b: var BipfBuilder, ext: sink ByteBuffer)  {.inline.} =
  ## Adds an extended value to the current array.
  addValueToStack(b, StackValue(tag:svtEXTENDED, ext: ext))

func addInt*(b: var BipfBuilder, k: sink string | cstring, i: sink int32)  {.inline.} =
  ## Adds an integer to the current map.
  addKeyedValueToStack(b, k, i)

func addDouble*(b: var BipfBuilder, k: sink string | cstring, d: sink float64)  {.inline.} =
  ## Adds a double to the current map.
  addKeyedValueToStack(b, k, d)

func addString*(b: var BipfBuilder, k: sink string | cstring, s: sink string | cstring)  {.inline.} =
  ## Adds a NativeString to the current map.
  addKeyedValueToStack(b, k, s)

func addBuffer*(b: var BipfBuilder, k: sink string | cstring, buf: sink ByteBuffer)  {.inline.} =
  ## Adds a buffer to the current map.
  addKeyedValueToStack(b, k, buf)

func addBipfBuffer*(b: var BipfBuilder, k: sink string | cstring, buf: sink BipfBuffer)  {.inline.} =
  ## Adds a buffer to the current map.
  addKeyedValueToStack(b, k, buf)

func addBool*(b: var BipfBuilder, k: sink string | cstring, v: sink bool)  {.inline.} =
  ## Adds a boolean to the current map.
  addKeyedValueToStack(b, k, if v: TRUE else: FALSE)

func addNull*(b: var BipfBuilder, k: sink string | cstring)  {.inline.} =
  ## Adds a null to the current map.
  addKeyedValueToStack(b, k, NULL)

func addExtended*(b: var BipfBuilder, k: sink string | cstring, ext: sink ByteBuffer)  {.inline.} =
  ## Adds an extended value to the current map.
  addKeyedValueToStack(b, k, StackValue(tag:svtEXTENDED, ext: ext))

template endBlock(b: var BipfBuilder, blockTag: static StackValueTag) =

  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
  else:
    let p = b.pointers.pop()

    if b.stack[p].tag != blockTag:
      raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
    
    if (b.pointers.len > 0): # if we are not at root, update the size of the parent block
      let parentP = b.pointers[^1]
      let pEncodedSize = b.stack[p].encodedSize
      b.stack[parentP].encodedSize += pEncodedSize + tagLen(pEncodedSize)


func endArray*(b: var BipfBuilder)  {.inline.} =
  ## Ends the current array.
  endBlock(b, svtARRAY)

func endMap*(b: var BipfBuilder)  {.inline.} =
  ## Ends the current map.
  endBlock(b, svtOBJECT)

proc addNodeWithKey*[N:DynNode, K:MapDynNodeKey](builder: var BipfBuilder, key: sink K, obj: sink N)

proc addNode*[N:DynNode](builder: var BipfBuilder, obj: sink N) =
  let nodeKind = obj.dnKind
  case nodeKind
  of nkUndefined:
    discard
  of nkNull:
    builder.addNull()
  of nkBool:
    builder.addBool(obj)
  of nkInt:
    builder.addInt(obj)
  of nkDouble:
    builder.addDouble(obj)
  of nkString:
    builder.addString(obj)
  of nkBuffer:
    builder.addBuffer(obj)
  of nkArray:
    builder.startArray()
    for value in obj.dnItems:
      addNode(builder, value)
    builder.endArray()
  of nkMap:
    builder.startMap()
    for key, value in obj.dnPairs:
      addNodeWithKey(builder, key, value)
    builder.endMap()
  of nkBipfBuffer:
    builder.addBipfBuffer(obj)
  
proc addNodeWithKey*[N:DynNode, K:MapDynNodeKey](builder: var BipfBuilder, key: sink K, obj: sink N) =
  let nodeKind = obj.dnKind

  case nodeKind
  of nkUndefined:
    discard
  of nkNull:
    builder.addNull(key)
  of nkBool:
    builder.addBool(key, obj)
  of nkInt:
    builder.addInt(key, obj)
  of nkDouble:
    builder.addDouble(key, obj)
  of nkString:
    builder.addString(key, obj)
  of nkBuffer:
    builder.addBuffer(key, obj)
  of nkArray:
    builder.startArray(key)
    for value in obj.dnItems:
      addNode(builder, value)
    builder.endArray()
  of nkMap:
    builder.startMap(key)
    for key, value in obj.dnPairs:
      addNodeWithKey(builder, key, value)
    builder.endMap()
  of nkBipfBuffer:
    builder.addBipfBuffer(key, obj)

func encodingSize*(b: var BipfBuilder): int =
  ## Returns the size of the current bipf document.
  if b.stack.len == 0:
    raise newException(BipfValueError, "Cannot get encoding size before adding any value")
  if b.pointers.len > 0:
    raise newException(BipfValueError, "Cannot get encoding size before ending all arrays and maps")

  result = b.stack[0].encodedSize + tagLen(b.stack[0].encodedSize)

func finish*[B](b: var BipfBuilder, buffer: var B) =
  ## Finishes the current bipf document and returns the result.
  var p = 0
  for sv in b.stack:
    if unlikely(sv.tag == svtBIPF_BUFFER):
      writeBuffer(buffer, sv.buf, p)
    else:
      let tagCode = if unlikely(sv.tag == svtCSTRING): svtSTRING else: sv.tag
      let tag = tagCode.uint32 + sv.encodedSize.uint32 shl 3
      writeVaruint32(buffer, tag, p)
      case sv.tag:
        of svtOBJECT, svtARRAY:
          discard
        of svtINT:
          writeInt32LittleEndian(buffer, sv.i, p)
        of svtDOUBLE:
          writeFloat64LittleEndian(buffer, sv.d, p)
        of svtBOOLNULL:
          case sv.b:
            of TRUE:
              buffer[p] = 1
              p+=1
            of FALSE:
              buffer[p] = 0
              p+=1
            of NULL:
              discard
        of svtSTRING:
          writeUtf8(buffer, sv.str, p)
        of svtCSTRING:
          writeUtf8(buffer, sv.cstr, p)
        of svtEXTENDED:
          writeBuffer(buffer, sv.ext, p)
        of svtBUFFER:
          writeBuffer(buffer, sv.buf, p)
        of svtBIPF_BUFFER:
          discard


func finish*(b: var BipfBuilder): BipfBuffer =
  ## Finishes the current bipf document and returns the result.
  
  let encodedSize = encodingSize(b)

  var r = newByteBuffer(encodedSize)
  b.finish(r)
  result = BipfBuffer(r)
