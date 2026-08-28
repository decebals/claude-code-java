# Releasing

## Versioning

Semantic Versioning, `MAJOR.MINOR.PATCH`. Tags are `vX.Y.Z`.

Within a major version, skill names and directory layout stay put. That is the promise
anyone copying or symlinking a skill folder depends on. A skill's content can change in a
minor release; renaming or moving one waits for a major.

## Where the version lives

In `CHANGELOG.md`. The top `## [x.y.z]` heading is the released version:

```bash
grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md
```

There is no build here, so a separate version file would exist only to be bumped and would
eventually drift from the changelog. The changelog has to be edited at release time anyway,
which makes it the one place that cannot fall behind.

## Cutting a release

1. `./scripts/test-all.sh` passes and CI is green on `main`.
2. Move the entries under `[Unreleased]` into a new `## [x.y.z] - YYYY-MM-DD` section and
   update the link definitions at the bottom of the file.
3. Commit, tag `vx.y.z`, push the tag.
4. Create the GitHub release from the tag, using that changelog section as the body.

Steps 3 and 4 are deliberately manual. Automating them can wait until doing it by hand
starts to feel like a chore.
