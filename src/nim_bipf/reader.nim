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

converter asByteBuffer*(b: BipfBuffer): ByteBuffer =
  ByteBuffer(b)

func readPrefix*(buffer: ByteBuffer, p: var int): BipfPrefix {.inline.} = BipfPrefix(readVaruint32(buffer, p))    

template readStringValue*(buffer: ByteBuffer, p: var int, size: int): typed =
  readUtf8(buffer, p, size)

func readBufferValue*(buffer: ByteBuffer, p: var int, size: int): ByteBuffer {.inline.} =
  readBuffer(buffer, p, size)


func readIntValue*(buffer: ByteBuffer, p: var int, size: int): int32 {.inline.} =
  readInt32LittleEndian(buffer, p)


func readFloatValue*(buffer: ByteBuffer, p: var int, size: int): float64 {.inline.} =
  readFloat64LittleEndian(buffer, p)

func readBoolNullValue*(buffer: ByteBuffer, p: var int, size: int): BoolNullValue =
  if size == 0:
    result = NULL
  elif size == 1:
    let v = buffer[p]
    inc(p)
    case v:
      of 0:
        result = FALSE
      of 1:
        result = TRUE
      else:
        raise newException(BipfValueError, "Invalid bool value (formely 'invalid boolnull'): " & $v)
  else:
    raise newException(BipfValueError, "Invalid bool value size (formely 'invalid boolnull, length must = 1'): " & $size)

#[ 
template eatString*[Bi](buffer: Bi, p: var int): NativeString =
  ## Reads prefix, check if String and read a string from the buffer.
  block:
    let prefix = buffer.readPrefix(p)

    assert prefix.tag == BipfTag.STRING, "Expected string, got [formely 'required type:string']: " 

    readStringValue(buffer, p, prefix.size)
 ]#



const NULL_PREFIX = BipfPrefix(BipfTag.BOOLNULL)

func compare*(b1: BipfBuffer, b2: BipfBuffer, start1: int = 0, start2: int = 0) : int =
  # undefined is larger than anything
  if start1 < 0:
    if start2 < 0:
      return 0
    else:
      return 1
  elif start2 < 0:
    return -1

  var p1 = start1 
  var p2 = start2

  let prefix1 = b1.readPrefix(p1)
  let prefix2 = b2.readPrefix(p2)

  # null is smaller than anything
  if prefix1.uint32 == NULL_PREFIX.uint32:
    if prefix2.uint32 == NULL_PREFIX.uint32:
      return 0
    else:
      return -1
  elif prefix2.uint32 == NULL_PREFIX.uint32:
    return 1

  let tag1 = prefix1.tag
  let size1 = prefix1.size
  let tag2 = prefix2.tag
  let size2 = prefix2.size

  # compare number types combinations
  if tag1 == BipfTag.INT and tag2 == BipfTag.DOUBLE:
    let v1 = b1.readIntValue(p1, size1)
    let v2 = b2.readFloatValue(p2, size2)
    return float64(v1).cmp(v2)
  elif tag2 == BipfTag.INT and tag1 == BipfTag.DOUBLE:
    let v2 = b2.readIntValue(p2, size2)
    let v1 = b1.readFloatValue(p1, size1)
    return v1.cmp(float64(v2))
  
  # if not same type, compare by type
  if (tag1 != tag2):
    return tag1.int - tag2.int

  if tag1 == BipfTag.INT:
    let v1 = b1.readIntValue(p1, size1)
    let v2 = b2.readIntValue(p2, size2)
    return v1.cmp(v2)
  elif tag1 == BipfTag.DOUBLE:
    let v1 = b1.readFloatValue(p1, size1) # we tested yet nulls
    let v2 = b2.readFloatValue(p2, size2)
    return v1.cmp(v2)
  else: # make bytes comparison
    return compare(ByteBuffer(b1), ByteBuffer(b2), p1, size1, p2, size2)
