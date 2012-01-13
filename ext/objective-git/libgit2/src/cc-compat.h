/*
 * Copyright (C) 2009-2011 the libgit2 contributors
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#ifndef INCLUDE_compat_h__
#define INCLUDE_compat_h__

/*
 * See if our compiler is known to support flexible array members.
 */
#ifndef GIT_FLEX_ARRAY
#	if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901L)
#		define GIT_FLEX_ARRAY /* empty */
#	elif defined(__GNUC__)
#		if (__GNUC__ >= 3)
#			define GIT_FLEX_ARRAY /* empty */
#		else
#			define GIT_FLEX_ARRAY 0 /* older GNU extension */
#		endif
#	endif

/* Default to safer but a bit wasteful traditional style */
#	ifndef GIT_FLEX_ARRAY
#		define GIT_FLEX_ARRAY 1
#	endif
#endif

#ifdef __GNUC__
#	define GIT_TYPEOF(x) (__typeof__(x))
#else
#	define GIT_TYPEOF(x)
#endif

#ifdef __cplusplus
#	define GIT_UNUSED(x)
#else
#	ifdef __GNUC__
#		define GIT_UNUSED(x) x __attribute__ ((__unused__))
#	else
#		define GIT_UNUSED(x) x
#	endif
#endif

#if defined(_MSC_VER)
#define GIT_UNUSED_ARG(x) ((void)(x)); /* note trailing ; */
#else
#define GIT_UNUSED_ARG(x)
#endif

/* Define the printf format specifer to use for size_t output */
#if defined(_MSC_VER) || defined(__MINGW32__)
#	define PRIuZ "Iu"
#else
#	define PRIuZ "zu"
#endif

/* Micosoft Visual C/C++ */
#if defined(_MSC_VER)
/* disable "deprecated function" warnings */
#	pragma warning ( disable : 4996 )
/* disable "conditional expression is constant" level 4 warnings */
#	pragma warning ( disable : 4127 )
#endif

#endif /* INCLUDE_compat_h__ */
