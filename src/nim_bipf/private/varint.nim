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


func writeVaruint32*[BB](buf: var BB, v: uint32, p: var int) {.inline.} =
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

template readVaruint32*[BB](data: BB, p: var int): uint32 =
  {.push checks:off.}  
  var b: uint8 = data[p]
  var result = uint32(b and 0x7f)
  inc p

  if (b and 0x80) != 0: 
    b = data[p]
    result += uint32(b and 0x7f) shl 7
    inc p
  
    if (b and 0x80) != 0:
      b = data[p]
      result += uint32(b and 0x7f) shl 14
      inc p
  
      if (b and 0x80) != 0:
        b = data[p]
        result += uint32(b and 0x7f) shl 21
        inc p
  
        if (b and 0x80) != 0: 
          b = data[p]
          result += uint32(b and 0x7f) shl 28
          inc p

          if (b and 0x80) != 0:
            raise newException(Exception, "Malformed Varint")
  {.pop.}
  result
  
      
