/* Generated by Nim Compiler v1.9.3 */
#define NIM_INTBITS 64

#include "nimbase.h"
#undef LANGUAGE_C
#undef MIPSEB
#undef MIPSEL
#undef PPC
#undef R3000
#undef R4000
#undef i386
#undef linux
#undef mips
#undef near
#undef far
#undef powerpc
#undef unix
#define nimfr_(x, y)
#define nimln_(x, y)
typedef struct NimStrPayload NimStrPayload;
typedef struct NimStringV2 NimStringV2;
struct NimStrPayload {
NI cap;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct NimStringV2 {
NI len;
NimStrPayload* p;
};
static N_INLINE(NIM_BOOL, lteqpercent___system_1086)(NI32 x__iaAkA6each9ctoBel6MBPcw, NI32 y__vNzXEOBEdWZoQ54adxNLpg);
N_LIB_PRIVATE N_NIMCALL(void, setLengthStrV2)(NimStringV2* s__19atMbr42TbRkrQSPFxaPZg, NI newLen__zdmruIpEqwmFKxid9btfbJw);
static N_INLINE(void, nimPrepareStrMutationV2)(NimStringV2* s__loo5Z73wZsb5OCeQPiUDYg);
N_LIB_PRIVATE N_NIMCALL(void, nimPrepareStrMutationImpl__system_2401)(NimStringV2* s__9azXNueo9acOrj8WVyZabYtg);
static const struct {
  NI cap; NIM_CHAR data[0+1];
} TM__e1RUVS0Bw7xmj9cnDPXLJMQ_2 = { 0 | NIM_STRLIT_FLAG, "" };
static const NimStringV2 TM__e1RUVS0Bw7xmj9cnDPXLJMQ_3 = {0, (NimStrPayload*)&TM__e1RUVS0Bw7xmj9cnDPXLJMQ_2};
static N_INLINE(NIM_BOOL, lteqpercent___system_1086)(NI32 x__iaAkA6each9ctoBel6MBPcw, NI32 y__vNzXEOBEdWZoQ54adxNLpg) {
	NIM_BOOL result;
	result = (NIM_BOOL)0;
	result = ((NU32)(((NU32) (x__iaAkA6each9ctoBel6MBPcw))) <= (NU32)(((NU32) (y__vNzXEOBEdWZoQ54adxNLpg))));
	return result;
}
static N_INLINE(void, nimPrepareStrMutationV2)(NimStringV2* s__loo5Z73wZsb5OCeQPiUDYg) {
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = !(((*s__loo5Z73wZsb5OCeQPiUDYg).p == ((NimStrPayload*) NIM_NIL)));
		if (!(T3_)) goto LA4_;
		T3_ = ((NI)((*(*s__loo5Z73wZsb5OCeQPiUDYg).p).cap & ((NI)IL64(4611686018427387904))) == ((NI)IL64(4611686018427387904)));
		LA4_: ;
		if (!T3_) goto LA5_;
		nimPrepareStrMutationImpl__system_2401(s__loo5Z73wZsb5OCeQPiUDYg);
	}
	LA5_: ;
}
N_LIB_PRIVATE N_NIMCALL(NimStringV2, nuctoUTF8)(NI32 c__qKfQ25ISMelofGeRKFBIIw) {
	NimStringV2 result;
	NI32 iX60gensym21_;
	result.len = 0; result.p = NIM_NIL;
	result = TM__e1RUVS0Bw7xmj9cnDPXLJMQ_3;
	iX60gensym21_ = c__qKfQ25ISMelofGeRKFBIIw;
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)127));
		if (!T3_) goto LA4_;
		setLengthStrV2((&result), ((NI)1));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) (iX60gensym21_))));
	}
	goto LA1_;
	LA4_: ;
	{
		NIM_BOOL T7_;
		T7_ = (NIM_BOOL)0;
		T7_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)2047));
		if (!T7_) goto LA8_;
		setLengthStrV2((&result), ((NI)2));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)6))) | ((NI32)192))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)1)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)(iX60gensym21_ & ((NI32)63)) | ((NI32)128))))));
	}
	goto LA1_;
	LA8_: ;
	{
		NIM_BOOL T11_;
		T11_ = (NIM_BOOL)0;
		T11_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)65535));
		if (!T11_) goto LA12_;
		setLengthStrV2((&result), ((NI)3));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)12))) | ((NI32)224))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)1)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)6))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)2)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)(iX60gensym21_ & ((NI32)63)) | ((NI32)128))))));
	}
	goto LA1_;
	LA12_: ;
	{
		NIM_BOOL T15_;
		T15_ = (NIM_BOOL)0;
		T15_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)2097151));
		if (!T15_) goto LA16_;
		setLengthStrV2((&result), ((NI)4));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)18))) | ((NI32)240))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)1)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)12))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)2)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)6))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)3)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)(iX60gensym21_ & ((NI32)63)) | ((NI32)128))))));
	}
	goto LA1_;
	LA16_: ;
	{
		NIM_BOOL T19_;
		T19_ = (NIM_BOOL)0;
		T19_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)67108863));
		if (!T19_) goto LA20_;
		setLengthStrV2((&result), ((NI)5));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)24))) | ((NI32)248))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)1)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)18))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)2)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)12))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)3)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)6))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)4)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)(iX60gensym21_ & ((NI32)63)) | ((NI32)128))))));
	}
	goto LA1_;
	LA20_: ;
	{
		NIM_BOOL T23_;
		T23_ = (NIM_BOOL)0;
		T23_ = lteqpercent___system_1086(iX60gensym21_, ((NI32)2147483647));
		if (!T23_) goto LA24_;
		setLengthStrV2((&result), ((NI)6));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)0)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)30))) | ((NI32)252))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)1)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)24))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)2)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)18))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)3)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)12))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)4)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)((NI32)((NI64)(iX60gensym21_) >> (NU64)(((NI)6))) & ((NI32)63)) | ((NI32)128))))));
		nimPrepareStrMutationV2((&result));
		result.p->data[((NI)5)] = ((NIM_CHAR) (((NI) ((NI32)((NI32)(iX60gensym21_ & ((NI32)63)) | ((NI32)128))))));
	}
	goto LA1_;
	LA24_: ;
	{
	}
	LA1_: ;
	return result;
}