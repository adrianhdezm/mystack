# Empty Remote Check

Before cloning, determine whether a default branch exists. If `defaultBranchRef` was already fetched in `02-missing-local-target.md`, reuse that value instead of querying again:

```sh
gh repo view "$REPOSITORY" --json defaultBranchRef
```

If `defaultBranchRef` is null, treat the remote as empty. If a default branch exists, treat the repository as not empty and stop. Try to list tracked files for the stop message:

```sh
DEFAULT_BRANCH="$(gh repo view "$REPOSITORY" --json defaultBranchRef --jq '.defaultBranchRef.name')"
DEFAULT_BRANCH_SHA="$(DEFAULT_BRANCH="$DEFAULT_BRANCH" gh api "repos/$REPOSITORY/git/matching-refs/heads" --jq '.[] | select(.ref == ("refs/heads/" + env.DEFAULT_BRANCH)) | .object.sha')"
gh api "repos/$REPOSITORY/git/trees/$DEFAULT_BRANCH_SHA?recursive=1" --jq '.tree[]?.path'
```

If the listing command fails, still stop because a default branch exists.
