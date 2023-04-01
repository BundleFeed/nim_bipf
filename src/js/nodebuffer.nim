import std/jsffi

type 
  NodeJsBuffer* = distinct JsObject

func fromCString*(s: cstring): NodeJsBuffer {.importjs: "Buffer.from(#)".}
func len*(buffer: NodeJsBuffer): int {.importjs: "#.length".}
func toString*(buffer: NodeJsBuffer, start:int = 0, endExclusive: int = buffer.len): cstring {.importjs: "#.toString('utf8', @)".}
func subarray*(buffer: NodeJsBuffer, start:int = 0, endExclusive: int = buffer.len): NodeJsBuffer {.importjs: "#.subarray(@)".}
func readInt8*(buffer: NodeJsBuffer, offset: int=0): int8 {.importjs: "#.readInt8(@)".}
func readUInt8*(buffer: NodeJsBuffer, offset: int=0): uint8 {.importjs: "#.readUInt8(@)".}
func readInt16LE*(buffer: NodeJsBuffer, offset: int=0): int16 {.importjs: "#.readInt16LE(@)".}
func readInt16BE*(buffer: NodeJsBuffer, offset: int=0): int16 {.importjs: "#.readInt16LE(@)".}
func readUInt16LE*(buffer: NodeJsBuffer, offset: int=0): uint16 {.importjs: "#.readUInt16LE(@)".}
func readUInt16BE*(buffer: NodeJsBuffer, offset: int=0): uint16 {.importjs: "#.readUInt16LE(@)".}
func readInt32LE*(buffer: NodeJsBuffer, offset: int=0): int32 {.importjs: "#.readInt32LE(@)".}
func readInt32BE*(buffer: NodeJsBuffer, offset: int=0): int32 {.importjs: "#.readInt32LE(@)".}
func readUInt32LE*(buffer: NodeJsBuffer, offset: int=0): uint32 {.importjs: "#.readUInt32LE(@)".}
func readUInt32BE*(buffer: NodeJsBuffer, offset: int=0): uint32 {.importjs: "#.readUInt32LE(@)".}
func readFloatLE*(buffer: NodeJsBuffer, offset: int=0): float32 {.importjs: "#.readFloatLE(@)".}
func readFloatBE*(buffer: NodeJsBuffer, offset: int=0): float32 {.importjs: "#.readFloatLE(@)".}
func readDoubleLE*(buffer: NodeJsBuffer, offset: int=0): float64 {.importjs: "#.readDoubleLE(@)".}
func readDoubleBE*(buffer: NodeJsBuffer, offset: int=0): float64 {.importjs: "#.readDoubleLE(@)".}

func compare*(source: NodeJsBuffer, target: NodeJsBuffer, targetStart: int, targetEnd: int, sourceStart: int, sourceEnd: int): int {.importjs: "#.compare(@)".}      

func `[]`*(buffer: NodeJsBuffer, p: int): byte {.importjs: "#[#]".}


