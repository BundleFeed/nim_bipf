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

import private/bytebuffer

export ByteBuffer

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
    BOOLNULL = 6, # (110) // 1 = true, 0 = false, no value means null
    EXTENDED = 7 # (111)  // custom type. Specific type should be indicated by varint at start of buffer

  BoolNullValue* = enum
    TRUE,
    FALSE,
    NULL

  BipfPrefix* = distinct uint32

  BipfBuffer* = distinct ByteBuffer
  


# BipfPrefix helpers

template tag*(prefix: BipfPrefix): BipfTag = BipfTag(prefix.uint32 and 7)
template size*(prefix: BipfPrefix): int = (prefix.uint32 shr 3).int
template prefix*(tag: BipfTag, size: int): BipfPrefix = BipfPrefix((size.uint32 shl 3) or tag)
template `==`*(a, b: BipfPrefix): bool = a.uint32 == b.uint32
template `$`*(p: BipfPrefix): string = "(" & $p.tag & "," & $p.size & ")"

    
    
# ------------------------------

# BipfBuffer helpers

func len*(x: BipfBuffer): int {.borrow.}
template `[]`*(v: BipfBuffer, i: int): byte = (ByteBuffer(v))[i]
template `[]`*(v: BipfBuffer, i: HSlice[system.int, system.int]): byte = (ByteBuffer(v))[i]



func skipNext*[Bi](buffer: Bi, p: var int) {.inline.} =
  let prefix = buffer.readPrefix(p)
  p += prefix.size