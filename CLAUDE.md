# CLAUDE.md

<br/>

## Project Structure

- Composite GitHub Action (no Docker image — `runs.using: composite`)
- One action covers both Ansible Galaxy publish paths:
  - **collection** → read version from `galaxy.yml` → `ansible-galaxy collection build` → `publish` (or dry-run + artifact upload)
  - **role**       → `ansible-galaxy role import` (or dry-run)
- Unified `namespace` + `name` input pair for both modes — no mode-specific flags
- `dry_run: true` validates inputs + (for collections) builds the tarball and uploads it as a workflow artifact — used by `ci.yml` and `use-action.yml` so neither needs a live API key

<br/>

## Key Files

- `action.yml` — composite action (**8 inputs**, **3 outputs**). Branch logic lives in a single inline `shell: bash` step ("Publish to Galaxy") followed by a conditional `actions/upload-artifact@v7` step for collection dry-runs.
- `tests/fixtures/sample_collection/` — minimal buildable collection (`galaxy.yml` + one role). CI dry-runs the collection path against it.
- `tests/fixtures/sample_role/` — minimal role (`meta/main.yml` + `tasks/main.yml`). CI dry-runs the role path against it.
- `cliff.toml` — git-cliff config for release notes.
- `Makefile` — `lint` (dockerized yamllint), `test` (`test-collection` + `test-role` locally), `fixtures`, `clean`.

<br/>

## Build & Test

There is no local "build" — composite actions execute on the GitHub Actions runner.

```bash
make lint              # yamllint action.yml + workflows + fixtures
make test              # local dry-run: build fixture collection + list fixture role
make test-collection   # only build the fixture collection
make test-role         # only sanity-check the fixture role metadata
make clean             # remove built collection tarballs
```

Local `make test` requires `ansible` on PATH (the CI-side install is handled by the action's `setup-python` + `pip install ansible` steps).

<br/>

## Workflows

- `ci.yml` — `lint` (yamllint + actionlint) + `test-collection` (dry-run against `tests/fixtures/sample_collection`, plus a `download-artifact` verify step that proves the upload worked) + `test-role` (dry-run against `tests/fixtures/sample_role`) + `ci-result` aggregator.
- `release.yml` — git-cliff release notes + `softprops/action-gh-release` + `somaz94/major-tag-action` for `v1` sliding tag.
- `use-action.yml` — post-release smoke test: `uses: somaz94/ansible-galaxy-publish-action@v1` against the same fixtures in both modes (dry-run).
- `gitlab-mirror.yml`, `changelog-generator.yml`, `contributors.yml`, `dependabot-auto-merge.yml`, `issue-greeting.yml`, `stale-issues.yml` — standard repo automation.

<br/>

## Release

Push a `vX.Y.Z` tag → `release.yml` runs → GitHub Release published → `v1` major tag updated → `use-action.yml` smoke-tests the published version against the fixture collection and role.

<br/>

## Action Inputs

Required: `type` (`collection` or `role`), `namespace`, `name`.

Conditional: `api_key` (required unless `dry_run: true`).

Tuning: `working_directory` (default `.`), `python_version` (default `3.12`), `ansible_version`, `dry_run` (default `false`).

See [README.md](README.md) for the full table.

<br/>

## Internal Flow

1. **Validate inputs** — `type` in {`collection`, `role`}; `namespace` + `name` non-empty; `api_key` required unless `dry_run=true`; `working_directory` exists.
2. **`actions/setup-python`** — installs the requested Python version.
3. **`pip install ansible`** — optional version pin via `ansible_version`; PyYAML is pulled in transitively and is used below to read `galaxy.yml`.
4. **Collection mode**:
   - `python -c 'yaml.safe_load(open("galaxy.yml"))["version"]'` → `collection_version` output
   - `ansible-galaxy collection build --force` in `working_directory`
   - Tarball path `<namespace>-<name>-<version>.tar.gz` → `artifact_path` output; `published_ref = collection/<ns>.<name>@<version>`
   - When `dry_run=false`: `ansible-galaxy collection publish <tarball> --api-key=<key>`
   - When `dry_run=true`: post-step uploads the tarball via `actions/upload-artifact@v7` as `collection-<ns>-<name>-<version>` (retention 7 days)
5. **Role mode**:
   - `published_ref = role/<namespace>.<name>`; `artifact_path=""`, `collection_version=""`
   - When `dry_run=false`: `ansible-galaxy role import --api-key <key> <namespace> <name>`
6. **Summary & outputs** — a markdown table (mode / namespace / name / version / ref / artifact) is appended to `$GITHUB_STEP_SUMMARY`; dry-run rows prefix the ref with `dry-run:`.
