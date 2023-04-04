/* Generated by Nim Compiler v1.9.3 */
#define NIM_INTBITS 64

#include "nimbase.h"
#include <string.h>
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
typedef struct tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw;
typedef struct tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ;
struct NimStrPayload {
NI cap;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct NimStringV2 {
NI len;
NimStrPayload* p;
};
struct tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw {
NI i;
NI prev;
NIM_BOOL notFirst;
};
struct tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ {
NI Field0;
NI Field1;
};
static N_INLINE(void, nimZeroMem)(void* p__BuPKoq7dppy2upaj3KUaxw, NI size__ttWVm79bajRU3tarcA7MkLw);
static N_INLINE(void, nimSetMem__systemZmemory_7)(void* a__tZiCJHYy5dYyAh9cxwrrVhQ, int v__iM7JOvZxArJIvbhGyRZG6Q, NI size__ntsFNLS0mpvnjQFrZT7DCw);
static N_INLINE(NIM_BOOL*, nimErrorFlag)(void);
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, hasNext__pureZpathnorm_6)(tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw it__GiqGABr9b8tA2Hckho2ysRQ, NimStringV2 x__6ofPNpPVL9bRlU1dBRc2mFA);
N_LIB_PRIVATE N_NIMCALL(tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ, next__pureZpathnorm_10)(tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw* it__ObgF400yx80YOHP9afiycgg, NimStringV2 x__7xj3YxaCnXQ9bS9a9b29bzYi5A);
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isSlash__pureZpathnorm_75)(NimStringV2 x__KUVev7zjrnRkEJ9bepO3tmA, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__RSuiqtilSDagygy2B6ghvw);
static N_INLINE(void, nimAddCharV1)(NimStringV2* s__S65jkNxJ72wMzHX9bQ0it8w, NIM_CHAR c__q53woDK9bF1K5bAKmsVpSkA);
N_LIB_PRIVATE N_NIMCALL(void, prepareAdd)(NimStringV2* s__qL2AkrAohOvo9bZZC15G6TA, NI addlen__uGPPC8Yor9a9avOoki7IG3AQ);
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isDotDot__pureZpathnorm_71)(NimStringV2 x__Bv49bL0b2mOwMdYvXM9bki9ag, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__aeZvn2j8yBl1sR3JGwAaew);
N_LIB_PRIVATE N_NIMCALL(void, setLengthStrV2)(NimStringV2* s__19atMbr42TbRkrQSPFxaPZg, NI newLen__zdmruIpEqwmFKxid9btfbJw);
N_LIB_PRIVATE N_NIMCALL(NimStringV2, substr__system_8447)(NimStringV2 s__eXeA1kh9ab7IlWnp9b2LKlnw, NI first__HUA4TUIjnYTo9aHRDiDB4TQ, NI last__1Ew0dzcZj5unitItuDdtPA);
static N_INLINE(void, appendString)(NimStringV2* dest__Ws6Yi19bfxrbjCy9a9brzRV7A, NimStringV2 src__369aqaoei6FUsRf9cDAsKQ2g);
static N_INLINE(void, copyMem__system_1752)(void* dest__fJYjxXM6yYjbZ9agQpPnNNA, void* source__Y6ZnHEKiVLswf16AMGuQUA, NI size__YLlwRG7Z9bTiXmiSwU9cUHeA);
static N_INLINE(void, nimCopyMem)(void* dest__HMDJtGX4ficduS9cTUiey0w, void* source__xDZEU1SRcEBuZ8mtbKQBhQ, NI size__9b8g0WMA1h1RvMwHOMW7yFA);
N_LIB_PRIVATE N_NIMCALL(void, eqdestroy___stdZassertions_30)(NimStringV2* dest__C2JKGPCNdWKCPrsQvNywTQ);
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isDot__pureZpathnorm_67)(NimStringV2 x__JBiwUk9byVRmU9bh4HxGSWlg, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__fKB8Rhj6yJwiQ49aEnZ9creQ);
N_LIB_PRIVATE N_NIMCALL(void, eqsink___stdZassertions_36)(NimStringV2* dest__VTJh4gw5Rje9bocjsx81Ekg, NimStringV2 src__GJAw6lOoetbnH4F11f7wrg);
static const struct {
  NI cap; NIM_CHAR data[1+1];
} TM__DfU0iuayCGwHDN1Exp9cbKg_2 = { 1 | NIM_STRLIT_FLAG, "." };
static const NimStringV2 TM__DfU0iuayCGwHDN1Exp9cbKg_3 = {1, (NimStrPayload*)&TM__DfU0iuayCGwHDN1Exp9cbKg_2};
extern NIM_THREADVAR NIM_BOOL nimInErrorMode__system_4297;
static N_INLINE(void, nimSetMem__systemZmemory_7)(void* a__tZiCJHYy5dYyAh9cxwrrVhQ, int v__iM7JOvZxArJIvbhGyRZG6Q, NI size__ntsFNLS0mpvnjQFrZT7DCw) {
	void* T1_;
	T1_ = (void*)0;
	T1_ = memset(a__tZiCJHYy5dYyAh9cxwrrVhQ, v__iM7JOvZxArJIvbhGyRZG6Q, ((size_t) (size__ntsFNLS0mpvnjQFrZT7DCw)));
}
static N_INLINE(NIM_BOOL*, nimErrorFlag)(void) {
	NIM_BOOL* result;
	result = (NIM_BOOL*)0;
	result = (&nimInErrorMode__system_4297);
	return result;
}
static N_INLINE(void, nimZeroMem)(void* p__BuPKoq7dppy2upaj3KUaxw, NI size__ttWVm79bajRU3tarcA7MkLw) {
NIM_BOOL* nimErr_;
{nimErr_ = nimErrorFlag();
	nimSetMem__systemZmemory_7(p__BuPKoq7dppy2upaj3KUaxw, ((int)0), size__ttWVm79bajRU3tarcA7MkLw);
	if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
	}BeforeRet_: ;
}
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, hasNext__pureZpathnorm_6)(tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw it__GiqGABr9b8tA2Hckho2ysRQ, NimStringV2 x__6ofPNpPVL9bRlU1dBRc2mFA) {
	NIM_BOOL result;
	result = (NIM_BOOL)0;
	result = (it__GiqGABr9b8tA2Hckho2ysRQ.i < x__6ofPNpPVL9bRlU1dBRc2mFA.len);
	return result;
}
N_LIB_PRIVATE N_NIMCALL(tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ, next__pureZpathnorm_10)(tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw* it__ObgF400yx80YOHP9afiycgg, NimStringV2 x__7xj3YxaCnXQ9bS9a9b29bzYi5A) {
	tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ result;
NIM_BOOL* nimErr_;
{nimErr_ = nimErrorFlag();
	nimZeroMem((void*)(&result), sizeof(tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ));
	(*it__ObgF400yx80YOHP9afiycgg).prev = (*it__ObgF400yx80YOHP9afiycgg).i;
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = !((*it__ObgF400yx80YOHP9afiycgg).notFirst);
		if (!(T3_)) goto LA4_;
		T3_ = (((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47)) || ((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47)));
		LA4_: ;
		if (!T3_) goto LA5_;
		(*it__ObgF400yx80YOHP9afiycgg).i += ((NI)1);
	}
	goto LA1_;
	LA5_: ;
	{
		{
			while (1) {
				NIM_BOOL T10_;
				T10_ = (NIM_BOOL)0;
				T10_ = ((*it__ObgF400yx80YOHP9afiycgg).i < x__7xj3YxaCnXQ9bS9a9b29bzYi5A.len);
				if (!(T10_)) goto LA11_;
				T10_ = !((((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47)) || ((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47))));
				LA11_: ;
				if (!T10_) goto LA9				;
				(*it__ObgF400yx80YOHP9afiycgg).i += ((NI)1);
			} LA9: ;
		}
	}
	LA1_: ;
	{
		NI colontmp_;
		NI colontmp__2;
		if (!((*it__ObgF400yx80YOHP9afiycgg).prev < (*it__ObgF400yx80YOHP9afiycgg).i)) goto LA14_;
		colontmp_ = (*it__ObgF400yx80YOHP9afiycgg).prev;
		colontmp__2 = (NI)((*it__ObgF400yx80YOHP9afiycgg).i - ((NI)1));
		result.Field0 = colontmp_;
		result.Field1 = colontmp__2;
	}
	goto LA12_;
	LA14_: ;
	{
		NIM_BOOL T17_;
		T17_ = (NIM_BOOL)0;
		T17_ = hasNext__pureZpathnorm_6((*it__ObgF400yx80YOHP9afiycgg), x__7xj3YxaCnXQ9bS9a9b29bzYi5A);
		if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
		if (!T17_) goto LA18_;
		result = next__pureZpathnorm_10(it__ObgF400yx80YOHP9afiycgg, x__7xj3YxaCnXQ9bS9a9b29bzYi5A);
		if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
	}
	goto LA12_;
	LA18_: ;
	LA12_: ;
	{
		while (1) {
			NIM_BOOL T22_;
			T22_ = (NIM_BOOL)0;
			T22_ = ((*it__ObgF400yx80YOHP9afiycgg).i < x__7xj3YxaCnXQ9bS9a9b29bzYi5A.len);
			if (!(T22_)) goto LA23_;
			T22_ = (((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47)) || ((NU8)(x__7xj3YxaCnXQ9bS9a9b29bzYi5A.p->data[(*it__ObgF400yx80YOHP9afiycgg).i])) == ((NU8)(47)));
			LA23_: ;
			if (!T22_) goto LA21			;
			(*it__ObgF400yx80YOHP9afiycgg).i += ((NI)1);
		} LA21: ;
	}
	(*it__ObgF400yx80YOHP9afiycgg).notFirst = NIM_TRUE;
	}BeforeRet_: ;
	return result;
}
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isSlash__pureZpathnorm_75)(NimStringV2 x__KUVev7zjrnRkEJ9bepO3tmA, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__RSuiqtilSDagygy2B6ghvw) {
	NIM_BOOL result;
	NIM_BOOL T1_;
	result = (NIM_BOOL)0;
	T1_ = (NIM_BOOL)0;
	T1_ = (bounds__RSuiqtilSDagygy2B6ghvw.Field1 == bounds__RSuiqtilSDagygy2B6ghvw.Field0);
	if (!(T1_)) goto LA2_;
	T1_ = (((NU8)(x__KUVev7zjrnRkEJ9bepO3tmA.p->data[bounds__RSuiqtilSDagygy2B6ghvw.Field0])) == ((NU8)(47)) || ((NU8)(x__KUVev7zjrnRkEJ9bepO3tmA.p->data[bounds__RSuiqtilSDagygy2B6ghvw.Field0])) == ((NU8)(47)));
	LA2_: ;
	result = T1_;
	return result;
}
static N_INLINE(void, nimAddCharV1)(NimStringV2* s__S65jkNxJ72wMzHX9bQ0it8w, NIM_CHAR c__q53woDK9bF1K5bAKmsVpSkA) {
	prepareAdd(s__S65jkNxJ72wMzHX9bQ0it8w, ((NI)1));
	(*(*s__S65jkNxJ72wMzHX9bQ0it8w).p).data[(*s__S65jkNxJ72wMzHX9bQ0it8w).len] = c__q53woDK9bF1K5bAKmsVpSkA;
	(*(*s__S65jkNxJ72wMzHX9bQ0it8w).p).data[(NI)((*s__S65jkNxJ72wMzHX9bQ0it8w).len + ((NI)1))] = 0;
	(*s__S65jkNxJ72wMzHX9bQ0it8w).len += ((NI)1);
}
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isDotDot__pureZpathnorm_71)(NimStringV2 x__Bv49bL0b2mOwMdYvXM9bki9ag, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__aeZvn2j8yBl1sR3JGwAaew) {
	NIM_BOOL result;
	NIM_BOOL T1_;
	NIM_BOOL T2_;
	result = (NIM_BOOL)0;
	T1_ = (NIM_BOOL)0;
	T2_ = (NIM_BOOL)0;
	T2_ = (bounds__aeZvn2j8yBl1sR3JGwAaew.Field1 == (NI)(bounds__aeZvn2j8yBl1sR3JGwAaew.Field0 + ((NI)1)));
	if (!(T2_)) goto LA3_;
	T2_ = ((NU8)(x__Bv49bL0b2mOwMdYvXM9bki9ag.p->data[bounds__aeZvn2j8yBl1sR3JGwAaew.Field0]) == (NU8)(46));
	LA3_: ;
	T1_ = T2_;
	if (!(T1_)) goto LA4_;
	T1_ = ((NU8)(x__Bv49bL0b2mOwMdYvXM9bki9ag.p->data[(NI)(bounds__aeZvn2j8yBl1sR3JGwAaew.Field0 + ((NI)1))]) == (NU8)(46));
	LA4_: ;
	result = T1_;
	return result;
}
static N_INLINE(void, nimCopyMem)(void* dest__HMDJtGX4ficduS9cTUiey0w, void* source__xDZEU1SRcEBuZ8mtbKQBhQ, NI size__9b8g0WMA1h1RvMwHOMW7yFA) {
	void* T1_;
	T1_ = (void*)0;
	T1_ = memcpy(dest__HMDJtGX4ficduS9cTUiey0w, source__xDZEU1SRcEBuZ8mtbKQBhQ, ((size_t) (size__9b8g0WMA1h1RvMwHOMW7yFA)));
}
static N_INLINE(void, copyMem__system_1752)(void* dest__fJYjxXM6yYjbZ9agQpPnNNA, void* source__Y6ZnHEKiVLswf16AMGuQUA, NI size__YLlwRG7Z9bTiXmiSwU9cUHeA) {
	nimCopyMem(dest__fJYjxXM6yYjbZ9agQpPnNNA, source__Y6ZnHEKiVLswf16AMGuQUA, size__YLlwRG7Z9bTiXmiSwU9cUHeA);
}
static N_INLINE(void, appendString)(NimStringV2* dest__Ws6Yi19bfxrbjCy9a9brzRV7A, NimStringV2 src__369aqaoei6FUsRf9cDAsKQ2g) {
	{
		if (!(((NI)0) < src__369aqaoei6FUsRf9cDAsKQ2g.len)) goto LA3_;
		copyMem__system_1752(((void*) ((&(*(*dest__Ws6Yi19bfxrbjCy9a9brzRV7A).p).data[(*dest__Ws6Yi19bfxrbjCy9a9brzRV7A).len]))), ((void*) ((&(*src__369aqaoei6FUsRf9cDAsKQ2g.p).data[((NI)0)]))), ((NI) ((NI)(src__369aqaoei6FUsRf9cDAsKQ2g.len + ((NI)1)))));
		(*dest__Ws6Yi19bfxrbjCy9a9brzRV7A).len += src__369aqaoei6FUsRf9cDAsKQ2g.len;
	}
	LA3_: ;
}
N_LIB_PRIVATE N_NIMCALL(NIM_BOOL, isDot__pureZpathnorm_67)(NimStringV2 x__JBiwUk9byVRmU9bh4HxGSWlg, tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ bounds__fKB8Rhj6yJwiQ49aEnZ9creQ) {
	NIM_BOOL result;
	NIM_BOOL T1_;
	result = (NIM_BOOL)0;
	T1_ = (NIM_BOOL)0;
	T1_ = (bounds__fKB8Rhj6yJwiQ49aEnZ9creQ.Field1 == bounds__fKB8Rhj6yJwiQ49aEnZ9creQ.Field0);
	if (!(T1_)) goto LA2_;
	T1_ = ((NU8)(x__JBiwUk9byVRmU9bh4HxGSWlg.p->data[bounds__fKB8Rhj6yJwiQ49aEnZ9creQ.Field0]) == (NU8)(46));
	LA2_: ;
	result = T1_;
	return result;
}
N_LIB_PRIVATE N_NIMCALL(void, addNormalizePath__pureZpathnorm_83)(NimStringV2 x__HhJ3EvK0Pc3JWVNbj9boH1A, NimStringV2* result__rUHqnSyl9c0bChyYf3nrLkQ, NI* state__9akIe1B9c51IR7mLz7KH5tOg, NIM_CHAR dirSep__aJuBHLSW4AuR0lm9a4Cybtg) {
	tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw it;
NIM_BOOL* nimErr_;
{nimErr_ = nimErrorFlag();
	nimZeroMem((void*)(&it), sizeof(tyObject_PathIter__9cpN3E0k54yhKl7AB2I3iNw));
	it.notFirst = (((NI)0) < (NI)((NI64)((*state__9akIe1B9c51IR7mLz7KH5tOg)) >> (NU64)(((NI)1))));
	{
		if (!it.notFirst) goto LA3_;
		{
			while (1) {
				NIM_BOOL T7_;
				T7_ = (NIM_BOOL)0;
				T7_ = (it.i < x__HhJ3EvK0Pc3JWVNbj9boH1A.len);
				if (!(T7_)) goto LA8_;
				T7_ = (((NU8)(x__HhJ3EvK0Pc3JWVNbj9boH1A.p->data[it.i])) == ((NU8)(47)) || ((NU8)(x__HhJ3EvK0Pc3JWVNbj9boH1A.p->data[it.i])) == ((NU8)(47)));
				LA8_: ;
				if (!T7_) goto LA6				;
				it.i += ((NI)1);
			} LA6: ;
		}
	}
	LA3_: ;
	{
		while (1) {
			NIM_BOOL T11_;
			tyTuple__1v9bKyksXWMsm0vNwmZ4EuQ b;
			T11_ = (NIM_BOOL)0;
			T11_ = hasNext__pureZpathnorm_6(it, x__HhJ3EvK0Pc3JWVNbj9boH1A);
			if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
			if (!T11_) goto LA10			;
			b = next__pureZpathnorm_10((&it), x__HhJ3EvK0Pc3JWVNbj9boH1A);
			if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
			{
				NIM_BOOL T14_;
				T14_ = (NIM_BOOL)0;
				T14_ = ((NI)((NI64)((*state__9akIe1B9c51IR7mLz7KH5tOg)) >> (NU64)(((NI)1))) == ((NI)0));
				if (!(T14_)) goto LA15_;
				T14_ = isSlash__pureZpathnorm_75(x__HhJ3EvK0Pc3JWVNbj9boH1A, b);
				if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
				LA15_: ;
				if (!T14_) goto LA16_;
				{
					NIM_BOOL T20_;
					T20_ = (NIM_BOOL)0;
					T20_ = ((*result__rUHqnSyl9c0bChyYf3nrLkQ).len == ((NI)0));
					if (T20_) goto LA21_;
					T20_ = !((((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47)) || ((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47))));
					LA21_: ;
					if (!T20_) goto LA22_;
					nimAddCharV1((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), dirSep__aJuBHLSW4AuR0lm9a4Cybtg);
				}
				LA22_: ;
				(*state__9akIe1B9c51IR7mLz7KH5tOg) = (NI)((*state__9akIe1B9c51IR7mLz7KH5tOg) | ((NI)1));
			}
			goto LA12_;
			LA16_: ;
			{
				NIM_BOOL T25_;
				T25_ = (NIM_BOOL)0;
				T25_ = isDotDot__pureZpathnorm_71(x__HhJ3EvK0Pc3JWVNbj9boH1A, b);
				if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
				if (!T25_) goto LA26_;
				{
					NI d;
					if (!(((NI)1) <= (NI)((NI64)((*state__9akIe1B9c51IR7mLz7KH5tOg)) >> (NU64)(((NI)1))))) goto LA30_;
					d = (*result__rUHqnSyl9c0bChyYf3nrLkQ).len;
					{
						while (1) {
							NIM_BOOL T34_;
							T34_ = (NIM_BOOL)0;
							T34_ = ((NI)((*state__9akIe1B9c51IR7mLz7KH5tOg) & ((NI)1)) < (NI)(d - ((NI)1)));
							if (!(T34_)) goto LA35_;
							T34_ = !((((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)(d - ((NI)1))])) == ((NU8)(47)) || ((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)(d - ((NI)1))])) == ((NU8)(47))));
							LA35_: ;
							if (!T34_) goto LA33							;
							d -= ((NI)1);
						} LA33: ;
					}
					{
						if (!(((NI)0) < d)) goto LA38_;
						setLengthStrV2((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), ((NI) ((NI)(d - ((NI)1)))));
						(*state__9akIe1B9c51IR7mLz7KH5tOg) -= ((NI)2);
					}
					LA38_: ;
				}
				goto LA28_;
				LA30_: ;
				{
					NimStringV2 colontmpD_;
					colontmpD_.len = 0; colontmpD_.p = NIM_NIL;
					{
						NIM_BOOL T43_;
						T43_ = (NIM_BOOL)0;
						T43_ = (((NI)0) < (*result__rUHqnSyl9c0bChyYf3nrLkQ).len);
						if (!(T43_)) goto LA44_;
						T43_ = !((((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47)) || ((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47))));
						LA44_: ;
						if (!T43_) goto LA45_;
						nimAddCharV1((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), dirSep__aJuBHLSW4AuR0lm9a4Cybtg);
					}
					LA45_: ;
					colontmpD_ = substr__system_8447(x__HhJ3EvK0Pc3JWVNbj9boH1A, b.Field0, b.Field1);
					prepareAdd((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), colontmpD_.len + 0);
appendString((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), colontmpD_);
					eqdestroy___stdZassertions_30((&colontmpD_));
				}
				LA28_: ;
			}
			goto LA12_;
			LA26_: ;
			{
				NIM_BOOL T48_;
				T48_ = (NIM_BOOL)0;
				T48_ = isDot__pureZpathnorm_67(x__HhJ3EvK0Pc3JWVNbj9boH1A, b);
				if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
				if (!T48_) goto LA49_;
			}
			goto LA12_;
			LA49_: ;
			{
				NimStringV2 colontmpD__2;
				if (!(b.Field0 <= b.Field1)) goto LA52_;
				colontmpD__2.len = 0; colontmpD__2.p = NIM_NIL;
				{
					NIM_BOOL T56_;
					T56_ = (NIM_BOOL)0;
					T56_ = (((NI)0) < (*result__rUHqnSyl9c0bChyYf3nrLkQ).len);
					if (!(T56_)) goto LA57_;
					T56_ = !((((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47)) || ((NU8)((*result__rUHqnSyl9c0bChyYf3nrLkQ).p->data[(NI)((*result__rUHqnSyl9c0bChyYf3nrLkQ).len - ((NI)1))])) == ((NU8)(47))));
					LA57_: ;
					if (!T56_) goto LA58_;
					nimAddCharV1((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), dirSep__aJuBHLSW4AuR0lm9a4Cybtg);
				}
				LA58_: ;
				colontmpD__2 = substr__system_8447(x__HhJ3EvK0Pc3JWVNbj9boH1A, b.Field0, b.Field1);
				prepareAdd((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), colontmpD__2.len + 0);
appendString((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), colontmpD__2);
				(*state__9akIe1B9c51IR7mLz7KH5tOg) += ((NI)2);
				eqdestroy___stdZassertions_30((&colontmpD__2));
			}
			goto LA12_;
			LA52_: ;
			LA12_: ;
		} LA10: ;
	}
	{
		NIM_BOOL T62_;
		T62_ = (NIM_BOOL)0;
		T62_ = ((*result__rUHqnSyl9c0bChyYf3nrLkQ).len == 0);
		if (!(T62_)) goto LA63_;
		T62_ = !((x__HhJ3EvK0Pc3JWVNbj9boH1A.len == 0));
		LA63_: ;
		if (!T62_) goto LA64_;
		eqsink___stdZassertions_36((&(*result__rUHqnSyl9c0bChyYf3nrLkQ)), TM__DfU0iuayCGwHDN1Exp9cbKg_3);
	}
	LA64_: ;
	}BeforeRet_: ;
}