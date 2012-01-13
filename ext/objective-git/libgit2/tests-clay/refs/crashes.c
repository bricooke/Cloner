#include "clay_libgit2.h"

void test_refs_crashes__double_free(void)
{
	git_repository *repo;
	git_reference *ref, *ref2;
	const char *REFNAME = "refs/heads/xxx";

	cl_git_pass(git_repository_open(&repo, cl_fixture("testrepo.git")));
	cl_git_pass(git_reference_create_symbolic(&ref, repo, REFNAME, "refs/heads/master", 0));
	cl_git_pass(git_reference_lookup(&ref2, repo, REFNAME));
	cl_git_pass(git_reference_delete(ref));
	/* reference is gone from disk, so reloading it will fail */
	cl_must_fail(git_reference_reload(ref2));
}
