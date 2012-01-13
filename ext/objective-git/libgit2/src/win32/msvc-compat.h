/*
 * Copyright (C) 2009-2011 the libgit2 contributors
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#ifndef INCLUDE_msvc_compat__
#define INCLUDE_msvc_compat__

#if defined(_MSC_VER)

/* access() mode parameter #defines	*/
#	define F_OK 0 /* existence check */
#	define W_OK 2 /* write mode check */
#	define R_OK 4 /* read mode check */

#	define lseek _lseeki64
#	define stat _stat64
#	define fstat _fstat64

/* stat: file mode type testing macros */
#	define _S_IFLNK 0120000
#	define S_IFLNK _S_IFLNK

#	define S_ISDIR(m)	(((m) & _S_IFMT) == _S_IFDIR)
#	define S_ISREG(m)	(((m) & _S_IFMT) == _S_IFREG)
#	define S_ISFIFO(m) (((m) & _S_IFMT) == _S_IFIFO)
#	define S_ISLNK(m) (((m) & _S_IFMT) == _S_IFLNK)

#	define mode_t unsigned short

/* case-insensitive string comparison */
#	define strcasecmp	_stricmp
#	define strncasecmp _strnicmp

#endif

#endif /* INCLUDE_msvc_compat__ */
