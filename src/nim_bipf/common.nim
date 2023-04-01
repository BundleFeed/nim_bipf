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

import std/tables


when defined(js):
  import private/backend/js
else:
  import private/backend/c

export lenUTF8


type

  BipfValueError* = object of ValueError

  BipfTag* = enum
    STRING   = 0, # (000) // utf8 encoded string
    BUFFER   = 1, # (001) // raw binary buffer
    INT      = 2, # (010) // little endian 32 bit integer
    DOUBLE   = 3, # (011) // little endian 64 bit float
    ARRAY    = 4, # (100) // sequence of any other value
    OBJECT   = 5, # (101) // sequence of alternating bipf encoded key and value
    ATOM     = 6, # (110) // 1 = true, 0 = false, no value means null
    EXTENDED = 7 # (111)  // custom type. Specific type should be indicated by varint at start of buffer

  AtomValue* = distinct int


  AtomDictionary* = concept d, v, a
    v is BipfBuffer
    a is Atom
    d.atomFor(v) is a
    d.valueFor(a) is v

  BipfPrefix* = distinct uint32

  BipfBuffer*[OB] = object
    buffer: OB


  NoopKeyDict* = ref object

var NOKEYDICT* : NoopKeyDict = nil
  
const TRUE* = AtomValue(1)
const FALSE* = AtomValue(0)



# BipfPrefix helpers

template tag*(prefix: BipfPrefix): BipfTag = BipfTag(prefix.uint32 and 7)
template size*(prefix: BipfPrefix): int = (prefix.uint32 shr 3).int
template prefix*(tag: BipfTag, size: int): BipfPrefix = BipfPrefix((size.uint32 shl 3) or tag)
template `==`*(a, b: BipfPrefix): bool = a.uint32 == b.uint32
template `$`*(p: BipfPrefix): string = "(" & $p.tag & "," & $p.size & ")"

    
    
# ------------------------------

# BipfBuffer helpers

template len*(bipf: BipfBuffer): int = bipf.buffer.len
template readPrefix*[B](bipf: B, p: var int): BipfPrefix = BipfPrefix(readVaruint32(bipf.buffer, p)) 

func skipNext*(bipf: BipfBuffer, p: var int) {.inline.} =
  let prefix = bipf.readPrefix(p)
  p += prefix.size

template copyBipfBuffer*[B](result: var B, s: BipfBuffer[B], p: var int) = copyBuffer(result, s.buffer, p)

# ------------------------------

template encodingSize*(v: AtomValue): int =
  if v.int < 0:
    0
  elif v.int <= 255:
    1
  elif v.int <= 65535:
    2
  elif v.int <= 16777215:
    3
  else:
    4


# AtomDictionary helpers
#[ 
func newAtomDictionary*(): AtomDictionary =
  result = AtomDictionary()
  result.atoms = @[]
  result.atomMap = initTable[BipfBuffer, Atom]()

template hash(buffer: BipfBuffer): Hash =
  hash(ByteBuffer(buffer))  

func atomFor(dictionary: AtomDictionary, buffer: BipfBuffer): Atom =
  if dictionary.atomMap.hasKey(buffer):
    return dictionary.atomMap[buffer]
  else:
    let atom = Atom(dictionary.atoms.len.uint32)
    dictionary.atoms.add(buffer)
    dictionary.atomMap[buffer] = atom
    return atom
  if buffer in dictionary.atomMap:
    return dictionary.atomMap[buffer]
  else:
    let atom = Atom(dictionary.atoms.len.uint32)
    dictionary.atoms.add(buffer)
    dictionary.atomMap[buffer] = atom
    return atom ]#