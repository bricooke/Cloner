/*
 * Copyright (C) 2009-2011 the libgit2 contributors
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#ifndef INCLUDE_buffer_h__
#define INCLUDE_buffer_h__

#include "common.h"

typedef struct {
	char *ptr;
	ssize_t asize, size;
} git_buf;

extern char git_buf_initbuf[];

#define GIT_BUF_INIT { git_buf_initbuf, 0, 0 }

/**
 * Initialize a git_buf structure.
 *
 * For the cases where GIT_BUF_INIT cannot be used to do static
 * initialization.
 */
void git_buf_init(git_buf *buf, size_t initial_size);

/**
 * Grow the buffer to hold at least `target_size` bytes.
 *
 * If the allocation fails, this will return an error and the buffer
 * will be marked as invalid for future operations.  The existing
 * contents of the buffer will be preserved however.
 * @return GIT_SUCCESS or GIT_ENOMEM on failure
 */
int git_buf_grow(git_buf *buf, size_t target_size);

/**
 * Attempt to grow the buffer to hold at least `target_size` bytes.
 *
 * This is just like `git_buf_grow` except that even if the allocation
 * fails, the git_buf will still be left in a valid state.
 */
int git_buf_try_grow(git_buf *buf, size_t target_size);

void git_buf_free(git_buf *buf);
void git_buf_swap(git_buf *buf_a, git_buf *buf_b);
char *git_buf_detach(git_buf *buf);
void git_buf_attach(git_buf *buf, char *ptr, ssize_t asize);

/**
 * Test if there have been any reallocation failures with this git_buf.
 *
 * Any function that writes to a git_buf can fail due to memory allocation
 * issues.  If one fails, the git_buf will be marked with an OOM error and
 * further calls to modify the buffer will fail.  Check git_buf_oom() at the
 * end of your sequence and it will be true if you ran out of memory at any
 * point with that buffer.
 * @return 0 if no error, 1 if allocation error.
 */
int git_buf_oom(const git_buf *buf);

/**
 * Just like git_buf_oom, except returns appropriate error code.
 * @return GIT_ENOMEM if allocation error, GIT_SUCCESS if not.
 */
int git_buf_lasterror(const git_buf *buf);

/*
 * The functions below that return int values, will return GIT_ENOMEM
 * if they fail to expand the git_buf when they are called, otherwise
 * GIT_SUCCESS.  Passing a git_buf that has failed an allocation will
 * automatically return GIT_ENOMEM for all further calls.  As a result,
 * you can ignore the return code of these functions and call them in a
 * series then just call git_buf_lasterror at the end.
 */
int git_buf_set(git_buf *buf, const char *data, size_t len);
int git_buf_sets(git_buf *buf, const char *string);
int git_buf_putc(git_buf *buf, char c);
int git_buf_put(git_buf *buf, const char *data, size_t len);
int git_buf_puts(git_buf *buf, const char *string);
int git_buf_printf(git_buf *buf, const char *format, ...) GIT_FORMAT_PRINTF(2, 3);
void git_buf_clear(git_buf *buf);
void git_buf_consume(git_buf *buf, const char *end);
void git_buf_truncate(git_buf *buf, ssize_t len);

int git_buf_join_n(git_buf *buf, char separator, int nbuf, ...);
int git_buf_join(git_buf *buf, char separator, const char *str_a, const char *str_b);

/**
 * Join two strings as paths, inserting a slash between as needed.
 * @return error code or GIT_SUCCESS
 */
GIT_INLINE(int) git_buf_joinpath(git_buf *buf, const char *a, const char *b)
{
	return git_buf_join(buf, '/', a, b);
}

GIT_INLINE(const char *) git_buf_cstr(git_buf *buf)
{
	return buf->ptr;
}


void git_buf_copy_cstr(char *data, size_t datasize, const git_buf *buf);

#define git_buf_PUTS(buf, str) git_buf_put(buf, str, sizeof(str) - 1)

#endif
