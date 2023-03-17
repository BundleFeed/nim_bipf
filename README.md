<!--
 Copyright 2023 Geoffrey Picron
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# Nim BIPF

BIPF is a binary format for data interchange, designed to be compact and fast to parse.

This library provides a Nim implementation of BIPF, with support for both reading and writing.

## Usage

### Writing

```nim
import bipf

var w = newBipfWriter()
w.writeMap()
w.writeKey("hello")
w.writeStr("world")
w.writeKey("answer")
w.writeInt(42)
w.writeKey("pi")
w.writeFloat(3.141592)
w.writeKey("array")
w.writeArray()
w.writeInt(1)
w.writeInt(2)
w.writeInt(3)
w.writeInt(4)
w.writeInt(5)
w.writeEnd()
w.writeKey("object")
w.writeMap()
w.writeKey("a")
w.writeInt(1)
w.writeKey("b")
w.writeInt(2)
w.writeKey("c")
w.writeInt(3)
w.writeEnd()
w.writeEnd()

echo w.result()
```

### Reading

```nim
import bipf

var r = newBipfReader(w.result())
r.readMap()
while r.next():
  echo r.key()
  case r.kind()
  of BIPF_INT: echo r.readInt()
  of BIPF_STR: echo r.readStr()
  of BIPF_FLOAT: echo r.readFloat()
  of BIPF_ARRAY: r.skip()
  of BIPF_MAP: r.skip()
  else: echo "unknown type"
```

## License

Apache-2.0