import std/json
import tables
import nim_bipf/private/logging
import nim_bipf/private/bytebuffer

export bytebuffer


type

  BipfValueError* = object of ValueError

  BipfTag* = enum
    STRING   = 0, # (000) // utf8 encoded string
    BUFFER   = 1, # (001) // raw binary buffer
    INT      = 2, # (010) // little endian 32 bit integer
    DOUBLE   = 3, # (011) // little endian 64 bit float
    ARRAY    = 4, # (100) // sequence of any other value
    OBJECT   = 5, # (101) // sequence of alternating bipf encoded key and value
    BOOLNULL = 6, # (110) // 1 = true, 0 = false, no value means null
    EXTENDED = 7 # (111)  // custom type. Specific type should be indicated by varint at start of buffer

  BoolNullValue* = enum
    TRUE,
    FALSE,
    NULL


  StackValue = object
    encodedSize : int
    case tag: BipfTag
    of STRING:
      str: NativeString
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

  BipfBuffer* = distinct ByteBuffer


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
  when typeof(value) is NativeString:
    StackValue(tag: STRING, str: value, encodedSize: lenUtf8(value))    
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
  
  var v = toStackValue(value)
  if unlikely(b.pointers.len == 0):
    if unlikely(b.stack.len > 0):
      raise newException(BipfValueError, "Cannot add value at root when root is not empty")
    when typeof(value) is BipfTag:
      when (value == OBJECT or value == ARRAY):
        b.pointers.add(b.stack.len)
    b.stack.add(move(v))
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
      b.stack.add(move(v))
    else:
      raise newException(BipfValueError, "Cannot add a value in a map without a key")

template addKeyedValueToStack*(b: BipfBuilder, key: NativeString, value: typed) =
  
  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot add value with a key at root")
  else:
    let p = b.pointers[^1]
    
    if b.stack[p].tag == OBJECT:
      b.stack[p].size += 1
      
      var k = toStackValue(key)
      var v = toStackValue(value)

      var added = k.encodedSize + v.encodedSize + tagLen(k.encodedSize)
      b.stack.add(move(k))

      when typeof(value) is BipfTag:
        when value == OBJECT or value == ARRAY:
          b.pointers.add(b.stack.len)
        else:
          {.fatal: "Unreachable".}
      else:
        added += tagLen(v.encodedSize)

      b.stack[p].encodedSize += added
      b.stack.add(move(v))
    else:
      raise newException(BipfValueError, "Cannot add a value with a key in an array")
  

func newBipfBuilder*(): BipfBuilder =
  ## Creates a new BipfWriter.
  
  new(result)

func startMap*(b: var BipfBuilder) =
  ## Starts a new map at root or in an array.
  addValueToStack(b, OBJECT)

func startMap*(b: var BipfBuilder, key: sink NativeString) =
  ## Starts a new map in a map.
  addKeyedValueToStack(b, key, OBJECT)

func startArray*(b: var BipfBuilder) =
  ## Starts a new array.
  addValueToStack(b, ARRAY)

func startArray*(b: var BipfBuilder, key: sink NativeString) =
  ## Starts a new array in a map.
  addKeyedValueToStack(b, key, ARRAY)

func addInt*(b: var BipfBuilder, i: sink int32) =
  ## Adds an integer to the current array.
  addValueToStack(b, i)

func addDouble*(b: var BipfBuilder, d: sink float64) =
  ## Adds a double to the current array.
  addValueToStack(b, d)

func addString*(b: var BipfBuilder, s: sink NativeString) =
  ## Adds a NativeString to the current array.
  addValueToStack(b, s)

func addBuffer*(b: var BipfBuilder, buff: sink ByteBuffer) =
  ## Adds a buffer to the current array.
  addValueToStack(b, buff)

func addBool*(b: var BipfBuilder, v: sink bool) =
  ## Adds a boolean to the current array.
  addValueToStack(b, if v: TRUE else: FALSE)

func addNull*(b: var BipfBuilder) =
  ## Adds a null to the current array.
  addValueToStack(b, NULL)

func addExtended*(b: var BipfBuilder, ext: sink ByteBuffer) =
  ## Adds an extended value to the current array.
  addValueToStack(b, StackValue(tag:EXTENDED, ext: ext))

func addInt*(b: var BipfBuilder, k: sink NativeString, i: sink int32) =
  ## Adds an integer to the current map.
  addKeyedValueToStack(b, k, i)

func addDouble*(b: var BipfBuilder, k: sink NativeString, d: sink float64) =
  ## Adds a double to the current map.
  addKeyedValueToStack(b, k, d)

func addString*(b: var BipfBuilder, k: sink NativeString, s: sink NativeString) =
  ## Adds a NativeString to the current map.
  addKeyedValueToStack(b, k, s)

func addBuffer*(b: var BipfBuilder, k: sink NativeString, buf: sink ByteBuffer) =
  ## Adds a buffer to the current map.
  addKeyedValueToStack(b, k, buf)

func addBool*(b: var BipfBuilder, k: sink NativeString, v: sink bool) =
  ## Adds a boolean to the current map.
  addKeyedValueToStack(b, k, if v: TRUE else: FALSE)

func addNull*(b: var BipfBuilder, k: sink NativeString) =
  ## Adds a null to the current map.
  addKeyedValueToStack(b, k, NULL)

func addExtended*(b: var BipfBuilder, k: sink NativeString, ext: sink ByteBuffer) =
  ## Adds an extended value to the current map.
  addKeyedValueToStack(b, k, StackValue(tag:EXTENDED, ext: ext))

template endBlock(b: var BipfBuilder, blockTag: static BipfTag) =

  if unlikely(b.pointers.len == 0):
    raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
  else:
    let p = b.pointers.pop()

    if b.stack[p].tag != blockTag:
      raise newException(BipfValueError, "Cannot end " & $blockTag & " before starting it")
    
    if (b.pointers.len > 0): # if we are not at root, update the size of the parent block
      let parentP = b.pointers[^1]
      let pEncodedSize = b.stack[p].encodedSize
      b.stack[parentP].encodedSize += pEncodedSize + tagLen(pEncodedSize)


func endArray*(b: var BipfBuilder) =
  ## Ends the current array.
  endBlock(b, ARRAY)

func endMap*(b: var BipfBuilder) =
  ## Ends the current map.
  endBlock(b, OBJECT)


func addJson*(b: var BipfBuilder, key: sink NativeString, node: sink JsonNode)

func addJson*(b: var BipfBuilder, node: sink JsonNode) =
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
    addString(b, NativeString(node.getStr))
  of JArray:
    startArray(b)
    for i in 0 ..< node.len:
      addJson(b, node[i])
    endArray(b)
  of JObject:
    startMap(b)
    for k, v in node.fields.pairs:
      addJson(b, NativeString(k), v)
    endMap(b)

func addJson*(b: var BipfBuilder, key: sink NativeString, node: sink JsonNode) =
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
    addString(b, key, NativeString(node.getStr))
  of JArray:
    startArray(b, key)
    for i in 0 ..< node.len:
      addJson(b, node[i])
    endArray(b)
  of JObject:
    startMap(b, key)
    for k, v in node.fields.pairs:
      addJson(b, NativeString(k), v)
    endMap(b)


func finish*(b: var BipfBuilder): BipfBuffer =
  ## Finishes the current bipf document and returns the result.
  
  if b.pointers.len > 0:
    raise newException(BipfValueError, "Cannot finish document before ending all arrays and maps")
  if b.stack.len == 0:
    raise newException(BipfValueError, "Cannot finish document before adding any value")

  let encodedSize = b.stack[0].encodedSize
  var r = newByteBuffer(encodedSize + tagLen(encodedSize))
  var p = 0
  for sv in b.stack:
    trace "writing stack value :", sv
    let tag = sv.tag.uint32 + sv.encodedSize.uint32 shl 3
    writeVaruint32(r, tag, p)
    case sv.tag:
      of OBJECT, ARRAY:
        discard
      of INT:
        writeInt32LittleEndian(r, sv.i, p)
      of DOUBLE:
        writeFloat64LittleEndian(r, sv.d, p)
      of BOOLNULL:
        case sv.b:
          of TRUE:
            r[p] = 1
            p+=1
          of FALSE:
            r[p] = 0
            p+=1
          of NULL:
            discard
      of STRING:
        writeUtf8(r, sv.str, p)
      of EXTENDED:
        writeBuffer(r, sv.ext, p)
      of BUFFER:
        writeBuffer(r, sv.buf, p)
  result = BipfBuffer(r)

# ---------------


type
  ByteBufferStream* = object
    buf*: ByteBuffer
    p*: int

  BipfPrefix* = object
    tag*: BipfTag
    size*: int

func newByteBufferStream*(buf: ByteBuffer, p: int = 0): ByteBufferStream =
  ## Creates a new ByteBufferStream.
  result.buf = buf
  result.p = p

func readPrefix*(s: var ByteBufferStream): BipfPrefix {.inline.} =
  ## Reads a prefix from the stream.
  let prefix = readVaruint32(s.buf, s.p)
  result.tag = BipfTag(prefix and 7)
  result.size = (prefix shr 3).int

func readInt32*(s: var ByteBufferStream): int32 {.inline.} =
  ## Reads an int32 from the stream.
  result = readInt32LittleEndian(s.buf, s.p)

func readFloat64*(s: var ByteBufferStream): float64 {.inline.} =
  ## Reads a float64 from the stream.
  result = readFloat64LittleEndian(s.buf, s.p)

func readByte*(s: var ByteBufferStream): byte {.inline.} =
  ## Reads a byte from the stream.
  result = s.buf[s.p]
  s.p += 1

template readUtf8*(s: var ByteBufferStream, len: int): NativeString =
  ## Reads a utf8 NativeString from the stream.
  readUtf8(s.buf, s.p, len)

template readBuffer*(s: var ByteBufferStream, len: int): ByteBuffer =
  ## Reads a buffer from the stream.
  readBuffer(s.buf, s.p, len)

func remaining*(s: var ByteBufferStream): int {.inline.} =
  ## Returns the number of bytes left in the stream.
  result = s.buf.len - s.p


# ---------------





type
  OffsetStackEntry = object
    ofs*: int
    tag*: BipfParserEventKind

  BipfParser*[S] = object
    stream: S
    offsetStack: seq[OffsetStackEntry]
    state: BipfParserState
    kind: BipfParserEventKind
    valueSize: int


  BipfParserEventKind* = enum
    bipfError, 
    bipfEndOfBipf,
    bipfStartArray, 
    bipfEndArray, 
    bipfStartMap, 
    bipfEndMap, 
    bipfKey,
    bipfString, 
    bipfInt, 
    bipfDouble, 
    bipfBoolNull, 
    bipfBuffer, 
    bipfExtended
  
  BipfParserState = enum
    psEnd, 
    psWaitMapKey,
    psWaitMapValue, 
    psWaitValue

  BipfTagToken* = object
    tag*: BipfTag
    size*: int
    endOfBlock*: bool

func next*[S](self: var BipfParser[S])

func newBipfParser*[S](stream: var S): BipfParser[S] =
  ## Creates a new BipfLexer.
  result.stream = stream
  result.state = psWaitValue
  result.kind = bipfError
  result.valueSize = stream.remaining
  result.offsetStack = @[OffsetStackEntry(ofs: stream.remaining, tag: bipfEndOfBipf)]
  next(result)
  trace "newBipfParser", result
  result.offsetStack[0].ofs = result.valueSize + stream.p 

func newBipfParser*(buf: ByteBuffer): BipfParser[ByteBufferStream] =
  ## Creates a new BipfParser from a ByteBuffer.
  var bufStream = newByteBufferStream(buf)
  result = newBipfParser(bufStream)
  
  
func kind*[S](self: BipfParser[S]): BipfParserEventKind {.inline.} =
  ## returns the current event type for the parser
  return self.kind

func next*[S](self: var BipfParser[S]) =
  ## move to the next event
  if unlikely(self.state == psEnd):
    self.kind = bipfError
  
  ## check if we are at the end of a map or array
  if self.offsetStack.len > 0:
    let ofs = self.offsetStack[^1].ofs
    if self.stream.p >= ofs:
      self.kind = self.offsetStack[^1].tag
      self.offsetStack.setLen(self.offsetStack.len - 1)
      
      if unlikely(self.offsetStack.len == 0):
        self.state = psEnd
        return

      ## check parent and determine if next is a key or value
      let parentTag = self.offsetStack[^1].tag
      case parentTag
      of bipfEndMap:
        self.state = psWaitMapKey
      else:
        self.state = psWaitValue
      
      return

  ## read tag and size, move pointer to value
  let key = readPrefix(self.stream)
  let tag = key.tag
  let size = key.size

  self.valueSize = size

  case tag
  of OBJECT:
    self.kind = bipfStartMap
    self.offsetStack.add(OffsetStackEntry(ofs: self.stream.p + size, tag: bipfEndMap))
    self.state = psWaitMapKey
  of ARRAY:
    self.kind = bipfStartArray
    self.offsetStack.add(OffsetStackEntry(ofs: self.stream.p + size, tag: bipfEndArray))
    self.state = psWaitValue
  of STRING:      
    if (self.state == psWaitMapValue):
      self.state = psWaitMapKey
      self.kind = bipfString
    elif (self.state == psWaitMapKey):
      self.kind = bipfKey
      self.state = psWaitMapValue
    else:
      self.kind = bipfString
  else:
    case tag
    of INT:
      self.kind = bipfInt
    of DOUBLE:
      self.kind = bipfDouble
    of BOOLNULL:
      self.kind = bipfBoolNull
      if (self.state == psWaitMapValue):
        self.state = psWaitMapKey
    of EXTENDED:
      self.kind = bipfExtended
    of BUFFER:
      self.kind = bipfBuffer
    else:
      raise newException(ValueError, "Invalid tag: " & $tag)

    ## wait for key 
    if (self.state == psWaitMapValue):
      self.state = psWaitMapKey



func readInt*[S](self: var BipfParser[S]): int {.inline.} =
  ## reads an int from the stream
  
  assert(self.kind == bipfInt and self.valueSize == 4)
  return readInt32(self.stream)

func readDouble*[S](self: var BipfParser[S]): float {.inline.} =
  ## reads a float from the stream
  assert(self.kind == bipfDouble and self.valueSize == 8)
  return readFloat64(self.stream)

func readBoolNull*[S](self: var BipfParser[S]): BoolNullValue {.inline.} =
  ## reads a bool from the stream
  assert(self.kind == bipfBoolNull and self.valueSize <= 1)

  if self.valueSize == 0:
    result = NULL
  else:
    if readByte(self.stream) == 1:
      result = TRUE
    else:
      result = FALSE

func readString*[S](self: var BipfParser[S]): NativeString {.inline.} =
  ## reads a NativeString from the stream
  assert(self.kind == bipfString)
  return readUtf8(self.stream, self.valueSize)

func readBuffer*[S](self: var BipfParser[S]): ByteBuffer {.inline.} =
  ## reads a buffer from the stream
  assert(self.kind == bipfBuffer)
  return readBuffer(self.stream, self.valueSize)

func readExtended*[S](self: var BipfParser[S]): ByteBuffer {.inline.} =
  ## reads an extended value from the stream
  assert(self.kind == bipfExtended)
  return readBuffer(self.stream, self.valueSize)

