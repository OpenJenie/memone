# Contributing to Context Engineering

Thanks for contributing to Context Engineering in the
[`OpenJenie/memone`](https://github.com/OpenJenie/memone) repository.

This project is a Phoenix and Elixir application for capturing, querying, and
serving organizational knowledge to AI assistants. Contributions should improve
correctness, maintainability, developer experience, or the quality of the
knowledge workflows without widening scope unnecessarily.

## Before You Start

1. Read [README.md](README.md) first.
2. Search existing issues and pull requests before starting new work.
3. For larger changes, open or comment on an issue first so maintainers can
   confirm the scope.
4. Prefer focused changes over broad refactors.

## Local Setup

Requirements:

- Elixir 1.15+
- Erlang/OTP 26+
- PostgreSQL 14+ with `pgvector`
- roughly 2 GB of RAM for local ML-model workflows

Recommended setup:

```bash
git clone https://github.com/OpenJenie/memone.git
cd memone
mix deps.get
mix setup
mix test
mix phx.server
```

Visit `http://localhost:4000` after startup to verify the app is running.

For a containerized local environment, you can also use:

```bash
docker compose up
```

## Repository Shape

Keep new code aligned with the current structure:

- `lib/context_engineering`: core application logic, contexts, services, and workers
- `lib/context_engineering_web`: Phoenix transport layer
- `lib/mix/tasks`: contributor-facing CLI tasks such as `mix context.*`
- `config`: runtime and environment configuration
- `priv/repo`: migrations and seeds
- `apps`, `packages`, `infra`: reserved monorepo slices and supporting assets

Avoid moving business logic into controllers or `mix` tasks when it belongs in
the core application modules.

## Development Workflow

1. Create a branch from `main`.
2. Make a focused change.
3. Add or update tests for behavior changes.
4. Run the relevant checks locally.
5. Update docs when setup, commands, APIs, or workflows change.
6. Open a pull request with a clear summary and verification notes.

## Quality Expectations

Contributions should meet these standards:

- preserve the current Phoenix and context-module boundaries
- prefer readable Elixir over clever abstractions
- keep public docs aligned with implementation
- add `@doc` and `@moduledoc` where public code benefits from explanation
- avoid unrelated refactors in the same pull request

## Validation

At minimum, contributors should run:

```bash
mix test
mix precommit
```

`mix precommit` currently runs compilation with warnings as errors, dependency
cleanup checks, formatting, and tests.

Useful commands while working:

```bash
mix phx.server
mix docs
mix context.query "Why did we choose PostgreSQL?"
```

If your change touches database behavior, migrations, or seeded flows, mention
the exact commands you used in the pull request description.

## Pull Requests

A good PR includes:

- what changed
- why it changed
- how it was verified
- any follow-up work or tradeoffs

If the UI or rendered graph output changes, include screenshots when that helps
reviewers understand the impact.

## Good First Issues

Good starter work usually includes:

- documentation improvements
- test coverage for existing behavior
- small CLI or API fixes
- contributor workflow improvements
- tightly scoped bug fixes

If an issue is labeled `good first issue`, try to keep the solution small and
avoid opportunistic refactors around it.

## Questions

If an issue is underspecified, ask for clarification in the issue or PR before
expanding the scope. That is better than guessing.
