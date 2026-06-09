# Existing Local Target

If `LOCAL_REPOSITORY_PATH` exists, do not create or clone anything until it passes these checks:

```sh
test -d "$LOCAL_REPOSITORY_PATH/.git"
```

Verify the local clone points to the requested repository:

```sh
LOCAL_REMOTE="$(cd "$LOCAL_REPOSITORY_PATH" && gh repo view --json nameWithOwner --jq '.nameWithOwner')"
test "$LOCAL_REMOTE" = "$REPOSITORY"
```

Verify there are no pre-existing local files beyond repository metadata:

```sh
find "$LOCAL_REPOSITORY_PATH" -mindepth 1 -maxdepth 1 ! -name .git -print
```

If this prints any path, stop. Do not bootstrap over pre-existing local files, even basic files such as `README.md`, `.gitignore`, or `LICENSE`. This restriction applies before the Product Builder bootstrap starts; files created by the bootstrap are expected to be reused and updated by later bootstrap steps.

If all checks pass, skip remote creation and cloning, then return:

```text
LOCAL_REPOSITORY_PATH: <absolute path>
REPOSITORY_STATUS: existing-local
```
