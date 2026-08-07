<!-- Markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.4.0] - 2026-08-07

### Added

- Enabled automatic text style consistency checking and correction for documentation and prose files through the fmt target in the Makefile. [c532d710](https://github.com/electrocucaracha/vagrant-boxes/commit/c532d710fb68e59b4fe48f56dc7d766388e9293d)

## [4.3.1] - 2026-08-07

### Changed

- Optimized lint and fmt tasks by automatically removing node_modules and Python environments before running them to ensure consistent results across environments. [be199d59](https://github.com/electrocucaracha/vagrant-boxes/commit/be199d590e6d74805612e7c733dbf669ad3b51e7)

## [4.3.0] - 2026-08-07

### Added

- Enabled consistent terminology usage across documentation and prose files by enforcing it through textlint rules. [09a232f7](https://github.com/electrocucaracha/vagrant-boxes/commit/09a232f7ab7e2df57153d572edef55f7d3eff0d5)

## [4.2.2] - 2026-08-07

### Fixed

- The linter now checks all files in the codebase and deployments, potentially increasing reported issues for previously excluded files, thereby improving code quality and consistency without any breaking behavior or migration requirements. [8678c963](https://github.com/electrocucaracha/vagrant-boxes/commit/8678c9633e3d233c37f1d6947c6924671580122b)

## [4.2.1] - 2026-08-07

### Changed

- Clarified terminology and capitalization in changelog to maintain uniform style across documentation without introducing any functional or behavioral modifications. [5ca286a0](https://github.com/electrocucaracha/vagrant-boxes/commit/5ca286a00eeb4f299cecf4bbe08fda11d029fa18)

## [4.2.0] - 2026-08-07

### Added

- Introduced a comprehensive CHANGELOG.md file following the Keep a Changelog format and Semantic Versioning, enabling clear traceability for releases and improving project transparency with consistent documentation in a single location. [61ba3e7e](https://github.com/electrocucaracha/vagrant-boxes/commit/61ba3e7e68aa8907d23ce69480f8f6117093f2ea)

## [4.1.0] - 2026-08-07

### Added

- Enabled support for self-contained documentation by relaxing Markdownlint rules to permit multiple H1 headings and longer lines. [7b28120c](https://github.com/electrocucaracha/vagrant-boxes/commit/7b28120cfa66d1c43e9b983d79eb64c9f44b086e)

## [4.0.0] - 2026-08-07

### Removed

- Simplified maintenance overhead by eliminating unnecessary configuration setup through removal of the .jscpd.json file which is no longer required for the current workflow. [e4347414](https://github.com/electrocucaracha/vagrant-boxes/commit/e43474148c3725513064303c61f4300f397437b1)

## [3.1.10] - 2026-08-07

### Changed

- Stabilized CI workflows to rely on the latest stable versions of GitHub Actions, thereby ensuring improved security, bugfixes, and compatibility with upstream changes without altering workflow logic. [6d42ecb0](https://github.com/electrocucaracha/vagrant-boxes/commit/6d42ecb0cf8b0f096214dabe044d1f1acf183a25)

## [3.1.9] - 2026-08-07

### Changed

- Unified GitHub Actions commit hash resolution to centralize and simplify version matching for both standard and exceptional cases. [1c67f7ce](https://github.com/electrocucaracha/vagrant-boxes/commit/1c67f7ce71bcb8c46f5a778511808ed3281f6b4a)

## [3.1.8] - 2026-08-07

### Changed

- modernized linting and commit message generation to ensure compatibility with recent pre-commit framework changes and maintain code quality by reducing manual maintenance efforts. [f34df60e](https://github.com/electrocucaracha/vagrant-boxes/commit/f34df60e68c66e06ac3e925d609fc3e93ea2e7f9)

## [3.1.7] - 2026-06-05

### Changed

- Updated the pre-commit hook for ai-prepare-commit-msg to ensure compatibility with the latest features and bugfixes without introducing any functional modifications. [08a1cc02](https://github.com/electrocucaracha/vagrant-boxes/commit/08a1cc02f8a40b27c0b17b5395eb31b66d75400f)

## [3.1.6] - 2026-06-05

### Fixed

- Resolved linting issues caused by stricter rules in newer markdownlint version by reverting to v0.47.0 for consistent behavior across all Markdown files. [d0dd9340](https://github.com/electrocucaracha/vagrant-boxes/commit/d0dd9340d076182378dbfdd472613213fbdf2886)

## [3.1.5] - 2026-06-05

### Changed

- Updated GitHub Actions to their latest versions, ensuring access to recent features and fixes while maintaining stability for critical components through the addition of 'golangci/golangci-lint-action' and 'actions/checkout' to the list of exceptions in ci/update_versions.sh. [e038fe4c](https://github.com/electrocucaracha/vagrant-boxes/commit/e038fe4c2c0c815a69f61bb13f4901db0d02354d)

## [3.1.4] - 2026-06-05

### Fixed

- Resolved compatibility issues by updating the pre-commit hook for ai-prepare-commit-msg to point to the latest revision. [65bfc5e9](https://github.com/electrocucaracha/vagrant-boxes/commit/65bfc5e93fdc2adf507be225b1fa6772d8188078)

## [3.1.3] - 2026-06-05

### Fixed

- BREAKING: Stabilized pre-commit hooks to their latest versions, ensuring consistent code quality checks across the repository by incorporating recent bugfixes and improvements, but this update may introduce new linter rules requiring adjustments to existing Markdown files or commit message formats. [2c5ad4a3](https://github.com/electrocucaracha/vagrant-boxes/commit/2c5ad4a3f379f3af4e19f989a3ce4d454caa731b)

## [3.1.2] - 2026-06-05

### Changed

- Enabled a copy code button to enhance user experience when copying code snippets from the documentation, and updated the theme to just-the-docs for improved structure and styling without introducing any breaking changes. [234ff1c0](https://github.com/electrocucaracha/vagrant-boxes/commit/234ff1c00eac3ceab45d71ff98e2c093ff6a129c)

## [3.1.1] - 2026-05-22

### Fixed

- Resolved the pre-commit environment installation failures caused by Node.js incompatibility by reverting to an earlier version of markdownlint-cli that is compatible with the current Node.js version. [a145ac48](https://github.com/electrocucaracha/vagrant-boxes/commit/a145ac4851d69e309f556032ae3984d2b150e843)

## [3.1.0] - 2026-05-18

### Added

- Enabled SSH host key regeneration via a systemd oneshot service that generates keys only if missing before the SSH daemon starts reducing the risk of failed SSH startups and improving overall reliability. [13b98269](https://github.com/electrocucaracha/vagrant-boxes/commit/13b98269717954e6db20bca9f2515863e54e59a5)

## [3.0.6] - 2026-05-17

### Changed

- Upgraded the AI Linter Analysis step to version 2.1.0 of the actions/ai-inference action which may include bugfixes new features and performance improvements from upstream helping maintain workflow reliability and security by keeping dependencies up to date. [2d779e65](https://github.com/electrocucaracha/vagrant-boxes/commit/2d779e658d3eed4453392c2c9d7afba339b80285)

## [3.0.5] - 2026-05-17

### Changed

- Optimized build efficiency by enabling Packer cache and updating ai-inference action to version 2.1.0 for access to the latest features and fixes. [d29aa883](https://github.com/electrocucaracha/vagrant-boxes/commit/d29aa8839bf352091a7730e2de90bdac5542a632)

## [3.0.4] - 2026-05-17

### Changed

- Updated the ai-prepare-commit-msg pre-commit hook to ensure that developers benefit from the latest improvements and bugfixes in their commit message preparation workflow. [a033b062](https://github.com/electrocucaracha/vagrant-boxes/commit/a033b0623de20ac0d2ef3c4d7d7f871a034d0900)

## [3.0.3] - 2026-05-17

### Changed

- Optimized SSH host key regeneration on first boot by introducing retry logic to handle transient errors during dpkg-reconfigure and systemctl restart operations, resulting in improved robustness of SSH connections on supported Ubuntu images. [04bfb1ba](https://github.com/electrocucaracha/vagrant-boxes/commit/04bfb1ba4dd9f5d4de19243b2eccb244ca43c6cb)

## [3.0.2] - 2026-05-17

### Changed

- Enabled real-time visibility of build progress in CI logs by piping output through tee without altering the underlying build process. [a9af054b](https://github.com/electrocucaracha/vagrant-boxes/commit/a9af054b3f810ff5929cbeb2e3174eeba68de8e2)

## [3.0.1] - 2026-05-17

### Changed

- Resolved super-linter false diagnosis by excluding intentional workflow clones and enriching AI failure evidence, enabling more accurate log collection and API interactions. [56203e2b](https://github.com/electrocucaracha/vagrant-boxes/commit/56203e2b659c6d82ea6b11bb694df8c50c114701)

## [3.0.0] - 2026-05-17

### Removed

- Simplified cleanup scripts for various Ubuntu versions to eliminate redundant `truncate --size=0` commands, improving script clarity and correctness without introducing breaking behavior or migration requirements, with no security impact, config schema changes, or primary user outcome affected. [22ff94e4](https://github.com/electrocucaracha/vagrant-boxes/commit/22ff94e40c92be63177405f40dc0d3b3f26cfe2a)

## [2.11.7] - 2026-05-17

### Changed

- Simplified the CI workflow by renaming the "AI Linter Analysis" step to "AI Build Output Analysis", improving clarity and maintainability without introducing breaking behavior or requiring migration steps. [3624e611](https://github.com/electrocucaracha/vagrant-boxes/commit/3624e6119a30cf12e6b58c07dc839c0d72706e16)

## [2.11.6] - 2026-05-17

### Changed

- Streamlined build failure triage by automatically uploading logs and AI-assisted analysis that diagnoses issues, proposes fixes, and assesses confidence, posting actionable insights to a new GitHub issue for maintainers. [70d7564f](https://github.com/electrocucaracha/vagrant-boxes/commit/70d7564f5b1d20465bbbe61ff78decca53be6202)

## [2.11.5] - 2026-05-16

### Changed

- Optimized functional tests to only run for Ubuntu distros that have relevant changes, reducing unnecessary CI runs and speeding up feedback without breaking existing behavior or requiring migration steps. [1cf98470](https://github.com/electrocucaracha/vagrant-boxes/commit/1cf98470115171995def931f1ee00dfd2dd39ebd)

## [2.11.4] - 2026-05-16

### Changed

- Enabled consistency in Ubuntu version documentation by introducing the correct Vagrant box link for Ubuntu 26.04, allowing users to access the resource directly. [1899df86](https://github.com/electrocucaracha/vagrant-boxes/commit/1899df863924cefa6d406ab3542804192eba3f0d)

## [2.11.3] - 2026-05-16

### Fixed

- Resolved SSH key regeneration for Ubuntu 26.04 by updating the regular expression to include '2604', ensuring consistent setup across supported versions and preventing incorrect configuration on affected images. [da94924c](https://github.com/electrocucaracha/vagrant-boxes/commit/da94924c512da39753571fa75399e7814cc46a29)

## [2.11.2] - 2026-05-15

### Fixed

- Resolved warnings about secrets being used incorrectly in GitHub workflow linter jobs by suppressing the zizmor secret-outside-env warning for the GITHUB_MCP_TOKEN secret. [26cc73a2](https://github.com/electrocucaracha/vagrant-boxes/commit/26cc73a29ddc52265cc0b21bee66e42f67c7d055)

## [2.11.1] - 2026-05-15

### Changed

- Optimized the linter workflow's output to reduce its size and improve readability within GitHub's annotation limits by capping changed files at 80, log files at 40, error excerpt lines at 80, and setting a 4000-byte limit on the commit diff excerpt while removing the raw log excerpt section for further size reduction. [745f6d23](https://github.com/electrocucaracha/vagrant-boxes/commit/745f6d23aaf47b8e81dbb37d153156b4afb61392)

## [2.11.0] - 2026-05-15

### Added

- Enabled detailed context collection for AI-driven linter failure analysis by passing relevant evidence to the AI Linter Analysis step via GitHub MCP tools, improving accuracy and actionability of root cause identification and remediation suggestions. [4a250319](https://github.com/electrocucaracha/vagrant-boxes/commit/4a2503197e2a4f5eff9234e55ffa25a36527eef1)

## [2.10.2] - 2026-05-14

### Changed

- Stabilized the GitHub Actions linter workflow to consistently reference artifacts via direct links to the workflow run page and ensured reliable super-linter version extraction by providing a jq failure fallback that sets the version as "unknown". [75337708](https://github.com/electrocucaracha/vagrant-boxes/commit/753377082b94754a99e1a6e167856077ae501181)

## [2.10.1] - 2026-05-14

### Changed

- The linter metadata is now reliably accessible to downstream steps in GitHub Actions workflows through its availability in both environment and output contexts. [bdd6faa0](https://github.com/electrocucaracha/vagrant-boxes/commit/bdd6faa0122ec83b9d9337b53d72ac1f086beac2)

## [2.10.0] - 2026-05-14

### Added

- Optimized CI performance by ensuring functional tests only run on code changes, eliminating unnecessary test executions and speeding up the build process for documentation or script-only updates. [df4256b0](https://github.com/electrocucaracha/vagrant-boxes/commit/df4256b05aa1a148ea545dab765948b5a34b0d15)

## [2.9.2] - 2026-05-14

### Changed

- Optimized the workflows list in documentation to improve readability and consistency by replacing bulleted list with Markdown table without affecting workflow behavior or API contracts. [8615d665](https://github.com/electrocucaracha/vagrant-boxes/commit/8615d6655f5f10def1cd263201435335e6b1d050)

## [2.9.1] - 2026-05-14

### Fixed

- Stabilized CI workflow reliability by using artifact URL output for linter logs instead of manually constructing URLs, ensuring robustness against GitHub format changes and enabling easier maintenance of log_url generation. [26e9f991](https://github.com/electrocucaracha/vagrant-boxes/commit/26e9f99112423711498ba27f7ef8d1dfa3b606f3)

## [2.9.0] - 2026-05-14

### Added

- Enabled support for custom self-hosted runner labels in CI workflows by configuring actionlint to recognize these labels and resolving compatibility issues with the super-linter. [34942c7c](https://github.com/electrocucaracha/vagrant-boxes/commit/34942c7c0186351c6c6c980b1839ec6a2ee012c4)

## [2.8.1] - 2026-05-13

### Changed

- Enabled direct links to Vagrant Cloud pages for Ubuntu 22.04 and 24.04 boxes in the readme file making it easier for users to access relevant resources and improving discoverability of supported Ubuntu releases. [c42cb73c](https://github.com/electrocucaracha/vagrant-boxes/commit/c42cb73cf1a9a67739a589dd1056b1ceaf7dc99a)

## [2.8.0] - 2026-05-13

### Added

- Enabled clear documentation of GitHub Actions workflows and automation for contributors by introducing a readme file in the .github/workflows directory that describes available ci, linter, and update workflows as well as the "super-linter-issue" label. [a708a00f](https://github.com/electrocucaracha/vagrant-boxes/commit/a708a00f460a8296d13f8478593c6d468f34f66f)

## [2.7.0] - 2026-05-13

### Added

- Enabled functional tests on self-hosted runners across multiple Ubuntu distributions by introducing a new job to the CI workflow that installs necessary build prerequisites and runs the build script with debugging enabled, improving test coverage and reliability in a controlled environment. [41ffe803](https://github.com/electrocucaracha/vagrant-boxes/commit/41ffe8032221b30e2e4d8a52ee74e60c0c2f7b63)

## [2.6.0] - 2026-05-13

### Added

- Enabled clearer expectations for syntax, quoting, variable usage, function structure, and error handling in shell scripts by incorporating guidelines from the Google Shell Style Guide, preferring $(...) command substitution over backticks and using [[ ... [df0a90cf](https://github.com/electrocucaracha/vagrant-boxes/commit/df0a90cfdb5b1f95094f78b09370f8eff682f570)

## [2.5.4] - 2026-05-09

### Fixed

- Stabilized linter metadata step and permissions to prevent line-length errors reported by Yamllint and provided a prompt for AI Linter Analysis with environment variables without introducing any breaking behavior or migration requirements. [fe05b5fd](https://github.com/electrocucaracha/vagrant-boxes/commit/fe05b5fd2e3f8296da1e537efd2ed7506ae59569)

## [2.5.3] - 2026-05-08

### Changed

- Optimized documentation for consuming published Vagrant boxes to improve clarity, structure, and consistency across all guides, making it more accessible to new users and reducing ambiguity in the process. [826f72ef](https://github.com/electrocucaracha/vagrant-boxes/commit/826f72efa708d910de78c9070b01af072193932a)

## [2.5.2] - 2026-05-08

### Changed

- Improved the Continuous Integration workflow to only run documentation link checks when actual documentation changes occur and added consistency in environment variable quoting across workflows. [d9638324](https://github.com/electrocucaracha/vagrant-boxes/commit/d9638324ef72034e85482761ec915de432533a9e)

## [2.5.1] - 2026-05-06

### Fixed

- Resolved both zizmor secrets-outside-env warnings and ava@7 Node.js engine incompatibilities by updating WORKFLOW_TOKEN secret usage to ignore the warning and downgrading markdownlint-cli to a compatible version. [2278a5b7](https://github.com/electrocucaracha/vagrant-boxes/commit/2278a5b776def1e18a7540fb850acd4ea47f56cc)

## [2.5.0] - 2026-05-06

### Added

- Automated version updates are now enabled through a scheduled GitHub Actions workflow that runs weekly and on demand, ensuring dependencies stay current and improving security and reliability by reducing manual maintenance. [c7499cf3](https://github.com/electrocucaracha/vagrant-boxes/commit/c7499cf3ff059fe6b51da8cb85d870a9236d2856)

## [2.4.2] - 2026-05-06

### Changed

- Updated markdownlint-cli to v0.48.0 for improved Markdown linting and better alignment with current best practices. [5ef0b6b6](https://github.com/electrocucaracha/vagrant-boxes/commit/5ef0b6b6ffe7c92200376b2b2e4424fe97ccfa54)

## [2.4.1] - 2026-05-06

### Changed

- Standardized YAML style across the repository by enforcing line length and comment spacing rules through the introduction of .yaml-lint.yml and .yamlfmt configurations. [e66a5034](https://github.com/electrocucaracha/vagrant-boxes/commit/e66a50347ad86d049b3ed7b86251be78e2cd14b2)

## [2.4.0] - 2026-05-06

### Added

- Introduced a Jekyll configuration to set up the Cayman theme and include license and copyright headers under Apache-2.0, modernizing the documentation site's appearance and licensing information without affecting breaking behavior or migration requirements. [7529e84a](https://github.com/electrocucaracha/vagrant-boxes/commit/7529e84a72baabc6a4659ca4d5879ca072e55096)

## [2.3.1] - 2026-05-06

### Changed

- Optimized pre-commit checks to ignore stylistic differences automatically applied by shfmt, preventing unnecessary manual intervention due to formatting changes like tab indentation and function declaration styles. [4d590ba6](https://github.com/electrocucaracha/vagrant-boxes/commit/4d590ba621558239aa7af8ce01a10d6ee47cb3d0)

## [2.3.0] - 2026-05-06

### Added

- Enabled standardized contributions to Bash scripts in the repository by providing detailed instructions on required workflows and conventions for maintaining compatibility with Bash 3.2. [8c441d2e](https://github.com/electrocucaracha/vagrant-boxes/commit/8c441d2e3e9b4eab4128338cb0720e94d36600d0)

## [2.2.0] - 2026-05-06

### Added

- Enabled consistent Markdown writing across the repository by introducing semantic line break guidelines that specify when to break lines without affecting rendered output and provide an example for contributors. [347eb48f](https://github.com/electrocucaracha/vagrant-boxes/commit/347eb48f348e2ddbc54e08c5dd659c33b19f2f3c)

## [2.1.1] - 2026-05-06

### Changed

- Stabilized documentation consistency and reviewability by applying semantic line breaks throughout the project's documentation and contributor guides, while maintaining technical content integrity and user-facing behavior. [3887433d](https://github.com/electrocucaracha/vagrant-boxes/commit/3887433ddfc31745972084ae1aab45f21b886e72)

## [2.1.0] - 2026-05-06

### Added

- Enabled repository-wide code change guidelines that require contributors to run make fmt for formatting and make lint to ensure no issues remain, emphasizing focused changes and providing a checklist for consistency and maintainability. [3094f05c](https://github.com/electrocucaracha/vagrant-boxes/commit/3094f05c86057eb1e8798bd6ac8c7fc152897c0a)

## [2.0.0] - 2026-05-06

### Removed

- Enforces default markdownlint rules for line length and unordered list indentation to ensure standard practices are followed in Markdown files. [929c6065](https://github.com/electrocucaracha/vagrant-boxes/commit/929c6065b0b772054a245d5ff77d1088d89d7100)

## [1.7.1] - 2026-05-05

### Changed

- Updated the markdownlint pre-commit hook to utilize the maintained markdownlint-cli repository and version v0.44.0 for compatibility with current rules and features. [e90eae17](https://github.com/electrocucaracha/vagrant-boxes/commit/e90eae17c7f1326606ffc0d61b08a8633994a0f6)

## [1.7.0] - 2026-05-05

### Added

- Enabled users to access comprehensive documentation for published Vagrant boxes, including tutorials, how-to guides, reference pages, and explanation sections to help select the right provider and metadata source. [cbbbda60](https://github.com/electrocucaracha/vagrant-boxes/commit/cbbbda60825d5a3b53e9b35becfbb11cddebeed2)

## [1.6.1] - 2026-05-05

### Changed

- Streamlined project documentation by clarifying contributor workflow and project overview in separate guides, CONTRIBUTING.md and readme respectively. [91319694](https://github.com/electrocucaracha/vagrant-boxes/commit/91319694cba2065a5e54a2faf67be795d0f61c01)

## [1.6.0] - 2026-05-05

### Added

- Enabled standardized code quality checks and formatting across the project through the introduction of a .pre-commit-config.yaml file that includes hooks for trailing whitespace removal, YAML validation, Bash script linting, Markdown linting, YAML formatting, and an AI-assisted prepare-commit-msg hook. [333a57ff](https://github.com/electrocucaracha/vagrant-boxes/commit/333a57ff53d49891934f348c821fd939a4fa808d)

## [1.5.0] - 2026-05-05

### Added

- Enabled improved handling of various scenarios for Ubuntu Vagrant base boxes by deriving box version from Ubuntu release and using codenames in published artifact directories and metadata names. [86ae6f8f](https://github.com/electrocucaracha/vagrant-boxes/commit/86ae6f8f029b9dc2c6478d7171885264df13a964)

## [1.4.0] - 2026-05-03

### Added

- Enabled support for Ubuntu 26.04 in the repository allowing developers to create Vagrant boxes for this distro alongside existing options for Ubuntu 22.04 and 24.04 without introducing breaking behavior or requiring migration efforts. [6296e573](https://github.com/electrocucaracha/vagrant-boxes/commit/6296e573160dfa5e28961513a10bcabc5c5d3e53)

## [1.3.5] - 2026-05-02

### Fixed

- The build process for UTM images has been stabilized to ensure reliable setup and deployment of UTM environments through cloud-init based installation, eliminating the need for ISO-based configuration. [b6249c6d](https://github.com/electrocucaracha/vagrant-boxes/commit/b6249c6d7211df9b6904b6b388a12230d1574c2a)

## [1.3.4] - 2026-04-29

### Fixed

- Resolved build reliability issues for Ubuntu 22.04 and 24.04 images by modifying the NoCloud sources used in libvirt and VirtualBox builders to match distro-specific requirements. [1a09a131](https://github.com/electrocucaracha/vagrant-boxes/commit/1a09a1314a693cfd75abbb76c4db06b4bfa369f1)

## [1.3.3] - 2026-04-29

### Fixed

- Enabled all linters for the repository's build process and linter rules resulting in improved code quality checks without introducing any breaking changes. [eeeeb147](https://github.com/electrocucaracha/vagrant-boxes/commit/eeeeb1470ec55a23e984d7ba826680ddbd8880da)

## [1.3.2] - 2026-04-29

### Fixed

- The GitHub Actions workflow for CI has been stabilized to allow linter rules to be unsynced, enabling the validation of Bash execution and Git commitlint on all codebase files by default. [edd48afc](https://github.com/electrocucaracha/vagrant-boxes/commit/edd48afc4c4b8d8c8a271d07e776ae552ffab73a)

## [1.3.1] - 2026-04-29

### Fixed

- Resolved linting issues by updating configuration files and modifying GitHub Actions workflows to enforce consistent code formatting. [02b80055](https://github.com/electrocucaracha/vagrant-boxes/commit/02b80055e11f4a9ff2d68990481b5b707955955f)

## [1.3.0] - 2026-04-27

### Added

- Enabled BDD-style shell testing for CI workflows through integration with ShellSpec. [d38b0f46](https://github.com/electrocucaracha/vagrant-boxes/commit/d38b0f46fc8627706b174925818906c2a4d1ac6a)

## [1.2.0] - 2026-04-27

### Added

- Enabled optional deployment of published artifacts into a web root by introducing two new environment variables that users can control to explicitly enable this behavior. [bb72bfef](https://github.com/electrocucaracha/vagrant-boxes/commit/bb72bfefb245b49f1588d8e855d234e54aab6a45)

## [1.1.0] - 2026-04-27

### Added

- Enabled support for building Ubuntu Vagrant base boxes on macOS using the UTM provider plugin by introducing new Packer templates and scripts specific to UTM builds that require users to select the utm provider explicitly in the PROVIDERS environment variable. [43211d24](https://github.com/electrocucaracha/vagrant-boxes/commit/43211d2486efba0b3a459939c4e49014745cbd01)

## [1.0.0] - 2026-04-26

### Added

- Enabled automated build and validation of Vagrant boxes using Packer templates through the introduction of scripts, configuration files, and GitHub Actions workflows that handle dependencies, environment variables, and output artifacts. [842928c5](https://github.com/electrocucaracha/vagrant-boxes/commit/842928c5a20bcf628426fda0977336ef78418a39)
