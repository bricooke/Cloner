#include "clay_libgit2.h"

#include "filebuf.h"
#include "fileops.h"
#include "posix.h"

#define TEST_CONFIG "git-new-config"

void test_config_new__write_new_config(void)
{
	const char *out;
	struct git_config_file *file;
	git_config *config;

	cl_git_pass(git_config_file__ondisk(&file, TEST_CONFIG));
	cl_git_pass(git_config_new(&config));
	cl_git_pass(git_config_add_file(config, file, 0));

	cl_git_pass(git_config_set_string(config, "color.ui", "auto"));
	cl_git_pass(git_config_set_string(config, "core.editor", "ed"));

	git_config_free(config);

	cl_git_pass(git_config_file__ondisk(&file, TEST_CONFIG));
	cl_git_pass(git_config_new(&config));
	cl_git_pass(git_config_add_file(config, file, 0));

	cl_git_pass(git_config_get_string(config, "color.ui", &out));
	cl_assert(strcmp(out, "auto") == 0);
	cl_git_pass(git_config_get_string(config, "core.editor", &out));
	cl_assert(strcmp(out, "ed") == 0);

	git_config_free(config);

	p_unlink(TEST_CONFIG);
}
