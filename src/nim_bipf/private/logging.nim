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

import std/logging


template wrapSideEffects(debug: bool, body: untyped) {.inject.} =
  when debug:
    {.noSideEffect.}:
      when defined(nimHasWarnBareExcept):
        {.push warning[BareExcept]:off.}
      try: body
      except Exception:
        log(lvlError, getCurrentExceptionMsg())
      when defined(nimHasWarnBareExcept):
        {.pop.}
  else:
    body

template trace*(args: varargs[string, `$`]) =
  when defined(release) or defined(warning):
    discard
  else:
    wrapSideEffects(true):
      log(lvlDebug, args)
