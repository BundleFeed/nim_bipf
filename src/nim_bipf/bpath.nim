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
import private/logging

type
  BipfQueryOpCode = enum
    MatchKey

  BipfQueryOp[ByteBuffer] = object
    case opCode: BipfQueryOpCode
    of MatchKey:
      prefix: BipfPrefix
      key: ByteBuffer
  

  BPath*[ByteBuffer] = seq[BipfQueryOp[ByteBuffer]]
  BPathRef*[ByteBuffer] = ref BPath[ByteBuffer]


func compileSimplePath*[ByteBuffer](path: openarray[ByteBuffer]): BPath[ByteBuffer] =
  result = @[]
  for key in path:
    let keyPrefix = (key.len.uint32 shl 3) or BipfTag.STRING.uint32
    result.add BipfQueryOp[ByteBuffer](opCode: MatchKey, prefix: BipfPrefix(keyPrefix), key: key)

import strutils
#[
func compilePath*[KD:ref](path: string, keyDict: KD): BPath[ByteBuffer] =
  result = @[]
  for key in path.split('.'):
    when compiles(keyDict.atomFor(key)):
      let atom = keyDict.atomFor(key)
      let keyPrefix = (atom.len.uint32 shl 3) or BipfTag.STRING.uint32
      var builder = newBipfBuilder()
      builder.addAtom(atom)
      let buffer = builder.finish()




    else:
      let key = key.toBytes()
    let keyPrefix = (key.len.uint32 shl 3) or BipfTag.STRING.uint32
    result.add BipfQueryOp[ByteBuffer](opCode: MatchKey, prefix: BipfPrefix(keyPrefix), key: key)
 ]#

func runBPath*[BipfBuffer, ByteBuffer](buffer: BipfBuffer, path: BPath[ByteBuffer], start: int = 0): int =
  var p = start
  for op in path:
    case op.opCode:
      of MatchKey:
        let opPrefix = op.prefix
        let opKey = op.key

        let prefix = buffer.readPrefix(p)

        if prefix.tag != BipfTag.OBJECT: 
          return -1

        let endOffset = p + prefix.size
        while p < endOffset:  
          let prefix = buffer.readPrefix(p)

          if prefix == opPrefix and buffer.equals(opKey, p):
            p += prefix.size
            break
          p += prefix.size
          buffer.skipNext(p)

        if p >= endOffset:
          return -1
  return p




