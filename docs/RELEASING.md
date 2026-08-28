# Releasing

## Versioning

Semantic Versioning, `MAJOR.MINOR.PATCH`. Tags are `vX.Y.Z`.

Within a major version, skill names and directory layout stay put. That is the promise
anyone copying or symlinking a skill folder depends on. A skill's content can change in a
minor release; renaming or moving one waits for a major.

## Where the version lives

In `plugin.json`, the Agent Plugins manifest. Clients read the version from there, so it
has to be right, which makes it the anchor.

`CHANGELOG.md` carries the same version in its top `## [x.y.z]` heading, because a release
note without a version is useless. Two files holding one number would normally drift, so
`validate-skills.sh` fails the build when they disagree. Bump both, or neither.

## Cutting a release

1. `./scripts/test-all.sh` passes and CI is green on `main`.
2. Move the entries under `[Unreleased]` into a new `## [x.y.z] - YYYY-MM-DD` section and
   update the link definitions at the bottom of the file.
3. Set the same version in `plugin.json` and run `./scripts/validate-skills.sh`.
4. Commit, tag `vx.y.z`, push the tag.
5. Create the GitHub release from the tag, using that changelog section as the body.

Steps 4 and 5 are deliberately manual. Automating them can wait until doing it by hand
starts to feel like a chore.
