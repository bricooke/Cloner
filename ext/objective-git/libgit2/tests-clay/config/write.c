#include "clay_libgit2.h"

void test_config_write__initialize(void)
{
	cl_fixture_sandbox("config/config9");
}

void test_config_write__cleanup(void)
{
	cl_fixture_cleanup("config9");
}

void test_config_write__replace_value(void)
{
	git_config *cfg;
	int i;
	int64_t l, expected = +9223372036854775803;

	/* By freeing the config, we make sure we flush the values  */
	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_set_int32(cfg, "core.dummy", 5));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_get_int32(cfg, "core.dummy", &i));
	cl_assert(i == 5);
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_set_int32(cfg, "core.dummy", 1));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_set_int64(cfg, "core.verylong", expected));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_get_int64(cfg, "core.verylong", &l));
	cl_assert(l == expected);
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_must_fail(git_config_get_int32(cfg, "core.verylong", &i));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_set_int64(cfg, "core.verylong", 1));
	git_config_free(cfg);
}

void test_config_write__delete_value(void)
{
	git_config *cfg;
	int32_t i;

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_set_int32(cfg, "core.dummy", 5));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_git_pass(git_config_delete(cfg, "core.dummy"));
	git_config_free(cfg);

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_assert(git_config_get_int32(cfg, "core.dummy", &i) == GIT_ENOTFOUND);
	cl_git_pass(git_config_set_int32(cfg, "core.dummy", 1));
	git_config_free(cfg);
}

void test_config_write__delete_inexistent(void)
{
	git_config *cfg;

	cl_git_pass(git_config_open_ondisk(&cfg, "config9"));
	cl_assert(git_config_delete(cfg, "core.imaginary") == GIT_ENOTFOUND);
	git_config_free(cfg);
}
