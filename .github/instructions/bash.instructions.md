---
description: "Bash-specific instructions for shell changes in vagrant-boxes"
applyTo: "build.sh, **/*.sh"
---

# Bash change instructions

Use these instructions when working on Bash scripts in this repository.

## Required workflow

When you change Bash scripts or Bash-driven behavior,
follow this validation workflow before considering the work complete:

1. Run `make test` so ShellSpec coverage still passes for Bash changes.

## Repository conventions

- Use `make test` for Bash script changes.
- ShellSpec is the project test entrypoint.

## Shell script guidance

Prefer existing shell patterns already used in the repository.
For changes to `build.sh` and related shell scripts:

- run `make test`
  after changing Bash scripts or Bash-driven behavior
- keep Bash syntax compatible with Bash 3.2
- avoid introducing newer Bash-only features such as associative arrays or
  `mapfile`
- preserve explicit error handling with `set -o pipefail`, `errexit`, and
  `nounset` when working in existing scripts

## Google Shell Style Guide

Follow the Google Shell Style Guide:
<https://google.github.io/styleguide/shellguide.html>.

Apply these expectations to new and revised shell code:

- prefer `$(...)` command substitution over backticks
- use `[[ ... ]]` for conditionals
- always quote variable expansions unless intentional word splitting is needed
- prefer local variables in functions (`local name=value`)
- use `readonly` for constants and avoid magic values
- keep functions small and focused with clear names
- prefer helper functions over repeated inline command sequences
- use `main` for non-trivial scripts and call it at the end
- check command exit status and return explicit errors where helpful
- keep comments concise and focused on non-obvious behavior

## Example completion checklist

```text
make test
```
