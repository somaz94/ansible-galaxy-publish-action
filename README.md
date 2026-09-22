# ansible-galaxy-publish-action

[![CI](https://github.com/somaz94/ansible-galaxy-publish-action/actions/workflows/ci.yml/badge.svg)](https://github.com/somaz94/ansible-galaxy-publish-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Latest Tag](https://img.shields.io/github/v/tag/somaz94/ansible-galaxy-publish-action)](https://github.com/somaz94/ansible-galaxy-publish-action/tags)
[![Top Language](https://img.shields.io/github/languages/top/somaz94/ansible-galaxy-publish-action)](https://github.com/somaz94/ansible-galaxy-publish-action)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Ansible%20Galaxy%20Publish%20Action-blue?logo=github)](https://github.com/marketplace/actions/ansible-galaxy-publish-action)

A composite GitHub Action that publishes an [Ansible](https://www.ansible.com/) **collection** or **role** to [Ansible Galaxy](https://galaxy.ansible.com/). Installs Python and Ansible, then either runs `ansible-galaxy collection build && publish` (collection mode) or `ansible-galaxy role import` (role mode). Supports `dry_run` for CI validation without a live API key, and uploads the built tarball as a workflow artifact in dry-run mode for manual inspection.

<br/>

## Features

- One action for both publish paths: **collection** (`build` + `publish`) and **role** (`import`) — selected via a single `type` input
- Unified `namespace` + `name` input pair for both modes (no mode-specific flags)
- `dry_run: true` validates inputs and — for collections — still builds the tarball and **uploads it as a workflow artifact**, without hitting Galaxy (ideal for pull-request CI)
- Version is read directly from `galaxy.yml`, so `published_ref` is deterministic (no filename scraping)
- Version pin for Ansible (`ansible_version`); empty = latest
- Writes a per-run summary table to `$GITHUB_STEP_SUMMARY`
- Exposes `published_ref`, `artifact_path`, and `collection_version` outputs

<br/>

## Requirements

- **Runner OS**: `ubuntu-latest` (also works on other OSes, but the rest of the Galaxy tooling is most commonly tested there).
- **Caller must run `actions/checkout`** before this action.
- **Python 3.10+** is recommended (default `3.12`).
- **Secret**: `GALAXY_API_KEY` (or any secret name you pass to `api_key`). Required unless `dry_run: true`.

<br/>

## Quick Start

### Publish an Ansible collection on tag push

```yaml
name: Publish to Ansible Galaxy
on:
  push:
    tags: ["v*"]
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: somaz94/ansible-galaxy-publish-action@v1
        with:
          type: collection
          api_key: ${{ secrets.GALAXY_API_KEY }}
          namespace: somaz94
          name: ansible_k8s_iac_tool
```

<br/>

### Import an Ansible role on tag push

```yaml
name: Publish to Ansible Galaxy
on:
  push:
    tags: ["v*"]
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: somaz94/ansible-galaxy-publish-action@v1
        with:
          type: role
          api_key: ${{ secrets.GALAXY_API_KEY }}
          namespace: somaz94
          name: ansible_kubectl_krew
```

<br/>

## Usage

### Dry-run in PR CI (no API key needed)

```yaml
- uses: actions/checkout@v6
- uses: somaz94/ansible-galaxy-publish-action@v1
  with:
    type: collection
    dry_run: true
    namespace: somaz94
    name: ansible_k8s_iac_tool
```

The build step still runs (so broken `galaxy.yml` / missing files fail CI), but no publish call is made. The built tarball is uploaded as a workflow artifact named `collection-<namespace>-<name>-<version>` so you can download and inspect it. The `published_ref` output is prefixed with `dry-run:` so downstream steps can branch on it.

<br/>

### Pin the Ansible version

```yaml
- uses: somaz94/ansible-galaxy-publish-action@v1
  with:
    type: collection
    api_key: ${{ secrets.GALAXY_API_KEY }}
    ansible_version: '9.5.1'
    namespace: somaz94
    name: ansible_k8s_iac_tool
```

<br/>

### Publish a collection that lives in a subdirectory

```yaml
- uses: somaz94/ansible-galaxy-publish-action@v1
  with:
    type: collection
    api_key: ${{ secrets.GALAXY_API_KEY }}
    working_directory: collections/somaz94/my_collection
    namespace: somaz94
    name: my_collection
```

<br/>

### Consume the outputs in a follow-up step

```yaml
- id: galaxy
  uses: somaz94/ansible-galaxy-publish-action@v1
  with:
    type: collection
    api_key: ${{ secrets.GALAXY_API_KEY }}
    namespace: somaz94
    name: ansible_k8s_iac_tool

- name: Report
  if: always()
  run: |
    echo "Published: ${{ steps.galaxy.outputs.published_ref }}"
    echo "Version:   ${{ steps.galaxy.outputs.collection_version }}"
    echo "Artifact:  ${{ steps.galaxy.outputs.artifact_path }}"
```

<br/>

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `type` | Publish target type: `collection` or `role`. | Yes | — |
| `api_key` | Ansible Galaxy API key. Required unless `dry_run: true`. | Conditional | `''` |
| `namespace` | Galaxy namespace (e.g., `somaz94`). Used for both modes; in collection mode it must match `galaxy.yml`. | Yes | — |
| `name` | Collection or role name under `namespace` (e.g., `ansible_k8s_iac_tool` or `ansible_kubectl_krew`). In collection mode it must match `galaxy.yml`. | Yes | — |
| `working_directory` | Directory containing `galaxy.yml` (collection) or `meta/main.yml` (role). | No | `.` |
| `python_version` | Python version for `actions/setup-python`. | No | `3.12` |
| `ansible_version` | pip pin for Ansible (e.g., `9.5.1`). Empty = latest. | No | `''` |
| `dry_run` | `true` or `false` (lowercase; any other value fails validation). When `true`, build the collection (if applicable), upload it as an artifact, and skip `publish`/`import`. | No | `false` |

<br/>

## Outputs

| Output | Description |
|--------|-------------|
| `published_ref` | Published reference, e.g., `collection/somaz94.ansible_k8s_iac_tool@1.2.0` or `role/somaz94.ansible_kubectl_krew`. Prefixed with `dry-run:` when `dry_run` is true. |
| `artifact_path` | Absolute path to the built collection tarball on the runner (collection mode only; empty for role mode). |
| `collection_version` | Version string read from `galaxy.yml` (collection mode only; empty for role mode). |

In `collection` + `dry_run: true` mode, the tarball is also uploaded as a workflow artifact named `collection-<namespace>-<name>-<version>` with a 7-day retention.

<br/>

## Permissions

The action itself needs no special permissions beyond what `actions/checkout` and `actions/setup-python` require. A typical caller:

```yaml
permissions:
  contents: read
```

The Galaxy API key is supplied via the `api_key` input (typically `${{ secrets.GALAXY_API_KEY }}`).

<br/>

## How It Works

1. **Validate inputs** — `type` must be `collection` or `role`; `namespace` and `name` are required; `dry_run` must be exactly `true` or `false` (lowercase — the artifact-upload condition compares case-insensitively while bash does not, so a value like `True` would split the mode); `api_key` is required unless `dry_run: true`.
2. **`actions/setup-python`** — installs the requested Python version.
3. **pip install** — installs `ansible` (or `ansible==<version>` if `ansible_version` is set); PyYAML comes as a transitive dependency.
4. **Collection mode**:
   - Read `namespace`, `name` and `version` from `galaxy.yml` via `yaml.safe_load` → emit `collection_version` output. Fails if `galaxy.yml` cannot be parsed, has no `version`, or its `namespace`/`name` differ from the inputs (the build names the tarball from `galaxy.yml`, so a mismatch could pick up a stale tarball)
   - `ansible-galaxy collection build --force` in `working_directory`
   - Locate the tarball `<namespace>-<name>-<version>.tar.gz` → expose via `artifact_path`
   - When `dry_run` is `false`, run `ansible-galaxy collection publish <tarball> --api-key=<key>`; when `true`, skip and upload the tarball as a workflow artifact
5. **Role mode**:
   - When `dry_run` is `false`, run `ansible-galaxy role import --api-key <key> <namespace> <name>`
6. **Summary & outputs** — a markdown table is appended to `$GITHUB_STEP_SUMMARY` (mode, namespace, name, version, ref, artifact). In dry-run mode the summary heading carries `dry-run`; only the `published_ref` output gets the `dry-run:` prefix.

<br/>

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
