export interface NodeJsBuffer { 
/* 
DistinctTy
  Sym "JsObject"
 */
}
export interface BipfBuffer { 
/* 
DistinctTy
  Sym "ByteBuffer"
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
export function serialize(obj: any, maybeKeyDict: any): BipfBuffer
export function deserialize(buffer: BipfBuffer, maybeStartOrKeyDict: any, maybeKeyDict: any): any
export function newKeyDict(): any
export function encodingLength(obj: any): number/* int */
export function encode(obj: any, buffer: NodeJsBuffer, offset: number/* int */): number/* int */
export function allocAndEncode(obj: any, maybeKeyDict: any): BipfBuffer
export function decode(buffer: BipfBuffer, maybeStartOrKeyDict: any, maybeKeyDict: any): any
export function seekPath(buffer: BipfBuffer, start: number/* int */, target: BipfBuffer, targetStart: number/* int */): number/* int */
export function seekKey(buffer: BipfBuffer, start: number/* int */, key: any): number/* int */
export function seekKey2(buffer: BipfBuffer, start: number/* int */, key: BipfBuffer, keyStart: number/* int */): number/* int */
export function seekKeyCached(buffer: BipfBuffer, start: number/* int */, key: string): number/* int */
export function slice(buffer: BipfBuffer, start: number/* int */): any
export function pluck(buffer: BipfBuffer, start: number/* int */): any
export function encodeIdempotent(obj: any, buffer: NodeJsBuffer, offset: number/* int */): number/* int */
export function markIdempotent(buffer: BipfBuffer): BipfBuffer
export function getEncodedLength(obj: BipfBuffer, start: number/* int */): number/* int */
export function getEncodedType(obj: BipfBuffer, start: number/* int */): any
export function allocAndEncodeIdempotent(obj: any, maybeKeyDict: any): BipfBuffer
export function isIdempotent(s: any): boolean
export function iterate(objBuf: BipfBuffer, start: number/* int */, callback: any): number/* int */
export const types: any
export function createSeekPath(path: any): any
export function createCompareAt(paths: any): any
export function compare(b1: BipfBuffer, v1: number/* int */, b2: BipfBuffer, v2: number/* int */): number/* int */