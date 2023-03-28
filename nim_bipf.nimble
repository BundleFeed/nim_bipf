# Package
packageName   = "nim_bipf"
version       = "0.1.0"
author        = "Geoffrey Picron"
description   = "BIPF encoding/decoding/transcoding"
license       = "Apache-2.0"
srcDir        = "src"



# Dependencies

requires "nim >= 1.6.10"

requires "https://github.com/nepeckman/jsExport.nim"
requires "chronicles >= 0.10.3"
requires "https://github.com/disruptek/criterion"
requires "node_binding"
requires "jsony"


task compilePureJs, "Compile to pure JS":
  exec "nim js -d:danger --app:lib  --rangeChecks:off  --boundChecks:off --sinkInference:on  --out:dist/nim_bipf.js --d:nodejs --mm:orc  src/js/index.nim"

task compilePureJsDebug, "Compile to pure JS (Debug)":
  exec "nim js --app:lib --sinkInference:on  --out:dist/nim_bipf.js --d:nodejs --mm:orc  src/js/index.nim"

task benchNim, "Benchmark Nim":
  exec "nim c -r -d:release --sinkInference:on --passC:-flto --passL:-flto --mm:orc --out:build/bench_encode tests/bench_encode.nim"

task benchJs, "Benchmark JS":
  compilePureJsTask()
  exec "node tests-js/benchmarks.js"

task compileNodeJsModule, "Build for NodeJS":
  #exec "$HOME/.nimble/bin/node_binding init -n " & $packageName & " -v " & version & " -d \"" & description &  "\" -a \"" & author & "\" -l \"" & license & "\""
  rmDir "dist/src"
  exec "nim c -c -d:danger --sinkInference:on --passC:-ffast-math --passC:-flto --passL:-flto --mm:orc --nimcache:dist/src src/js/nodejs/binding.nim"
  exec "npx cmake-js clean"
  exec "npx cmake-js build -l verbose "

task compileNodeJsModuleDebug, "Build for NodeJS":
  #exec "$HOME/.nimble/bin/node_binding init -n " & $packageName & " -v " & version & " -d \"" & description &  "\" -a \"" & author & "\" -l \"" & license & "\""
  rmDir "dist/src"
  exec "nim c -c -d:debug --sinkInference:on --passC:-flto --passL:-flto --mm:orc --nimcache:dist/src src/js/nodejs/binding.nim"
  exec "npx cmake-js clean"
  exec "npx cmake-js build --debug -l verbose"
