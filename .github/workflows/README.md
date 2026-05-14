# Available workflows

- [ci](./ci.yml):
  Runs shell specs, documentation link checks,
  and functional build tests for supported distros.
  Run event: on push and pull request.
- [linter](./linter.yml):
  Counts lines of code,
  and executes lint validations across the repository.
  Run event: on push and pull request.
- [update](./update.yml):
  Verifies and updates version files,
  then opens a pull request with the changes.
  Run event: scheduled/manual trigger.

## Available labels

- super-linter-issue:
  Opened automatically when the super-linter workflow fails,
  and needs follow-up.
