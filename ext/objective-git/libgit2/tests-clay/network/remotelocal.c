#include "clay_libgit2.h"
#include "transport.h"
#include "buffer.h"
#include "path.h"

static git_repository *repo;
static git_buf file_path_buf = GIT_BUF_INIT;
static git_remote *remote;

static void build_local_file_url(git_buf *out, const char *fixture)
{
	git_buf path_buf = GIT_BUF_INIT;

	cl_git_pass(git_path_prettify_dir(&path_buf, cl_fixture(fixture), NULL));
	cl_git_pass(git_buf_puts(out, "file://"));

#ifdef _MSC_VER
	/*
	 * A FILE uri matches the following format: file://[host]/path
	 * where "host" can be empty and "path" is an absolute path to the resource.
	 * 
	 * In this test, no hostname is used, but we have to ensure the leading triple slashes:
	 * 
	 * *nix: file:///usr/home/...
	 * Windows: file:///C:/Users/...
	 */
	cl_git_pass(git_buf_putc(out, '/'));
#endif

	cl_git_pass(git_buf_puts(out, git_buf_cstr(&path_buf)));

	git_buf_free(&path_buf);
}

void test_network_remotelocal__initialize(void)
{
	cl_fixture("remotelocal");
	cl_git_pass(git_repository_init(&repo, "remotelocal/", 0));
	cl_assert(repo != NULL);

	build_local_file_url(&file_path_buf, "testrepo.git");

	cl_git_pass(git_remote_new(&remote, repo, git_buf_cstr(&file_path_buf), NULL));
	cl_git_pass(git_remote_connect(remote, GIT_DIR_FETCH));
}

void test_network_remotelocal__cleanup(void)
{
	git_remote_free(remote);
	git_buf_free(&file_path_buf);
	git_repository_free(repo);
	cl_fixture_cleanup("remotelocal");
}

static int count_ref__cb(git_remote_head *head, void *payload)
{
	int *count = (int *)payload;

	(void)head;
	(*count)++;

	return GIT_SUCCESS;
}

void test_network_remotelocal__retrieve_advertised_references(void)
{
	int how_many_refs = 0;

	cl_git_pass(git_remote_ls(remote, &count_ref__cb, &how_many_refs));

	cl_assert(how_many_refs == 12); /* 1 HEAD + 9 refs + 2 peeled tags */
}
