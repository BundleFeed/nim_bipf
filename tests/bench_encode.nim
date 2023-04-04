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
when compileOption("profiler"):
  import nimprof

import criterion

var cfg = newDefaultConfig()
cfg.verbose = true


import nim_bipf/private/backend/c
import nim_bipf
import nim_bipf/serde_json
import json

let fakeData = parseFile("tests/fakeData.json")
let fakeData2 = parseFile("tests/fakeData2.json")
let pkg = parseFile("package.json")

benchmark cfg:
  func simpleEncode(root: JsonNode) : int =
    var builder = newBipfBuilder[NimContext](DEFAULT_CONTEXT)
    builder.addJsonNode(root)
    result = builder.finish().len

  iterator argFactory(): JsonNode =
    for data in [fakeData, fakeData2, pkg]:
      yield data

  proc benchEncode(x: JsonNode) {.measure: argFactory.} =
    blackBox simpleEncode(x)
