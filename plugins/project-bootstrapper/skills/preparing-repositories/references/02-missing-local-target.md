# Missing Local Target

If `LOCAL_FOLDER` does not exist, ask before creating it:

```sh
mkdir -p "$LOCAL_FOLDER"
```

If `LOCAL_REPOSITORY_PATH` does not exist, inspect the remote:

```sh
gh repo view "$REPOSITORY" --json nameWithOwner,isPrivate,defaultBranchRef
```

If the repository does not exist, ask for visibility unless already provided, then create it:

```sh
gh repo create "$REPOSITORY" --private
# or: gh repo create "$REPOSITORY" --public
```

After creating it, set the status to `created-and-cloned`; otherwise set it to `cloned`.
