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
  import jsffi
  
  type ByteBuffer* = distinct JSObject # JS Uint8Array
  type ArrayBuffer = distinct JSObject # JS ArrayBuffer
  type DataView = distinct JSObject # JS DataView
  type NativeString* = cstring

  func buffer*(a: ByteBuffer): ArrayBuffer {.importjs: "#.buffer".}
  func byteOffset*(a: ByteBuffer): int {.importjs: "#.byteOffset".}
  func byteLength*(a: ByteBuffer): int {.importjs: "#.byteLength".}
  func newDataView*(a: ArrayBuffer): DataView {.importjs: "new DataView(#)".}
  func getInt32*(a: DataView, p: int, l: bool): int32 {.importjs: "#.getInt32(#, #)".}
  func setInt32*(a: DataView, p: int, d: int32, l: bool) {.importjs: "#.setInt32(#, #, #)".}
  func getFloat64*(a: DataView, p: int, l: bool): float64 {.importjs: "#.getFloat64(#, #)".}
  func setFloat64*(a: DataView, p: int, d: float64, l: bool) {.importjs: "#.setFloat64(#, #, #)".}

  when defined(nodejs):
    func newByteBuffer*(size: int): ByteBuffer {.importjs: "Buffer.allocUnsafe(#)".}
  else:
    func newByteBuffer*(size: int): ByteBuffer {.importjs: "new Uint8Array(#)".}

  func newByteBuffer(buffer: ArrayBuffer, offset: int, size: int): ByteBuffer {.importjs: "new Uint8Array(@)".}
  func len*(v:ByteBuffer): int {.importjs: "#.length".}
  func `[]=`*(v: ByteBuffer, i: int, b: byte) {.importjs: "#[#] = #".}
  func `[]`*(v: ByteBuffer, i: int): byte {.importjs: "#[#]".}
  func `$`*(v: ByteBuffer): string {.importjs: "#.toString()".}

  func set*(bb: ByteBuffer, s: NativeString, p: int) {.importjs: "#.set(#,#);".}
  func set*(bb: ByteBuffer, s: ByteBuffer, p: int) {.importjs: "#.set(#,#);".}

  template writeBuffer*(result: ByteBuffer, s: ByteBuffer, p: var int) =
    if unlikely(s.len == 0):
      discard
    else:
      set(result, s, p)
      p+=s.len
    
  template readBuffer*(source: ByteBuffer, p: var int, l: int): ByteBuffer =
    if unlikely(l == 0):
      newByteBuffer(0)
    else:
      p+=l
      newByteBuffer(source.buffer(), p-l, l)

    
  when defined(nodejs):
    func bufferWriteInt32LittleEndian*(result: ByteBuffer, i: int32, p: int) {.importjs: "#.writeInt32LE(#, #)".}

    template writeInt32LittleEndian*(result: ByteBuffer, i: int32, p: var int) =
      bufferWriteInt32LittleEndian(result, i, p)
      p+=4

    func bufferWriteFloat64LittleEndian*(result: ByteBuffer, d: float64, p: int) {.importjs: "#.writeDoubleLE(#, #)".}

    template writeFloat64LittleEndian*(result: ByteBuffer, d: float64, p: var int) =
      bufferWriteFloat64LittleEndian(result, d, p)
      p+=8

    func bufferReadInt32LittleEndian*(source: ByteBuffer, p: int): int32 {.importjs: "#.readInt32LE(#)".}

    template readInt32LittleEndian*(source: ByteBuffer, p: var int): int32 =
      block:
        let result = bufferReadInt32LittleEndian(source, p)
        p+=4
        result

    func bufferReadFloat64LittleEndian*(source: ByteBuffer, p: int): float64 {.importjs: "#.readDoubleLE(#)".}

    template readFloat64LittleEndian*(source: ByteBuffer, p: var int): float64 =
      block:
        let result = bufferReadFloat64LittleEndian(source, p)
        p+=8
        result
    func lenUtf8*(s: NativeString): int {.importjs: "Buffer.byteLength(#)".}

    func bufferWriteUtf8*(result: ByteBuffer, s: NativeString, p: int): int {.importjs: "#.write(#, #)".}

    template writeUTF8*(result: ByteBuffer, s: NativeString, p: var int) =
      p += bufferWriteUtf8(result, s, p)

    func bufferReadUtf8*(source: ByteBuffer, p: int, pend: int): NativeString {.importjs: "#.toString('utf8', #, #)".}

    template readUTF8*(source: ByteBuffer, p: var int, len: int): NativeString =
      block:
        let result = bufferReadUtf8(source, p, p+len)
        p+=len
        result
  else:
    template writeInt32LittleEndian*(result: ByteBuffer, i: int32, p: var int) =
      newDataView(buffer(result)).setInt32(byteOffset(result) + p, i, true)
      p+=4

    template writeFloat64LittleEndian*(result: ByteBuffer, d: float64, p: var int) =
      newDataView(buffer(result)).setFloat64(byteOffset(result) + p, d, true)
      p+=8

    func readInt32LittleEndian*(source: ByteBuffer, p: var int): int32 {.inline.} =
      result =  newDataView(buffer(source)).getInt32(byteOffset(source) + p, true)
      p+=4

    func readFloat64LittleEndian*(source: ByteBuffer, p: var int): float64 {.inline.} =
      result =  newDataView(buffer(source)).getFloat64(byteOffset(source) + p, true)
      p+=8
    
    func lenUtf8*(s: NativeString): int {.importjs: "new TextEncoder().encode(#).length".} # todo optimize
    template writeUTF8*(result: ByteBuffer, s: NativeString, p: var int) =
      writeBuffer(result, cast[ByteBuffer]($s), p)

    template readUtf8*(source: ByteBuffer, p: var int, l: int): NativeString =
      let utf8String = cast[string](readBuffer(source, p, l))
      cast[NativeString](utf8String.cstring)    

else:
  import std/endians

  type ByteBuffer* = distinct seq[byte]
  type NativeString* = distinct string    

  template newByteBuffer*(size: int): ByteBuffer = ByteBuffer(newSeq[byte](size))
  template len*(v:ByteBuffer): int = (seq[byte](v)).len
  template `[]=`*(v: ByteBuffer, i: int, b: byte) = (seq[byte](v))[i] = b
  template `[]`*(v: ByteBuffer, i: int): byte = (seq[byte](v))[i]
  template `$`*(v: ByteBuffer): string = $(seq[byte](v))

  template lenUtf8*(s: NativeString): int = s.string.len
  
  template writeUTF8*(result: ByteBuffer, s: NativeString, p: var int) =
    let l = s.lenUtf8
    if unlikely(l == 0):
      discard
    else:
      copyMem(result[p].addr, unsafeAddr(s.string[0]), l)
      p+=l

  func readUtf8*(source: ByteBuffer, p: var int, l: int): NativeString {.inline.} =
    var r = newString(l)
    if unlikely(l == 0):
      discard
    else:
      copyMem(addr(r[0]), source[p].unsafeAddr, l)
      p+=l
    result = NativeString(r)
  
  template writeBuffer*(result: ByteBuffer, s: ByteBuffer, p: var int) =
    let l = s.len
    if unlikely(l == 0):
      discard
    else:
      copyMem(result[p].addr, s[0].unsafeAddr, l)
      p+=l

  func readBuffer*(source: ByteBuffer, p: var int, l: int): ByteBuffer {.inline.} =
    if unlikely(l == 0):
      result = newByteBuffer(0)
    else:
      result = newByteBuffer(l)
      copyMem(result[0].unsafeAddr, source[p].unsafeAddr, l)
      p+=l


  template writeInt32LittleEndian*(result: ByteBuffer, i: int32, p: var int) =
    littleEndian32(cast[ptr uint32](result[p].addr), unsafeAddr i)
    p+=4

  template writeFloat64LittleEndian*(result: ByteBuffer, d: float64, p: var int) =
    littleEndian64(cast[ptr uint64](result[p].addr), unsafeAddr d)
    p+=8

  func readInt32LittleEndian*(source: ByteBuffer, p: var int): int32 {.inline.} =
    littleEndian32(addr result, cast[ptr uint32](source[p]))
    p+=4
  
  func readFloat64LittleEndian*(source: ByteBuffer, p: var int): float64 {.inline.} =
    littleEndian64(addr result, cast[ptr uint64](source[p]))
    p+=8


func writeVaruint32*(buf: var ByteBuffer, v: uint32, p: var int) {.inline.} =
  if v < 0x80:
    buf[p] = byte(v)
    p+=1
  elif v < 0x4000:
    buf[p] = byte(v or 0x80)
    buf[p+1] = byte(v shr 7)
    p+=2
  elif v < 0x200000:
    buf[p] = byte(v or 0x80)
    buf[p+1] = byte((v shr 7) or 0x80)
    buf[p+2] = byte(v shr 14)
    p+=3
  elif v < 0x10000000:
    buf[p] = byte(v or 0x80)
    buf[p+1] = byte((v shr 7) or 0x80)
    buf[p+2] = byte((v shr 14) or 0x80)
    buf[p+3] = byte(v shr 21)
    p+=4
  else:
    buf[p] = byte(v or 0x80)
    buf[p+1] = byte((v shr 7) or 0x80)
    buf[p+2] = byte((v shr 14) or 0x80)
    buf[p+3] = byte((v shr 21) or 0x80)
    buf[p+4] = byte(v shr 28)
    p+=5

func readVaruint32*(data: ByteBuffer, p: var int): uint32 {.inline.} =
  result = 0
  var b: uint8
  b = data[p]
  result += uint32(b and 0x7f)
  p += 1

  if (b and 0x80) == 0: return result
  b = data[p]
  result += uint32(b and 0x7f) shl 7
  p += 1
  
  if (b and 0x80) == 0: return result
  b = data[p]
  result += uint32(b and 0x7f) shl 14
  p += 1
  
  if (b and 0x80) == 0: return result
  b = data[p]
  result += uint32(b and 0x7f) shl 21
  p += 1
  
  if (b and 0x80) == 0: return result
  b = data[p]
  result += uint32(b and 0x7f) shl 28
  p += 1
  
  if (b and 0x80) == 0: return result
  raise newException(Exception, "Malformed Varint")
  
      
