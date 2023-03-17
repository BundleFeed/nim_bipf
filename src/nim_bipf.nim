import std/logging
import std/json
import tables

template wrapSideEffects(debug: bool, body: untyped) {.inject.} =
  when debug:
    {.noSideEffect.}:
      when defined(nimHasWarnBareExcept):
        {.push warning[BareExcept]:off.}
      try: body
      except: discard
      when defined(nimHasWarnBareExcept):
        {.pop.}
  else:
    body

template trace*(args: varargs[string, `$`]) =
  discard
  #wrapSideEffects(true):
  #  log(lvlDebug, args)

when not(defined(js)):
  import std/endians

when defined(js):
  import jsffi
  

  type Utf8String* = distinct JSObject # JS Uint8Array
  type ByteBuffer* = distinct JSObject # JS Uint8Array

  func byteLen*(v:Utf8String): int {.importjs: "#.length".}
  func `$`*(v:Utf8String): string {.importjs: "#".}
  func `[]`*(v:Utf8String, i:int): byte {.importjs: "#[#]".}

  func toUTF8String*(s: cstring) : Utf8String {.importjs: "new TextEncoder().encode(#)".}


  func newByteBuffer*(size: int): ByteBuffer {.importjs: "new Uint8Array(#)".}
  func len*(v:ByteBuffer): int {.importjs: "#.length".}
  func `[]=`*(v: ByteBuffer, i: int, b: byte) {.importjs: "#[#] = #".}
  func `[]`*(v: ByteBuffer, i: int): byte {.importjs: "#[#]".}
  func `$`*(v: ByteBuffer): string {.importjs: "#.toString()".}

  func set*(result: ByteBuffer, s: Utf8String, p: int) {.importjs: "#.set(#,#);".}
  func set*(result: ByteBuffer, s: ByteBuffer, p: int) {.importjs: "#.set(#,#);".}

  template writeUTF8*(result: ByteBuffer, s: Utf8String, p: var int) =
    trace "writeUTF8 ", result.len, " ", s.byteLen, " ", p
    if unlikely(s.byteLen == 0):
      discard
    else:
      set(result, s, p)
      p+=s.byteLen
    
  template writeBuffer*(result: ByteBuffer, s: ByteBuffer, p: var int) =
    if unlikely(s.len == 0):
      discard
    else:
      set(result, s, p)
      p+=s.len
    

else:
  type Utf8String* = distinct string
  type ByteBuffer* = distinct seq[byte]

  template byteLen*(v:Utf8String): int = v.string.len
  template `$`*(v:Utf8String): string = v.string
  template toUTF8String*(s: cstring) : Utf8String = Utf8String($s)
    

  template newByteBuffer*(size: int): ByteBuffer = ByteBuffer(newSeq[byte](size))
  template len*(v:ByteBuffer): int = (seq[byte](v)).len
  template `[]=`*(v: ByteBuffer, i: int, b: byte) = (seq[byte](v))[i] = b
  template `[]`*(v: ByteBuffer, i: int): byte = (seq[byte](v))[i]
  template `$`*(v: ByteBuffer): string = $(seq[byte](v))
    
  template address(v:Utf8String): ptr char = unsafeAddr(string(v)[0])
  template writeUTF8*(result: ByteBuffer, s: Utf8String, p: var int) =
    let l = s.byteLen
    if unlikely(l == 0):
      discard
    else:
      copyMem(result[p].addr, s.address, l)
      p+=l
  
  template writeBuffer*(result: ByteBuffer, s: ByteBuffer, p: var int) =
    let l = s.len
    if unlikely(l == 0):
      discard
    else:
      copyMem(result[p].addr, s[0].unsafeAddr, l)
      p+=l


type

  BipfValueError* = object of ValueError

  BipfTag = enum
    STRING   = 0, # (000) // utf8 encoded string
    BUFFER   = 1, # (001) // raw binary buffer
    INT      = 2, # (010) // little endian 32 bit integer
    DOUBLE   = 3, # (011) // little endian 64 bit float
    ARRAY    = 4, # (100) // sequence of any other value
    OBJECT   = 5, # (101) // sequence of alternating bipf encoded key and value
    BOOLNULL = 6, # (110) // 1 = true, 0 = false, no value means null
    EXTENDED = 7 # (111)  // custom type. Specific type should be indicated by varint at start of buffer

  BoolNullValue = enum
    TRUE,
    FALSE,
    NULL


  StackValue = object
    encodedSize : int
    case tag: BipfTag
    of STRING:
      str: Utf8String
    of BUFFER:
      buf: ByteBuffer
    of INT:
      i: int32
    of DOUBLE:
      d: float64
    of BOOLNULL:
      b: BoolNullValue
    of EXTENDED:
      ext: ByteBuffer
    else:
      size: int

  BipfBuilderObj = object
    stack    : seq[StackValue]
    pointers : seq[int]
  
  BipfBuilder* = ref BipfBuilderObj


template tagLen(v: int): int =
  assert v >= 0 and v <= high(int32)
  
  let u = v.uint32 shl 3
  if u < 0x80:
    1
  elif u < 0x4000:
    2
  elif u < 0x200000:
    3
  elif u < 0x10000000:
    4
  else:
    5

template toStackValue(value: typed): StackValue =
  when typeof(value) is Utf8String:
    StackValue(tag: STRING, str: value, encodedSize: value.byteLen)    
  elif typeof(value) is ByteBuffer:
    StackValue(tag: BUFFER, buf: value, encodedSize: value.len)
  elif typeof(value) is int32:
    StackValue(tag: INT, i: value, encodedSize: 4)
  elif typeof(value) is float64:
    StackValue(tag: DOUBLE, d: value, encodedSize: 8)
  elif typeof(value) is BoolNullValue:
    StackValue(tag: BOOLNULL, b: value, encodedSize: if (value == NULL): 0 else: 1)
  elif (typeof(value) is BipfTag):
    when value == ARRAY or value == OBJECT:
      StackValue(tag: value, size: 0, encodedSize: 0) ## size is set when the array/map is closed
  elif typeof(value) is StackValue:
    value


template addValueToStack*(b: BipfBuilder, value: typed) =
  trace "addValueToStack: ", value
  let v = toStackValue(value)
  if unlikely(b.pointers.len == 0):
    if unlikely(b.stack.len > 0):
      raise newException(BipfValueError, "Cannot add " & $value & " at root when root is not empty")
    when typeof(value) is BipfTag:
      when (value == OBJECT or value == ARRAY):
        b.pointers.add(b.stack.len)
    b.stack.add(v)
  else:
    let p = b.pointers[^1]
  
    if b.stack[p].tag == ARRAY:
      b.stack[p].size += 1
      var added = v.encodedSize
      when typeof(value) is BipfTag:
        when (value == OBJECT or value == ARRAY):
          b.pointers.add(b.stack.len)
        else:
          {.fatal: "Unreachable".}
      else:
        added += tagLen(v.encodedSize)
      b.stack[p].encodedSize += added
      b.stack.add(v)
    else:
      raise newException(BipfValueError, "Cannot add a value in a map without a key")

template addKeyedValueToStack*(b: BipfBuilder, key: Utf8String, value: typed) =
  trace "addValuaddKeyedValueToStackeToStack: ", key, " -> ", value
  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot add " & $value & " with a key at root")
  else:
    let p = b.pointers[^1]
    
    if b.stack[p].tag == OBJECT:
      b.stack[p].size += 1
      
      let k = toStackValue(key)
      b.stack.add(k)

      trace "add key to stack: ", k
      let v = toStackValue(value)

      var added = k.encodedSize + v.encodedSize + tagLen(k.encodedSize)

      when typeof(value) is BipfTag:
        when value == OBJECT or value == ARRAY:
          b.pointers.add(b.stack.len)
        else:
          {.fatal: "Unreachable".}
      else:
        added += tagLen(v.encodedSize)

      b.stack[p].encodedSize += added
      b.stack.add(v)
      trace "add value to stack: ", v
      trace "block stack value : ", b.stack[p]
    else:
      raise newException(BipfValueError, "Cannot add a value with a key in an array")
  

func newBipfBuilder*(): BipfBuilder =
  ## Creates a new BipfWriter.
  
  new(result)

func startMap*(b: BipfBuilder) =
  ## Starts a new map at root or in an array.
  addValueToStack(b, OBJECT)

func startMap*(b: BipfBuilder, key: sink Utf8String) =
  ## Starts a new map in a map.
  addKeyedValueToStack(b, key, OBJECT)

func startArray*(b: BipfBuilder) =
  ## Starts a new array.
  addValueToStack(b, ARRAY)

func startArray*(b: BipfBuilder, key: sink Utf8String) =
  ## Starts a new array in a map.
  addKeyedValueToStack(b, key, ARRAY)

func addInt*(b: BipfBuilder, i: sink int32) =
  ## Adds an integer to the current array.
  addValueToStack(b, i)

func addDouble*(b: BipfBuilder, d: sink float64) =
  ## Adds a double to the current array.
  addValueToStack(b, d)

func addString*(b: BipfBuilder, s: sink Utf8String) =
  ## Adds a string to the current array.
  addValueToStack(b, s)

func addBuffer*(b: BipfBuilder, buff: sink ByteBuffer) =
  ## Adds a buffer to the current array.
  addValueToStack(b, buff)

func addBool*(b: BipfBuilder, v: sink bool) =
  ## Adds a boolean to the current array.
  addValueToStack(b, if v: TRUE else: FALSE)

func addNull*(b: BipfBuilder) =
  ## Adds a null to the current array.
  addValueToStack(b, NULL)

func addExtended*(b: BipfBuilder, ext: sink ByteBuffer) =
  ## Adds an extended value to the current array.
  addValueToStack(b, StackValue(tag:EXTENDED, ext: ext))

func addInt*(b: BipfBuilder, k: sink Utf8String, i: sink int32) =
  ## Adds an integer to the current map.
  addKeyedValueToStack(b, k, i)

func addDouble*(b: BipfBuilder, k: sink Utf8String, d: sink float64) =
  ## Adds a double to the current map.
  addKeyedValueToStack(b, k, d)

func addString*(b: BipfBuilder, k: sink Utf8String, s: sink Utf8String) =
  ## Adds a string to the current map.
  addKeyedValueToStack(b, k, s)

func addBuffer*(b: BipfBuilder, k: sink Utf8String, buf: sink ByteBuffer) =
  ## Adds a buffer to the current map.
  addKeyedValueToStack(b, k, buf)

func addBool*(b: BipfBuilder, k: sink Utf8String, v: sink bool) =
  ## Adds a boolean to the current map.
  addKeyedValueToStack(b, k, if v: TRUE else: FALSE)

func addNull*(b: BipfBuilder, k: sink Utf8String) =
  ## Adds a null to the current map.
  addKeyedValueToStack(b, k, NULL)

func addExtended*(b: BipfBuilder, k: sink Utf8String, ext: sink ByteBuffer) =
  ## Adds an extended value to the current map.
  addKeyedValueToStack(b, k, StackValue(tag:EXTENDED, ext: ext))

template endBlock(b: BipfBuilder, blockTag: static BipfTag) =
  trace "endBlock: ", blockTag

  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
  else:
    let p = b.pointers.pop()
    var e = b.stack[p]
    trace "endBlock stack val: ", e
    if e.tag != blockTag:
      raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
    
    if (b.pointers.len > 0): # if we are not at root, update the size of the parent block
      let parentP = b.pointers[^1]
      trace "parent stack val: ", b.stack[parentP]
      b.stack[parentP].encodedSize += e.encodedSize + tagLen(e.encodedSize)
      trace "parent stack val: ", b.stack[parentP]


func endArray*(b: BipfBuilder) =
  ## Ends the current array.
  endBlock(b, ARRAY)

func endMap*(b: BipfBuilder) =
  ## Ends the current map.
  endBlock(b, OBJECT)


func addJson*(b: BipfBuilder, key: Utf8String, node: JsonNode)

func addJson*(b: BipfBuilder, node: JsonNode) =
  ## Adds a JsonNode to the current array.
  case node.kind
  of JNull:
    addNull(b)
  of JBool:
    addBool(b, node.getBool)
  of JInt:
    let i = node.getInt
    if i >= int32.low and i <= int32.high:
      addInt(b, i.int32)
    else:
      addDouble(b, i.float64)
  of JFloat:
    addDouble(b, node.getFloat)
  of JString:
    addString(b, node.getStr.toUTF8String)
  of JArray:
    startArray(b)
    for i in 0 ..< node.len:
      addJson(b, node[i])
    endArray(b)
  of JObject:
    startMap(b)
    for k, v in node.fields.pairs:
      addJson(b, k.toUTF8String, v)
    endMap(b)

func addJson*(b: BipfBuilder, key: Utf8String, node: JsonNode) =
  ## Adds a JsonNode to the current map.
  case node.kind
  of JNull:
    addNull(b, key)
  of JBool:
    addBool(b, key, node.getBool)
  of JInt:
    let i = node.getInt
    if i >= int32.low and i <= int32.high:
      addInt(b, key, i.int32)
    else:
      addDouble(b, key, i.float64)
  of JFloat:
    addDouble(b, key, node.getFloat)
  of JString:
    addString(b, key, node.getStr.toUTF8String)
  of JArray:
    startArray(b, key)
    for i in 0 ..< node.len:
      addJson(b, node[i])
    endArray(b)
  of JObject:
    startMap(b, key)
    for k, v in node.fields.pairs:
      addJson(b, k.toUTF8String, v)
    endMap(b)



template writeVarint(result: ByteBuffer, tag: int, p: var int) =
  assert tag >= 0 and tag <= high(int32)
  if tag < 0x80:
    result[p] = byte(tag)
    p+=1
  elif tag < 0x4000:
    result[p] = byte(tag or 0x80)
    result[p+1] = byte(tag shr 7)
    p+=2
  elif tag < 0x200000:
    result[p] = byte(tag or 0x80)
    result[p+1] = byte((tag shr 7) or 0x80)
    result[p+2] = byte(tag shr 14)
    p+=3
  elif tag < 0x10000000:
    result[p] = byte(tag or 0x80)
    result[p+1] = byte((tag shr 7) or 0x80)
    result[p+2] = byte((tag shr 14) or 0x80)
    result[p+3] = byte(tag shr 21)
    p+=4
  else:
    result[p] = byte(tag or 0x80)
    result[p+1] = byte((tag shr 7) or 0x80)
    result[p+2] = byte((tag shr 14) or 0x80)
    result[p+3] = byte((tag shr 21) or 0x80)
    result[p+4] = byte(tag shr 28)
    p+=5

template writeInt32LittleEndian(result: ByteBuffer, i: int32, p: var int) =
  when defined(js): # TODO: Should use Int32Array if available, or NodeJs Buffer is available
    result[p] = byte(i and 0xFF)
    result[p+1] = byte((i shr 8) and 0xFF)
    result[p+2] = byte((i shr 16) and 0xFF)
    result[p+3] = byte((i shr 24) and 0xFF)
  else:
    littleEndian32(cast[ptr uint32](result[p].addr), unsafeAddr i)
  p+=4

template writeFloat64LittleEndian(result: ByteBuffer, d: float64, p: var int) =
  when defined(js):  # TODO: Should use Float64Array if available, or NodeJs Buffer is available
    let i = int64(d)
    result[p] = byte(i and 0xFF)
    result[p+1] = byte((i shr 8) and 0xFF)
    result[p+2] = byte((i shr 16) and 0xFF)
    result[p+3] = byte((i shr 24) and 0xFF)
    result[p+4] = byte((i shr 32) and 0xFF)
    result[p+5] = byte((i shr 40) and 0xFF)
    result[p+6] = byte((i shr 48) and 0xFF)
    result[p+7] = byte((i shr 56) and 0xFF)
  else:
    littleEndian64(cast[ptr uint64](result[p].addr), unsafeAddr d)
  p+=8
  

  

func finish*(b: BipfBuilder): ByteBuffer =
  ## Finishes the current bipf document and returns the result.
  
  if b.pointers.len > 0:
    raise newException(BipfValueError, "Cannot finish document before ending all arrays and maps")
  if b.stack.len == 0:
    raise newException(BipfValueError, "Cannot finish document before adding any value")

  let encodedSize = b.stack[0].encodedSize
  result = newByteBuffer(encodedSize + tagLen(encodedSize))
  var p = 0
  for sv in b.stack:
    trace "writing stack value :", sv
    let tag = sv.tag.int + sv.encodedSize shl 3
    writeVarint(result, tag, p)
    case sv.tag:
      of OBJECT, ARRAY:
        discard
      of INT:
        writeInt32LittleEndian(result, sv.i, p)
      of DOUBLE:
        writeFloat64LittleEndian(result, sv.d, p)
      of BOOLNULL:
        case sv.b:
          of TRUE:
            result[p] = 1
            p+=1
          of FALSE:
            result[p] = 0
            p+=1
          of NULL:
            discard
      of STRING:
        writeUtf8(result, sv.str, p)
      of EXTENDED:
        writeBuffer(result, sv.ext, p)
      of BUFFER:
        writeBuffer(result, sv.buf, p)


