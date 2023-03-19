# Package

version       = "0.1.0"
author        = "Geoffrey Picron"
description   = "BIPF encoding/decoding/transcoding"
license       = "Apache-2.0"
srcDir        = "src"



# Dependencies

requires "nim >= 1.6.10"

requires "https://github.com/nepeckman/jsExport.nim"
requires "chronicles >= 0.10.3"
requires "faststreams >= 0.3.0"


task compilePureJs, "Compile to pure JS":
  exec "nim js -d:release --app:lib  --rangeChecks:off  --boundChecks:off --sinkInference:on  --out:dist/nim_bipf.js --d:nodejs --mm:orc  src/nim_bipf_purejs.nim"

task compilePureJsDebug, "Compile to pure JS (Debug)":
  exec "nim js --app:lib --sinkInference:on  --out:dist/nim_bipf.js --d:nodejs --mm:orc  src/nim_bipf_purejs.nim"