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
typedef struct TNimTypeV2 TNimTypeV2;
typedef struct tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA;
typedef struct tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw;
typedef struct tyObject_ValueError__PotCu49bK9cPOepZ9ae9b17fJA tyObject_ValueError__PotCu49bK9cPOepZ9ae9b17fJA;
typedef struct tyObject_CatchableError__9cyZ9aPQenU9bm4gpwSRVmfsA tyObject_CatchableError__9cyZ9aPQenU9bm4gpwSRVmfsA;
typedef struct Exception Exception;
typedef struct RootObj RootObj;
typedef struct NimStrPayload NimStrPayload;
typedef struct NimStringV2 NimStringV2;
typedef struct tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ;
typedef struct tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content;
typedef struct tyObject_GcEnv__wrXjIZdIxCtzM9cDR1LtFhA tyObject_GcEnv__wrXjIZdIxCtzM9cDR1LtFhA;
typedef struct tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q;
typedef struct tyTuple__N4J9cV4JZGem3ljqqj5rT0Q tyTuple__N4J9cV4JZGem3ljqqj5rT0Q;
typedef struct tyObject_CellSeq__9aBhmPhRskpiCeptzlOeZyA tyObject_CellSeq__9aBhmPhRskpiCeptzlOeZyA;
typedef struct tyTuple__JtsWbX86bdJaB04v6hfOnA tyTuple__JtsWbX86bdJaB04v6hfOnA;
typedef struct tyObject_StackTraceEntry__2Xjg6E7TZG7p9bcgUNTKHrg tyObject_StackTraceEntry__2Xjg6E7TZG7p9bcgUNTKHrg;
typedef NU8 tySet_tyChar__nmiMWKVIe46vacnhAFrQvw[32];
struct TNimTypeV2 {
void* destructor;
NI size;
NI16 align;
NI16 depth;
NU32* display;
void* traceImpl;
void* typeInfoV1;
NI flags;
};
struct tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw {
NI rc;
NI rootIdx;
};
struct RootObj {
TNimTypeV2* m_type;
};
struct NimStrPayload {
NI cap;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct NimStringV2 {
NI len;
NimStrPayload* p;
};
struct tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ {
  NI len; tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content* p;
};
struct Exception {
  RootObj Sup;
Exception* parent;
NCSTRING name;
NimStringV2 message;
tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ trace;
Exception* up;
};
struct tyObject_CatchableError__9cyZ9aPQenU9bm4gpwSRVmfsA {
  Exception Sup;
};
struct tyObject_ValueError__PotCu49bK9cPOepZ9ae9b17fJA {
  tyObject_CatchableError__9cyZ9aPQenU9bm4gpwSRVmfsA Sup;
};
struct tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA {
  tyObject_ValueError__PotCu49bK9cPOepZ9ae9b17fJA Sup;
};
struct tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q {
NI len;
NI cap;
tyTuple__N4J9cV4JZGem3ljqqj5rT0Q* d;
};
struct tyObject_CellSeq__9aBhmPhRskpiCeptzlOeZyA {
NI len;
NI cap;
tyTuple__JtsWbX86bdJaB04v6hfOnA* d;
};
struct tyObject_GcEnv__wrXjIZdIxCtzM9cDR1LtFhA {
tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q traceStack;
tyObject_CellSeq__9aBhmPhRskpiCeptzlOeZyA toFree;
NI freed;
NI touched;
NI edges;
NI rcSum;
NIM_BOOL keepThreshold;
};
struct tyTuple__N4J9cV4JZGem3ljqqj5rT0Q {
void** Field0;
TNimTypeV2* Field1;
};
typedef tyTuple__N4J9cV4JZGem3ljqqj5rT0Q tyUncheckedArray__72XmdLy0QAaMtx66AmNKfA[1];
struct tyObject_StackTraceEntry__2Xjg6E7TZG7p9bcgUNTKHrg {
NCSTRING procname;
NI line;
NCSTRING filename;
};


#ifndef tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content_PP
#define tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content_PP
struct tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ_Content { NI cap; tyObject_StackTraceEntry__2Xjg6E7TZG7p9bcgUNTKHrg data[SEQ_DECL_SIZE];};
#endif

      N_LIB_PRIVATE N_NIMCALL(void, eqdestroy___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_186)(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA* dest__FXpLZ39cy5Q2hBjvaOxwx9bw);
static N_INLINE(NIM_BOOL, nimDecRefIsLastCyclicDyn)(void* p__dABzUdgzrkaSDMDdaWLtRg);
static N_INLINE(NI, minuspercent___system_790)(NI x__nhqJNug5PDvy9ah8vc6uJ5Q, NI y__LJLJ0MGnpTb2U2nvMvG6MQ);
N_LIB_PRIVATE N_NOINLINE(void, rememberCycle__system_3324)(NIM_BOOL isDestroyAction__wlZkTmY2exyvD4PmYZgCHw, tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw* s__rifrsJGbWaDLWZRj0ktOnA, TNimTypeV2* desc__YB9c2fwKemzor6iGIpZW9bIw);
static N_INLINE(NIM_BOOL*, nimErrorFlag)(void);
N_LIB_PRIVATE N_NIMCALL(void, nimDestroyAndDispose)(void* p__9avvNwjq1NdQwdCBwEYwA9bw);
N_LIB_PRIVATE N_NIMCALL(void, eqdestroy___stdZassertions_30)(NimStringV2* dest__C2JKGPCNdWKCPrsQvNywTQ);
N_LIB_PRIVATE N_NIMCALL(void, eqdestroy___stdZassertions_87)(tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ* dest__OvUJ7i3R9aE9as9bgGZONrFOA);
N_LIB_PRIVATE N_NIMCALL(void, eqtrace___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_195)(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA* dest__9ae0Rp9ajnKZiopHGc0kSIBQ, void* env__H7apztaaSmiz2HUcfTP6Mg);
static N_INLINE(void, nimTraceRefDyn)(void* q__DU69bA8QWYzcJYHZK62MWjA, void* env__jq9cK8cvI9c0aQFP3P6pQbYA);
static N_INLINE(void, add__system_2821)(tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q* s__G58rBzp9arUs2Le3q9bajUHA, void** c__glbQoed0fMuhXSt1wQUc7w, TNimTypeV2* t__afUUWAFqIJFXIEkjClESEA);
N_LIB_PRIVATE N_NOCONV(void*, allocSharedImpl)(NI size__PQOom62dq59az26ZBA3l8Lg);
static N_INLINE(void, copyMem__system_1752)(void* dest__fJYjxXM6yYjbZ9agQpPnNNA, void* source__Y6ZnHEKiVLswf16AMGuQUA, NI size__YLlwRG7Z9bTiXmiSwU9cUHeA);
static N_INLINE(void, nimCopyMem)(void* dest__HMDJtGX4ficduS9cTUiey0w, void* source__xDZEU1SRcEBuZ8mtbKQBhQ, NI size__9b8g0WMA1h1RvMwHOMW7yFA);
N_LIB_PRIVATE N_NOCONV(void, deallocShared)(void* p__XTVwAD5Qcy8cCUaIcC80hw);
N_LIB_PRIVATE N_NIMCALL(void, eqtrace___stdZassertions_96)(tySequence__9bNRJkU9cJnNkESCDTQ7DgcQ* dest__MtFFOU2wNRj2y9bA8lUbcdQ, void* env__kESFTih59bdOEL17KGJBDtg);
N_LIB_PRIVATE TNimTypeV2 NTIv2__iBRrIKmJWbkgrnAcChY3YA_;
N_LIB_PRIVATE NIM_CONST tySet_tyChar__nmiMWKVIe46vacnhAFrQvw whiteSpace__OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_11 = {
0x00, 0x26, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
;
extern NIM_THREADVAR NIM_BOOL nimInErrorMode__system_4297;
static NIM_CONST NU32 TM__i2iijR14SWP7qfN9cUr8zoQ_2[5] = {3701606400, 1285336064, 645741824, 2336406272, 342564864};
N_LIB_PRIVATE TNimTypeV2 NTIv2__iBRrIKmJWbkgrnAcChY3YA_ = {.destructor = (void*)eqdestroy___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_186, .size = sizeof(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA), .align = (NI16) NIM_ALIGNOF(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA), .depth = 4, .display = TM__i2iijR14SWP7qfN9cUr8zoQ_2, .traceImpl = (void*)eqtrace___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_195, .flags = 0};
static N_INLINE(NI, minuspercent___system_790)(NI x__nhqJNug5PDvy9ah8vc6uJ5Q, NI y__LJLJ0MGnpTb2U2nvMvG6MQ) {
	NI result;
	result = (NI)0;
	result = ((NI) ((NU)((NU64)(((NU) (x__nhqJNug5PDvy9ah8vc6uJ5Q))) - (NU64)(((NU) (y__LJLJ0MGnpTb2U2nvMvG6MQ))))));
	return result;
}
static N_INLINE(NIM_BOOL*, nimErrorFlag)(void) {
	NIM_BOOL* result;
	result = (NIM_BOOL*)0;
	result = (&nimInErrorMode__system_4297);
	return result;
}
static N_INLINE(NIM_BOOL, nimDecRefIsLastCyclicDyn)(void* p__dABzUdgzrkaSDMDdaWLtRg) {
	NIM_BOOL result;
NIM_BOOL* nimErr_;
{nimErr_ = nimErrorFlag();
	result = (NIM_BOOL)0;
	{
		tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw* cell;
		NI T5_;
		if (!!((p__dABzUdgzrkaSDMDdaWLtRg == NIM_NIL))) goto LA3_;
		T5_ = (NI)0;
		T5_ = minuspercent___system_790(((NI) (ptrdiff_t) (p__dABzUdgzrkaSDMDdaWLtRg)), ((NI)16));
		cell = ((tyObject_RefHeader__YmUax3FsG7Gnj3DF0PcAlw*) (T5_));
		{
			if (!((NI)((*cell).rc & ((NI)-16)) == ((NI)0))) goto LA8_;
			result = NIM_TRUE;
		}
		goto LA6_;
		LA8_: ;
		{
			(*cell).rc -= ((NI)16);
		}
		LA6_: ;
		rememberCycle__system_3324(result, cell, (*((TNimTypeV2**) (p__dABzUdgzrkaSDMDdaWLtRg))));
		if (NIM_UNLIKELY(*nimErr_)) goto BeforeRet_;
	}
	LA3_: ;
	}BeforeRet_: ;
	return result;
}
N_LIB_PRIVATE N_NIMCALL(void, eqdestroy___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_186)(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA* dest__FXpLZ39cy5Q2hBjvaOxwx9bw) {
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = nimDecRefIsLastCyclicDyn((*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.parent);
		if (!T3_) goto LA4_;
		nimDestroyAndDispose((*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.parent);
	}
	LA4_: ;
	eqdestroy___stdZassertions_30((&(*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.message));
	eqdestroy___stdZassertions_87((&(*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.trace));
	{
		NIM_BOOL T8_;
		T8_ = (NIM_BOOL)0;
		T8_ = nimDecRefIsLastCyclicDyn((*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.up);
		if (!T8_) goto LA9_;
		nimDestroyAndDispose((*dest__FXpLZ39cy5Q2hBjvaOxwx9bw).Sup.Sup.Sup.up);
	}
	LA9_: ;
}
static N_INLINE(void, nimCopyMem)(void* dest__HMDJtGX4ficduS9cTUiey0w, void* source__xDZEU1SRcEBuZ8mtbKQBhQ, NI size__9b8g0WMA1h1RvMwHOMW7yFA) {
	void* T1_;
	T1_ = (void*)0;
	T1_ = memcpy(dest__HMDJtGX4ficduS9cTUiey0w, source__xDZEU1SRcEBuZ8mtbKQBhQ, ((size_t) (size__9b8g0WMA1h1RvMwHOMW7yFA)));
}
static N_INLINE(void, copyMem__system_1752)(void* dest__fJYjxXM6yYjbZ9agQpPnNNA, void* source__Y6ZnHEKiVLswf16AMGuQUA, NI size__YLlwRG7Z9bTiXmiSwU9cUHeA) {
	nimCopyMem(dest__fJYjxXM6yYjbZ9agQpPnNNA, source__Y6ZnHEKiVLswf16AMGuQUA, size__YLlwRG7Z9bTiXmiSwU9cUHeA);
}
static N_INLINE(void, add__system_2821)(tyObject_CellSeq__89bNXn3s6QKjCT39cWz9cQw5Q* s__G58rBzp9arUs2Le3q9bajUHA, void** c__glbQoed0fMuhXSt1wQUc7w, TNimTypeV2* t__afUUWAFqIJFXIEkjClESEA) {
	void** colontmp_;
	TNimTypeV2* colontmp__2;
	{
		tyTuple__N4J9cV4JZGem3ljqqj5rT0Q* d;
		void* T5_;
		if (!((*s__G58rBzp9arUs2Le3q9bajUHA).cap <= (*s__G58rBzp9arUs2Le3q9bajUHA).len)) goto LA3_;
		(*s__G58rBzp9arUs2Le3q9bajUHA).cap = (NI)((NI)((*s__G58rBzp9arUs2Le3q9bajUHA).cap * ((NI)3)) / ((NI)2));
		T5_ = (void*)0;
		T5_ = allocSharedImpl(((NI) (((NU) ((NI)((*s__G58rBzp9arUs2Le3q9bajUHA).cap * ((NI)16)))))));
		d = ((tyTuple__N4J9cV4JZGem3ljqqj5rT0Q*) (T5_));
		copyMem__system_1752(((void*) (d)), ((void*) ((*s__G58rBzp9arUs2Le3q9bajUHA).d)), ((NI) ((NI)((*s__G58rBzp9arUs2Le3q9bajUHA).len * ((NI)16)))));
		deallocShared(((void*) ((*s__G58rBzp9arUs2Le3q9bajUHA).d)));
		(*s__G58rBzp9arUs2Le3q9bajUHA).d = d;
	}
	LA3_: ;
	colontmp_ = c__glbQoed0fMuhXSt1wQUc7w;
	colontmp__2 = t__afUUWAFqIJFXIEkjClESEA;
	(*s__G58rBzp9arUs2Le3q9bajUHA).d[(*s__G58rBzp9arUs2Le3q9bajUHA).len].Field0 = colontmp_;
	(*s__G58rBzp9arUs2Le3q9bajUHA).d[(*s__G58rBzp9arUs2Le3q9bajUHA).len].Field1 = colontmp__2;
	(*s__G58rBzp9arUs2Le3q9bajUHA).len += ((NI)1);
}
static N_INLINE(void, nimTraceRefDyn)(void* q__DU69bA8QWYzcJYHZK62MWjA, void* env__jq9cK8cvI9c0aQFP3P6pQbYA) {
	void** p;
	p = ((void**) (q__DU69bA8QWYzcJYHZK62MWjA));
	{
		tyObject_GcEnv__wrXjIZdIxCtzM9cDR1LtFhA* j;
		if (!!(((*p) == NIM_NIL))) goto LA3_;
		j = ((tyObject_GcEnv__wrXjIZdIxCtzM9cDR1LtFhA*) (env__jq9cK8cvI9c0aQFP3P6pQbYA));
		add__system_2821((&(*j).traceStack), p, (*((TNimTypeV2**) ((*p)))));
	}
	LA3_: ;
}
N_LIB_PRIVATE N_NIMCALL(void, eqtrace___OOZOOZOOZOOZOOZOOZOOZOOZOOZOnimbleZpkgsZjsony4549O49O53Zjsony_195)(tyObject_JsonError__iBRrIKmJWbkgrnAcChY3YA* dest__9ae0Rp9ajnKZiopHGc0kSIBQ, void* env__H7apztaaSmiz2HUcfTP6Mg) {
	nimTraceRefDyn(&(*dest__9ae0Rp9ajnKZiopHGc0kSIBQ).Sup.Sup.Sup.parent, env__H7apztaaSmiz2HUcfTP6Mg);
	eqtrace___stdZassertions_96((&(*dest__9ae0Rp9ajnKZiopHGc0kSIBQ).Sup.Sup.Sup.trace), env__H7apztaaSmiz2HUcfTP6Mg);
	nimTraceRefDyn(&(*dest__9ae0Rp9ajnKZiopHGc0kSIBQ).Sup.Sup.Sup.up, env__H7apztaaSmiz2HUcfTP6Mg);
}
