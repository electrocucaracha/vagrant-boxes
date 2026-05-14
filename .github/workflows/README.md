# Available workflows

<!-- markdownlint-disable MD013 -->

| Workflow               | Purpose                                                                                        | Events                   |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ------------------------ |
| [ci](./ci.yml)         | Runs shell specs, documentation link checks, and functional build tests for supported distros. | push, pull_request       |
| [linter](./linter.yml) | Counts lines of code and executes lint validations across the repository.                      | push, pull_request       |
| [update](./update.yml) | Verifies and updates version files, then opens a pull request with the changes.                | schedule, manual trigger |

<!-- markdownlint-enable MD013 -->

## Available labels

- super-linter-issue:
  Opened automatically when the super-linter workflow fails,
  and needs follow-up.
