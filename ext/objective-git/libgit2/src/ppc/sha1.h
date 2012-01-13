/*
 * Copyright (C) 2009-2011 the libgit2 contributors
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#include <stdint.h>

typedef struct {
	uint32_t hash[5];
	uint32_t cnt;
	uint64_t len;
	union {
		unsigned char b[64];
		uint64_t l[8];
	} buf;
} ppc_SHA_CTX;

int ppc_SHA1_Init(ppc_SHA_CTX *c);
int ppc_SHA1_Update(ppc_SHA_CTX *c, const void *p, unsigned long n);
int ppc_SHA1_Final(unsigned char *hash, ppc_SHA_CTX *c);

#define SHA_CTX		ppc_SHA_CTX
#define SHA1_Init	ppc_SHA1_Init
#define SHA1_Update	ppc_SHA1_Update
#define SHA1_Final	ppc_SHA1_Final
