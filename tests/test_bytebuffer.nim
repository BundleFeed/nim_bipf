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

import unittest
import nim_bipf/private/backend/c
import nim_bipf/private/varint

import std/random

suite "byte buffer":
  test "varint":
    var r1 = initRand(123)
    for i in 0..100:
      let v = r1.rand(0.uint32..high(uint32))

      var buf = newByteBuffer(5)

      var p = 0
      buf.writeVaruint32(v, p)
      var p2 = 0
      let v2 = buf.readVaruint32(p2)

      check p == p2
      check v == v2