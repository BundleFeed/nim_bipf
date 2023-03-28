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
import reader
import private/bytebuffer


func findKey(buffer: BipfBuffer, key: sink ByteBuffer, keyPrefix: uint32, start: int): int =
  result = -1
  var p = start

  let prefix = buffer.readPrefix(p)
  if prefix.tag == BipfTag.OBJECT:
    let endOffset = p + prefix.size

    while p < endOffset:
      let prefix = buffer.readPrefix(p)

      if prefix.uint32 == keyPrefix and ByteBuffer(buffer).equals(key, p):
        p += prefix.size
        result = p
        break
      p += prefix.size
      buffer.skipNext(p)  
  
  

func findKey*(buffer: BipfBuffer, key: sink ByteBuffer, start: int = 0): int =
  let keyPrefix = (key.len.uint32 shl 3) or BipfTag.STRING.uint32
  result = findKey(buffer, key, keyPrefix, start)

func findKey*(buffer: BipfBuffer, key: sink BipfBuffer, start: int = 0, keyStart: int = 0): int =
  var pKey = keyStart
  let keyPrefix = key.readPrefix(pKey)
  if keyPrefix.tag != BipfTag.STRING:
    raise newException(BipfValueError, "key must be encoded string")
  let keyBuffer = key.readBufferValue(pKey, keyPrefix.size)

  result = findKey(buffer, keyBuffer, keyPrefix.uint32, start)

#  ---------------------------------------------------------------------------

