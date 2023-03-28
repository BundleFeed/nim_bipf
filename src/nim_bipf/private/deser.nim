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

import ../common



## Deserialization algorithm

proc deserializeNext[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int): DynNode

template deserializeMap[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int, size: int): DynNode =
  var result = factory.newMap()
  let endOffset = p + size
  while p < endOffset:
    let prefix = buffer.readPrefix(p)
    assert prefix.tag == BipfTag.STRING, "Expected string, got [formely 'required type:string']: " 

    let key = factory.readStringNode(buffer, p, prefix.size)
    let value = deserializeNext[Factory, DynNode, BipfBuffer](factory, buffer, p)
    factory.setEntry(result, key, value)
  result

template deserializeArray[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int, size: int): DynNode =
  var stack : seq[DynNode] = @[]
  let endOffset = p + size
  while p < endOffset:
    stack.add(deserializeNext[Factory, DynNode, BipfBuffer](factory, buffer, p))
  factory.newArray(stack)

proc deserializeNext[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int): DynNode =
  let prefix = buffer.readPrefix(p)
  let size = prefix.size
  let tag = prefix.tag

  result = case tag
          of BipfTag.STRING:   factory.readStringNode(buffer, p, size)
          of BipfTag.BUFFER:   factory.readBufferNode(buffer, p, size)
          of BipfTag.INT:      factory.readIntNode(buffer, p, size)
          of BipfTag.DOUBLE:   factory.readDoubleNode(buffer, p, size)
          of BipfTag.ARRAY:    deserializeArray[Factory, DynNode, BipfBuffer](factory, buffer, p, size)
          of BipfTag.OBJECT:   deserializeMap[Factory, DynNode, BipfBuffer](factory, buffer, p, size)
          of BipfTag.BOOLNULL: factory.readBoolNullNode(buffer, p, size)
          of BipfTag.EXTENDED: factory.readBufferNode(buffer, p, size)



proc deserialize*[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, at: int = 0): DynNode {.inline.} =
  var p = at
  result = deserializeNext[Factory, DynNode, BipfBuffer](factory, buffer, p)



proc parseHookMap[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int, k: DynNode, parentMap: var DynNode)

proc parseHookArray[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int, stack: var seq[DynNode]) =
  let prefix = buffer.readPrefix(p)
  let size = prefix.size
  let tag = prefix.tag

  case tag
  of BipfTag.STRING: stack.add(factory.readStringNode(buffer, p, size))
  of BipfTag.BUFFER: stack.add(factory.readBufferNode(buffer, p, size))
  of BipfTag.INT:   stack.add(factory.readIntNode(buffer, p, size))
  of BipfTag.DOUBLE: stack.add(factory.readDoubleNode(buffer, p, size))
  of BipfTag.ARRAY:
    var childs = newSeq[DynNode]()
    let endOffset = p + size
    while p < endOffset:
      parseHookArray[Factory, DynNode, BipfBuffer](factory, buffer, p, childs)

    stack.add(factory.newArray(childs))
  of BipfTag.OBJECT:
    var map = factory.newMap()
    let endOffset = p + size
    while p < endOffset:
      let kPrefix = buffer.readPrefix(p)
      assert kPrefix.tag == BipfTag.STRING, "Expected string, got [formely 'required type:string']: "

      let key = factory.readStringNode(buffer, p, kPrefix.size)
      parseHookMap[Factory, DynNode, BipfBuffer](factory, buffer, p, key, map)

    stack.add(map)
  of BipfTag.BOOLNULL: stack.add(factory.readBoolNullNode(buffer, p, size))
  of BipfTag.EXTENDED: stack.add(factory.readBufferNode(buffer, p, size))

proc parseHookMap[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, p: var int, k: DynNode, parentMap: var DynNode) =
  let prefix = buffer.readPrefix(p)
  let size = prefix.size
  let tag = prefix.tag

  case tag
  of BipfTag.STRING: factory.setEntry(parentMap, k, factory.readStringNode(buffer, p, size))
  of BipfTag.BUFFER: factory.setEntry(parentMap, k, factory.readBufferNode(buffer, p, size))
  of BipfTag.INT:   factory.setEntry(parentMap, k, factory.readIntNode(buffer, p, size))
  of BipfTag.DOUBLE: factory.setEntry(parentMap, k, factory.readDoubleNode(buffer, p, size))
  of BipfTag.ARRAY:
    var childs = newSeq[DynNode]()
    let endOffset = p + size
    while p < endOffset:
      parseHookArray[Factory, DynNode, BipfBuffer](factory, buffer, p, childs)

    factory.setEntry(parentMap, k, factory.newArray(childs))
  of BipfTag.OBJECT:
    var map = factory.newMap()
    let endOffset = p + size
    while p < endOffset:
      let kPrefix = buffer.readPrefix(p)
      assert kPrefix.tag == BipfTag.STRING, "Expected string, got [formely 'required type:string']: "

      let key = factory.readStringNode(buffer, p, kPrefix.size)
      parseHookMap[Factory, DynNode, BipfBuffer](factory, buffer, p, key, map)

    factory.setEntry(parentMap, k, map)
  of BipfTag.BOOLNULL: factory.setEntry(parentMap, k, factory.readBoolNullNode(buffer, p, size))
  of BipfTag.EXTENDED: factory.setEntry(parentMap, k, factory.readBufferNode(buffer, p, size))


proc deserializeB*[Factory, DynNode, BipfBuffer](factory: var Factory, buffer: BipfBuffer, at: int = 0): DynNode {.inline.} =
  var p = at
  var ctx = newSeqOfCap[DynNode](1)
  parseHookArray[Factory, DynNode, BipfBuffer](factory, buffer, p, ctx)
  result = ctx[0]


