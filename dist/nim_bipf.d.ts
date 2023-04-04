export interface NodeJsBuffer { 
/* 
DistinctTy
  Sym "JsObject"
 */
}
export interface JsBipfBuffer { 
/* 
ObjectTy
  Empty
  Empty
  RecList
    IdentDefs
      Sym "buffer"
      Sym "NodeJsBuffer"
      Empty
 */
}
export interface CStringAtomDict { 
/* 
ObjectTy
  Empty
  OfInherit
    Sym "JsObject"
  RecList
    IdentDefs
      Sym "values"
      BracketExpr
        Sym "seq"
        Sym "cstring"
      Empty
    IdentDefs
      Sym "map"
      BracketExpr
        Sym "JsAssoc"
        Sym "cstring"
        Sym "AtomValue"
      Empty
 */
}
export function serialize(obj: any, maybeKeyDict: any): JsBipfBuffer
export function deserialize(bipf: JsBipfBuffer, maybeStartOrKeyDict: any, maybeKeyDict: any): any
export function newKeyDict(): any
export function encodingLength(obj: any): number/* int */
export function encode(obj: any, buffer: NodeJsBuffer, offset: number/* int */): number/* int */
export function allocAndEncode(obj: any): NodeJsBuffer
export function decode(buffer: NodeJsBuffer, maybeStart: number/* int */): any
export function seekPath(buffer: NodeJsBuffer, start: number/* int */, target: NodeJsBuffer, targetStart: number/* int */): number/* int */
export function seekKey(buffer: NodeJsBuffer, start: number/* int */, key: any): number/* int */
export function seekKey2(buffer: NodeJsBuffer, start: number/* int */, key: NodeJsBuffer, keyStart: number/* int */): number/* int */
export function seekKeyCached(buffer: NodeJsBuffer, start: number/* int */, key: string): number/* int */
export function slice(buffer: NodeJsBuffer, start: number/* int */): NodeJsBuffer
export function pluck(buffer: NodeJsBuffer, start: number/* int */): NodeJsBuffer
export function encodeIdempotent(obj: any, buffer: NodeJsBuffer, offset: number/* int */): number/* int */
export function markIdempotent(buffer: NodeJsBuffer): NodeJsBuffer
export function getEncodedLength(obj: NodeJsBuffer, start: number/* int */): number/* int */
export function getEncodedType(obj: NodeJsBuffer, start: number/* int */): any
export function allocAndEncodeIdempotent(obj: any): NodeJsBuffer
export function isIdempotent(s: any): boolean
export function iterate(objBuf: NodeJsBuffer, start: number/* int */, callback: any): number/* int */
export const types: any
export function createSeekPath(path: any): any
export function createCompareAt(paths: any): any
export function compare(b1: NodeJsBuffer, start1: number/* int */, b2: NodeJsBuffer, start2: number/* int */): number/* int */