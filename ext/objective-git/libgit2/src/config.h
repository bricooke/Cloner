/*
 * Copyright (C) 2009-2011 the libgit2 contributors
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#ifndef INCLUDE_config_h__
#define INCLUDE_config_h__

#include "git2.h"
#include "git2/config.h"
#include "vector.h"
#include "repository.h"

#define GIT_CONFIG_FILENAME ".gitconfig"
#define GIT_CONFIG_FILENAME_INREPO "config"
#define GIT_CONFIG_FILE_MODE 0666

struct git_config {
	git_refcount rc;
	git_vector files;
};

extern int git_config_find_global_r(git_buf *global_config_path);
extern int git_config_find_system_r(git_buf *system_config_path);

#endif
