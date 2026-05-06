---
description: "Repository-wide code change instructions for vagrant-boxes"
applyTo: "**"
---

# Project code change instructions

Use these instructions for every code change in this repository.

## Required workflow

When you modify repository files,
follow this validation workflow before considering the work complete:

1. Run `make fmt` so the repository uses the expected formatting.
2. Run `make lint` so the change does not leave linting issues behind.

Do not skip the commands that apply to your change.
If one fails,
fix the issue and run the relevant commands again.

## Repository conventions

| Area       | Instruction                                                      |
| ---------- | ---------------------------------------------------------------- |
| Formatting | Use `make fmt` instead of formatting files manually.             |
| Linting    | Use `make lint` and leave the repository without linting errors. |
| Scope      | Make surgical changes and avoid unrelated edits.                 |

## Example completion checklist

```text
make fmt
make lint
```
