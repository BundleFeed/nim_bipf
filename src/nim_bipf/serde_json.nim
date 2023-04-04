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

import std/json, common, builder
import private/backend/c


func dnKind*(n: JsonNode): DynNodeKind  =
  case n.kind
  of JNull: nkNull
  of JBool: nkBool
  of JInt: 
    let i = n.getInt
    when sizeof(i) == 4:
      nkInt
    else:
      if i.int64 <= int32.high and i >= int32.low:
        nkInt
      else:
        nkDouble
  of JFloat: nkDouble
  of JString: nkString
  of JArray: nkArray
  of JObject: nkMap

converter toInt32*(n: JsonNode): int32             = n.getInt.int32
converter toDouble*(n: JsonNode): float64        = n.getFloat
converter toString*(n: JsonNode): string         = n.getStr
converter toBool*(n: JsonNode): bool             = n.getBool 
converter toInputBuffer*(n: JsonNode): ByteBuffer     = raise newException(BipfValueError, "Cannot convert JsonNode to ByteBuffer")
converter toBipfBuffer*(n: JsonNode): BipfBuffer[ByteBuffer] = raise newException(BipfValueError, "Cannot convert JsonNode to BipfBuffer")
converter toAtom*(n: JsonNode): AtomValue             = raise newException(BipfValueError, "Cannot convert JsonNode to Atom")

template dnItems*(n: JsonNode): JsonNode = n.items
iterator dnPairs*(n: JsonNode): (string, JsonNode) = 
  for k, v in n.pairs:
    yield (k, v)

proc addJsonNode*(b: var BipfBuilder, key: sink string, node: JsonNode) {.inline.} =
  addNodeWithKey(b, key, node)

proc addJsonNode*(b: var BipfBuilder, node: JsonNode) {.inline.} =
  addNode(b, node)


### variation using jsony

import jsony
import std/strutils

type 
  NonKeyedNodeContext[Builder: BipfBuilder] = object
    b: Builder
  
  KeyedNodeContext[Builder: BipfBuilder] = object
    b: Builder
    key: string
  
  NodeContext = KeyedNodeContext | NonKeyedNodeContext   

proc parseHook*(s: SomeInputString, i: var int, v: var NodeContext) =
  
  var builder = v.b

  ## Parses a regular json node.
  eatSpace(s, i)
  if unlikely(i >= s.len):
    raise newException(ValueError, "unexpected end of json")

  case s[i]
  of '{':  
    when typeof(v) is KeyedNodeContext:
      v.b.startMap(v.key)
    else:
      v.b.startMap()
    eatChar(s, i, '{')
    while i < s.len:
      eatSpace(s, i)
      if i < s.len and s[i] == '}':
        break
      var mapEntry = KeyedNodeContext[typeof(v.b)](b: builder)
      parseHook(s, i, mapEntry.key)
      eatChar(s, i, ':')
      parseHook(s, i, mapEntry)
      eatSpace(s, i)
      if i < s.len and s[i] == ',':
        inc i
    eatChar(s, i, '}')
    v.b.endMap()
  of '[':
    var builder = builder
    when typeof(v) is KeyedNodeContext:
      
      var key = newString(v.key.len)
      for i in 0..<v.key.len:
        key[i] = v.key[i]

      builder.startArray(key)
      
    else:
      
      builder.startArray()
    
    eatChar(s, i, '[')
    
    while i < s.len:
      eatSpace(s, i)
      if i < s.len and s[i] == ']':
        break
      var element = NonKeyedNodeContext[typeof(v.b)](b: builder)
      parseHook(s, i, element)
      eatSpace(s, i)
      if i < s.len and s[i] == ',':
        inc i

    eatChar(s, i, ']')
    v.b.endArray()
  of '"':
    var str: string
    parseHook(s, i, str)
    when typeof(v) is KeyedNodeContext:
      v.b.addString(v.key, str)
    else:
      v.b.addString(str)
  of 't':
    if i + 3 < s.len and
      s[i+1] == 'r' and
      s[i+2] == 'u' and
      s[i+3] == 'e':
      i += 4
      when typeof(v) is KeyedNodeContext:
        v.b.addBool(v.key, true)
      else:
        v.b.addBool(true)
  of 'f':
    if i + 4 < s.len and
      s[i+1] == 'a' and
      s[i+2] == 'l' and
      s[i+3] == 's' and
      s[i+4] == 'e':
      i += 5
      when typeof(v) is KeyedNodeContext:
        v.b.addBool(v.key, false)
      else:
        v.b.addBool(false)
  of 'n':
    if i + 3 < s.len and
      s[i+1] == 'u' and
      s[i+2] == 'l' and
      s[i+3] == 'l':
      i += 4
      when typeof(v) is KeyedNodeContext:
        v.b.addNull(v.key)
      else:
        v.b.addNull()            
  of {'0'..'9', '-', '+'}:
    var data = parseSymbol(s, i)
    if {'.', 'e', 'E'} in data:
      let f : float64 = parseFloat(data)
      when typeof(v) is KeyedNodeContext:
        v.b.addDouble(v.key, f)
      else:
        v.b.addDouble(f)
    else:
      let i : int64 = parseInt(data)
      if i >= int32.low.int64 and i <= int32.high.int64:
        when typeof(v) is KeyedNodeContext:
          v.b.addInt(v.key, i.int32)
        else:
          v.b.addInt(i.int32)
      else:
        when typeof(v) is KeyedNodeContext:
          v.b.addDouble(v.key, i.float64)
        else:
          v.b.addDouble(i.float64)
  else:
    raise newException(ValueError, "Invalid json at : " & $i & " was following :" & $s[i.. min(s.len, i+10)])
    
  
proc addJson*(b: var BipfBuilder, input: sink openArray[char]) =

  var ctx = NonKeyedNodeContext[typeof(b)](b: b)
  var i = 0
  parseHook(input, i, ctx)



