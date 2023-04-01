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

when defined(js):
  {.fatal: "This module is not designed to be used with the JavaScript backend.".}

import std/endians

template lenUTF8*(s: cstring): int = s.len


type
    NimContext* = distinct int
    ByteBuffer* = distinct seq[byte]

const DEFAULT_CONTEXT* = NimContext(0)

template inputBufferType*(ctx: NimContext): typedesc = ByteBuffer

## ByteBuffer API

template newByteBuffer*(size: int): ByteBuffer = ByteBuffer(newSeq[byte](size))
func len*(x: ByteBuffer): int {.borrow.}
template `[]=`*(v: var ByteBuffer, i: int, b: byte) = (seq[byte](v))[i] = b
template `[]`*(v: ByteBuffer, i: int): byte = (seq[byte](v))[i]

template writeUTF8*(result: var ByteBuffer, s: string, p: var int) =
  let l = s.len
  if unlikely(l == 0):
    discard
  else:
    copyMem(result[p].addr, unsafeAddr(s[0]), l)
    p+=l

template writeUTF8*(result: ByteBuffer, s: cstring, p: var int) =
  let str = $s
  writeUTF8(result, str, p)

template copyBuffer*(result: var ByteBuffer, s: ByteBuffer, p: var int) =
  let l = s.len
  if unlikely(l == 0):
    discard
  else:
    copyMem(result[p].addr, s[0].unsafeAddr, l)
    p+=l

template writeInt32LittleEndian*(result: ByteBuffer, i: int32, p: var int) =
  littleEndian32(cast[ptr uint32](result[p].addr), unsafeAddr i)
  p+=4

func writeUInt32LittleEndianTrim*(result: var ByteBuffer, i: uint32, p: var int) =
  var v = i
  if i <= 255:
    result[p] = byte(v)
    p+=1
  elif i <= 65535:
    littleEndian16(cast[ptr uint16](result[p].addr), v.addr)
    p+=2
  elif i <= 16777215:
    result[p] = byte(v shr 16)
    result[p+1] = byte(v shr 8)
    result[p+2] = byte(v)
    p+=3
  else:
    let i: int = p
    littleEndian32(cast[ptr uint32](result[i].addr), v.addr)
    p+=4


template writeFloat64LittleEndian*(result: ByteBuffer, d: float64, p: var int) =
  littleEndian64(cast[ptr uint64](result[p].addr), unsafeAddr d)
  p+=8
