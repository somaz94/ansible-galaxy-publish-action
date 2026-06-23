# Changelog

All notable changes to this project will be documented in this file.

## Unreleased (2026-06-23)

### Documentation

- update upload-artifact reference to @v7 in CLAUDE.md ([bd18763](https://github.com/somaz94/ansible-galaxy-publish-action/commit/bd18763bc4e25a347daca2c164834913eccf4bf3))

### Continuous Integration

- add DCO check via shared reusable workflow ([e39cc21](https://github.com/somaz94/ansible-galaxy-publish-action/commit/e39cc21203b2f10d4a2bc41ae32dd1490fdfa09f))
- add concurrency guards to recurring workflows ([8a2b4fd](https://github.com/somaz94/ansible-galaxy-publish-action/commit/8a2b4fdbffb8e7a75024afecdd9e1457c7e99953))

### Chores

- **deps:** bump actions/checkout from 6 to 7 ([63f7616](https://github.com/somaz94/ansible-galaxy-publish-action/commit/63f76166206e0612342978c066c594cdcdf54dbc))
- **deps:** bump actions/upload-artifact from 4 to 7 ([8517ffe](https://github.com/somaz94/ansible-galaxy-publish-action/commit/8517ffeef944e348fac34949d20911f97cda6d81))
- **deps:** bump actions/download-artifact from 4 to 8 ([ab3d723](https://github.com/somaz94/ansible-galaxy-publish-action/commit/ab3d7239d4975d5def24c29b72254fbcb8c258d9))
- drop unused docker dependabot ecosystem (composite action, no Dockerfile) ([4bf6ef2](https://github.com/somaz94/ansible-galaxy-publish-action/commit/4bf6ef2e478261bf5f3d04e5deedbde6de602157))
- set CODEOWNERS to @somaz94 ([c61c2f4](https://github.com/somaz94/ansible-galaxy-publish-action/commit/c61c2f40a31214009f0aad7860bdfe9acdde60ba))

### Contributors

- somaz

<br/>

## [v1.1.0](https://github.com/somaz94/ansible-galaxy-publish-action/compare/v1.0.0...v1.1.0) (2026-04-21)

### Code Refactoring

- **action:** unify namespace+name inputs, derive version from galaxy.yml, upload dry-run artifact, polish summary ([12fb2a7](https://github.com/somaz94/ansible-galaxy-publish-action/commit/12fb2a77531d0e1ccce66548bf2fb6c26e8b0c89))

### Chores

- **deps:** bump softprops/action-gh-release from 2 to 3 ([4526385](https://github.com/somaz94/ansible-galaxy-publish-action/commit/4526385b0f6dc13a11753f3ee568121e41d95605))

### Contributors

- somaz

<br/>

## [v1.0.0](https://github.com/somaz94/ansible-galaxy-publish-action/releases/tag/v1.0.0) (2026-04-21)

### Features

- implement ansible-galaxy-publish-action ([058d19b](https://github.com/somaz94/ansible-galaxy-publish-action/commit/058d19bff5747b5d819ee145db85dee7e1db6043))

### Continuous Integration

- add release, mirror, and changelog workflows ([d7cd1b4](https://github.com/somaz94/ansible-galaxy-publish-action/commit/d7cd1b4018422952545e584ff93dc44e786ba52f))

### Chores

- add baseline repo files and license ([480acd9](https://github.com/somaz94/ansible-galaxy-publish-action/commit/480acd9db9ee546d0536466f37e91246d0df0f9a))

### Contributors

- somaz

<br/>

