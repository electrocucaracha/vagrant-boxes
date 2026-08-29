<!-- Markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [6.0.3] - 2026-08-29

### Changed

- Clarified the project's purpose and scope by updating the readme to accurately describe the project as an automated build tool, improving documentation for readability and consistency. [c9f8ac15](https://github.com/electrocucaracha/vagrant-boxes/commit/c9f8ac15bb56857042a45d417b93116212293d2e)

## [6.0.2] - 2026-08-29

### Changed

- Upgrading the ai-prepare-commit-msg hook to version 9.0.0 ensures compatibility with the latest pre-commit framework and includes upstream bugfixes, improving commit message generation reliability and continued support. [98bffb55](https://github.com/electrocucaracha/vagrant-boxes/commit/98bffb550a6e08cccec8c903993ef986cd039105)

## [6.0.1] - 2026-08-29

### Changed

- Clarified the project's value proposition by expanding the README's overview and adding an architecture diagram to visually illustrate the workflow and relationships between components. [c5b24662](https://github.com/electrocucaracha/vagrant-boxes/commit/c5b246622faf6b7daeed6e6837f37db8a59960fe)

## [6.0.0] - 2026-08-21

### Removed

- Simplified configuration files by eliminating unnecessary leading YAML document separators, which were present in multiple files and could cause confusion for tools that do not expect explicit document delimiters, without introducing any functional changes or affecting breaking behavior or migration requirements. [181e0024](https://github.com/electrocucaracha/vagrant-boxes/commit/181e002432929a4725204f98f31c5c710915662c)

## [5.0.0] - 2026-08-21

### Removed

- Simplified the funding config by removing the .yamlfmt configuration file and YAML document start marker, which is now handled by other tools in the workflow. [8019bc5b](https://github.com/electrocucaracha/vagrant-boxes/commit/8019bc5b01a8ff3a5ac7181773555491f898c4bb)

## [4.7.0] - 2026-08-21

### Added

- Enabled project sponsorship links on the repository, allowing users to support ongoing development and maintenance through GitHub Sponsors and Buy Me a Coffee profiles. [51fc30f8](https://github.com/electrocucaracha/vagrant-boxes/commit/51fc30f8bdb135ab1a776708a581050b6fa7e888)

## [4.6.3] - 2026-08-21

### Changed

- Upgraded the pre-commit configuration to use the latest version of ai-prepare-commit-msg, specifically v7.1.0, ensuring compatibility with recent pre-commit versions and potentially improving commit message suggestions. [e924498f](https://github.com/electrocucaracha/vagrant-boxes/commit/e924498fdc3459c006a39fa0d49d74d8c59db17e)

## [4.6.2] - 2026-08-21

### Fixed

- The Makefile now checks for the presence of textlint and prettier before use, ensuring consistent formatting regardless of setup, and installs these tools locally if missing to prevent failures in clean environments and reduce setup friction for developers. [587cf994](https://github.com/electrocucaracha/vagrant-boxes/commit/587cf994a04bb91b030c6ce5eade6aa3753f7cde)

## [4.6.1] - 2026-08-13

### Changed

- Clarified and standardized changelog entries to enhance readability and usability for users and contributors by providing clear context and consistent terminology. [5d652992](https://github.com/electrocucaracha/vagrant-boxes/commit/5d652992f687abb5c252ecadd488cb61d9ca649c)

## [4.6.0] - 2026-08-07

### Added

- Enabled automated code duplication detection by introducing a .jscpd.json configuration file that enforces zero allowed duplicates and excludes commonly ignored files and directories from scanning to reduce noise and false positives. [7d9825ea](https://github.com/electrocucaracha/vagrant-boxes/commit/7d9825ead875548eaecad050c2c533ac3cb85e1a)

## [4.5.0] - 2026-08-07

### Added

- Enabled automatic text style consistency checks, terminology enforcement, and improved linting coverage for versions 4.2.0 through 4.4.0, enhancing documentation quality and ensuring consistent results across environments. [ce9f6086](https://github.com/electrocucaracha/vagrant-boxes/commit/ce9f6086d8c2626f2d2a968187ad0a8fb66a7387)

## [4.4.0] - 2026-08-07

### Added

- Enabled automatic text style consistency checks for documentation and prose files through the fmt target in the Makefile, reducing manual review effort and maintaining consistent writing standards across the project without introducing any breaking behavior or migration requirements. [c532d710](https://github.com/electrocucaracha/vagrant-boxes/commit/c532d710fb68e59b4fe48f56dc7d766388e9293d)

## [4.3.1] - 2026-08-07

### Changed

- Stabilized linting and formatting results across environments by removing node_modules and Python environments before running these checks. [be199d59](https://github.com/electrocucaracha/vagrant-boxes/commit/be199d590e6d74805612e7c733dbf669ad3b51e7)

## [4.3.0] - 2026-08-07

### Added

- Enabled consistent terminology usage across documentation and prose files by enforcing specific terms uniformly throughout the project's content without introducing any breaking behavior, API changes, or security impact. [09a232f7](https://github.com/electrocucaracha/vagrant-boxes/commit/09a232f7ab7e2df57153d572edef55f7d3eff0d5)

## [4.2.2] - 2026-08-07

### Fixed

- The linter now resolves issues in all files, including those not tracked by Git but still in the codebase or included in deployments, improving code quality and consistency. [8678c963](https://github.com/electrocucaracha/vagrant-boxes/commit/8678c9633e3d233c37f1d6947c6924671580122b)

## [4.2.1] - 2026-08-07

### Changed

- Standardized terminology and capitalization across multiple changelog entries to improve clarity and maintain a uniform style throughout the documentation. [5ca286a0](https://github.com/electrocucaracha/vagrant-boxes/commit/5ca286a00eeb4f299cecf4bbe08fda11d029fa18)

## [4.2.0] - 2026-08-07

### Added

- Introduced a comprehensive CHANGELOG.md file that details all project changes and provides clear traceability for releases, improving project transparency and making it easier to navigate the development path. [61ba3e7e](https://github.com/electrocucaracha/vagrant-boxes/commit/61ba3e7e68aa8907d23ce69480f8f6117093f2ea)

## [4.1.0] - 2026-08-07

### Added

- Enabled support for self-contained documentation by permitting multiple H1 headings and longer lines in Markdown files, aligning with the project's documentation style requirements. [7b28120c](https://github.com/electrocucaracha/vagrant-boxes/commit/7b28120cfa66d1c43e9b983d79eb64c9f44b086e)

## [4.0.0] - 2026-08-07

### Removed

- Simplified project setup by eliminating an unused configuration file that was no longer needed due to the absence of code duplication checks in the current workflow. [e4347414](https://github.com/electrocucaracha/vagrant-boxes/commit/e43474148c3725513064303c61f4300f397437b1)

## [3.1.10] - 2026-08-07

### Changed

- Stabilized GitHub Actions in CI, linter, and update workflows to their latest stable versions for improved security, bugfixes, and compatibility, with no changes to workflow logic. [6d42ecb0](https://github.com/electrocucaracha/vagrant-boxes/commit/6d42ecb0cf8b0f096214dabe044d1f1acf183a25)

## [3.1.9] - 2026-08-07

### Changed

- Unified GitHub Actions commit hash resolution logic to simplify version matching and improve action name extraction, with no impact on update semantics. [1c67f7ce](https://github.com/electrocucaracha/vagrant-boxes/commit/1c67f7ce71bcb8c46f5a778511808ed3281f6b4a)

## [3.1.8] - 2026-08-07

### Changed

- Upgraded to latest markdownlint-cli and ai-prepare-commit hook versions to ensure compatibility with recent pre-commit framework changes and improve code quality through enhanced linter rules and automated commit message generation. [f34df60e](https://github.com/electrocucaracha/vagrant-boxes/commit/f34df60e68c66e06ac3e925d609fc3e93ea2e7f9)

## [3.1.7] - 2026-06-05

### Changed

- Updated the pre-commit hook for ai-prepare-commit-msg to ensure compatibility with the latest features and bugfixes without introducing any functional modifications. [08a1cc02](https://github.com/electrocucaracha/vagrant-boxes/commit/08a1cc02f8a40b27c0b17b5395eb31b66d75400f)

## [3.1.6] - 2026-06-05

### Fixed

- Resolved linting issues by reverting to markdownlint v0.47.0 in the pre-commit configuration due to stricter rules introduced in newer versions breaking existing documentation formatting. [d0dd9340](https://github.com/electrocucaracha/vagrant-boxes/commit/d0dd9340d076182378dbfdd472613213fbdf2886)

## [3.1.5] - 2026-06-05

### Changed

- Updated GitHub Actions versions to their latest versions across multiple workflow files, ensuring the use of recent features and fixes provided by action maintainers, while also modifying exceptions in ci/update_versions.sh to prevent auto-updating specific actions. [e038fe4c](https://github.com/electrocucaracha/vagrant-boxes/commit/e038fe4c2c0c815a69f61bb13f4901db0d02354d)

## [3.1.4] - 2026-06-05

### Fixed

- Stabilized compatibility across development environments by updating the pre-commit hook for ai-prepare-commit-msg to point to the latest revision. [65bfc5e9](https://github.com/electrocucaracha/vagrant-boxes/commit/65bfc5e93fdc2adf507be225b1fa6772d8188078)

## [3.1.3] - 2026-06-05

### Fixed

- BREAKING: Stabilized pre-commit hooks to ensure consistent code quality checks across the repository by updating markdownlint and ai-prepare-commit-msg to their latest versions, potentially introducing new linter rules that may require adjustments to existing Markdown files or commit message formats. [2c5ad4a3](https://github.com/electrocucaracha/vagrant-boxes/commit/2c5ad4a3f379f3af4e19f989a3ce4d454caa731b)

## [3.1.2] - 2026-06-05

### Changed

- Enabled improved documentation structure and styling through a switch to just-the-docs remote theme, and streamlined code copying by adding a single-click copy code button feature with no breaking changes affecting core application behavior or API. [234ff1c0](https://github.com/electrocucaracha/vagrant-boxes/commit/234ff1c00eac3ceab45d71ff98e2c093ff6a129c)

## [3.1.1] - 2026-05-22

### Fixed

- Resolved an issue where pre-commit environment installation failed due to incompatible dependencies by downgrading markdownlint-cli to v0.47.0 and updating ai-prepare-commit-msg to its latest commit. [a145ac48](https://github.com/electrocucaracha/vagrant-boxes/commit/a145ac4851d69e309f556032ae3984d2b150e843)

## [3.1.0] - 2026-05-18

### Added

- Introduced a systemd oneshot service that generates SSH host keys only if missing before the SSH daemon starts, improving reliability and reducing the risk of failed SSH startups due to missing host keys. [13b98269](https://github.com/electrocucaracha/vagrant-boxes/commit/13b98269717954e6db20bca9f2515863e54e59a5)

## [3.0.6] - 2026-05-17

### Changed

- Updated the AI Linter Analysis step to utilize version 2.1.0 of the actions/ai-inference action, potentially incorporating upstream bugfixes and performance enhancements, without introducing breaking behavior or requiring migration. [2d779e65](https://github.com/electrocucaracha/vagrant-boxes/commit/2d779e658d3eed4453392c2c9d7afba339b80285)

## [3.0.5] - 2026-05-17

### Changed

- Optimized build efficiency by enabling Packer cache to restore and save relevant files for faster subsequent builds and reduced network usage, also updating the ai-inference action to version 2.1.0 for access to the latest features and fixes. [d29aa883](https://github.com/electrocucaracha/vagrant-boxes/commit/d29aa8839bf352091a7730e2de90bdac5542a632)

## [3.0.4] - 2026-05-17

### Changed

- Updated the ai-prepare-commit-msg pre-commit hook to its latest version, ensuring the commit message preparation workflow incorporates recent improvements and bugfixes. [a033b062](https://github.com/electrocucaracha/vagrant-boxes/commit/a033b0623de20ac0d2ef3c4d7d7f871a034d0900)

## [3.0.3] - 2026-05-17

### Changed

- Stabilized SSH host key regeneration on supported Ubuntu images by introducing retry logic to mitigate transient errors during dpkg-reconfigure and systemctl restart operations. [04bfb1ba](https://github.com/electrocucaracha/vagrant-boxes/commit/04bfb1ba4dd9f5d4de19243b2eccb244ca43c6cb)

## [3.0.2] - 2026-05-17

### Changed

- Enabled real-time visibility of build progress in CI logs by piping output through tee, allowing immediate feedback on build status without modifying the existing build command. [a9af054b](https://github.com/electrocucaracha/vagrant-boxes/commit/a9af054b3f810ff5929cbeb2e3174eeba68de8e2)

## [3.0.1] - 2026-05-17

### Changed

- Hardened linter configuration to prevent false positives and enriched AI log evidence collection for improved error resolution. [56203e2b](https://github.com/electrocucaracha/vagrant-boxes/commit/56203e2b659c6d82ea6b11bb694df8c50c114701)

## [3.0.0] - 2026-05-17

### Removed

- Simplified the log cleanup script for various Ubuntu versions by removing redundant truncate commands thereby improving efficiency in log cleanup operations without introducing any breaking behavior API changes security impact or config schema changes. [22ff94e4](https://github.com/electrocucaracha/vagrant-boxes/commit/22ff94e40c92be63177405f40dc0d3b3f26cfe2a)

## [2.11.7] - 2026-05-17

### Changed

- Renamed the "AI Linter Analysis" step to "AI Build Output Analysis" in the CI workflow for clarity and accuracy, improving maintainability by accurately reflecting its purpose of analyzing build output on failure without introducing breaking behavior. [3624e611](https://github.com/electrocucaracha/vagrant-boxes/commit/3624e6119a30cf12e6b58c07dc839c0d72706e16)

## [2.11.6] - 2026-05-17

### Changed

- Automated evidence collection and root cause analysis now streamline build failure triage for maintainers by providing actionable insights and proposed fixes directly in a new GitHub issue. [70d7564f](https://github.com/electrocucaracha/vagrant-boxes/commit/70d7564f5b1d20465bbbe61ff78decca53be6202)

## [2.11.5] - 2026-05-16

### Changed

- Optimized functional tests to run only for relevant Ubuntu distros based on modified files in a PR reducing unnecessary CI runs and speeding up feedback while improving resource efficiency. [1cf98470](https://github.com/electrocucaracha/vagrant-boxes/commit/1cf98470115171995def931f1ee00dfd2dd39ebd)

## [2.11.4] - 2026-05-16

### Changed

- Updated the README.md to include a link to the Ubuntu 26.04 Vagrant box, ensuring consistency with other supported Ubuntu releases and making it easier for users to access the correct resource. [1899df86](https://github.com/electrocucaracha/vagrant-boxes/commit/1899df863924cefa6d406ab3542804192eba3f0d)

## [2.11.3] - 2026-05-16

### Fixed

- Stabilized SSH key regeneration to correctly configure keys on Ubuntu 26.04 images by updating the regular expression to include 2604 and ensure future compatibility across supported Ubuntu versions. [da94924c](https://github.com/electrocucaracha/vagrant-boxes/commit/da94924c512da39753571fa75399e7814cc46a29)

## [2.11.2] - 2026-05-15

### Fixed

- Resolved suppressing secret-outside-env warnings for the GITHUB_MCP_TOKEN environment variable in GitHub workflow linter jobs without affecting API or CLI contracts and with no security implications. [26cc73a2](https://github.com/electrocucaracha/vagrant-boxes/commit/26cc73a29ddc52265cc0b21bee66e42f67c7d055)

## [2.11.1] - 2026-05-15

### Changed

- Optimized GitHub workflow linter output to reduce captured data and improve readability by capping changed files at 80, log files at 40, error excerpt lines at 250, and commit diff bytes at 4000, with a unified diff format used for brevity. [745f6d23](https://github.com/electrocucaracha/vagrant-boxes/commit/745f6d23aaf47b8e81dbb37d153156b4afb61392)

## [2.11.0] - 2026-05-15

### Added

- Enhanced AI-driven linter failure analysis by providing more relevant context and guiding the model toward better root cause identification and remediation suggestions through improved diagnostics and concrete fixes with confidence levels. [4a250319](https://github.com/electrocucaracha/vagrant-boxes/commit/4a2503197e2a4f5eff9234e55ffa25a36527eef1)

## [2.10.2] - 2026-05-14

### Changed

- Optimized artifact logging in GitHub Actions linter workflow to provide a more consistent and accessible reference for developers by updating the log URL to point directly to the workflow run page, and improved error resilience when extracting super-linter version with jq by providing a fallback to set the version as "unknown" if extraction fails. [75337708](https://github.com/electrocucaracha/vagrant-boxes/commit/753377082b94754a99e1a6e167856077ae501181)

## [2.10.1] - 2026-05-14

### Changed

- Enabled linter metadata such as log URL, super-linter version, and commit ID to be accessed reliably by downstream steps via outputs in GitHub Actions workflows. [bdd6faa0](https://github.com/electrocucaracha/vagrant-boxes/commit/bdd6faa0122ec83b9d9337b53d72ac1f086beac2)

## [2.10.0] - 2026-05-14

### Added

- Optimized CI performance by enabling functional tests to run only on code changes. [df4256b0](https://github.com/electrocucaracha/vagrant-boxes/commit/df4256b05aa1a148ea545dab765948b5a34b0d15)

## [2.9.2] - 2026-05-14

### Changed

- Reformatted the workflows list as a Markdown table for improved readability and consistency without modifying workflow behavior or content. [8615d665](https://github.com/electrocucaracha/vagrant-boxes/commit/8615d6655f5f10def1cd263201435335e6b1d050)

## [2.9.1] - 2026-05-14

### Fixed

- Stabilized log URL generation by using upload-artifact output for linter logs, making it more robust against potential changes in GitHub artifact URL formats and requiring no breaking changes or migration efforts. [26e9f991](https://github.com/electrocucaracha/vagrant-boxes/commit/26e9f99112423711498ba27f7ef8d1dfa3b606f3)

## [2.9.0] - 2026-05-14

### Added

- Enabled support for custom self-hosted runner labels in CI workflows by introducing the 'vm-self-hosted' label without requiring any migration steps or breaking changes. [34942c7c](https://github.com/electrocucaracha/vagrant-boxes/commit/34942c7c0186351c6c6c980b1839ec6a2ee012c4)

## [2.8.1] - 2026-05-13

### Changed

- Improved discoverability for users accessing Ubuntu 22.04 and 24.04 boxes by enabling direct links to the relevant Vagrant Cloud pages in the readme file without introducing any breaking behavior or migration requirements. [c42cb73c](https://github.com/electrocucaracha/vagrant-boxes/commit/c42cb73cf1a9a67739a589dd1056b1ceaf7dc99a)

## [2.8.0] - 2026-05-13

### Added

- Documented GitHub Actions workflows to improve contributor understanding of automation scripts and issue tracking. [a708a00f](https://github.com/electrocucaracha/vagrant-boxes/commit/a708a00f460a8296d13f8478593c6d468f34f66f)

## [2.7.0] - 2026-05-13

### Added

- Enabled functional testing for self-hosted runners across multiple Ubuntu distributions by introducing a new job to the CI workflow that installs build prerequisites and runs the build script with debugging enabled. [41ffe803](https://github.com/electrocucaracha/vagrant-boxes/commit/41ffe8032221b30e2e4d8a52ee74e60c0c2f7b63)

## [2.6.0] - 2026-05-13

### Added

- Enabled adherence to the Google Shell Style Guide for new and revised shell code in the repository, requiring migration to this style guide for all contributors working on shell scripts. [df0a90cf](https://github.com/electrocucaracha/vagrant-boxes/commit/df0a90cfdb5b1f95094f78b09370f8eff682f570)

## [2.5.4] - 2026-05-09

### Fixed

- Resolved the Yamllint line-length error in linter.yml by enabling long lines to be wrapped and providing a prompt for AI model input without impacting the API or CLI contract. [fe05b5fd](https://github.com/electrocucaracha/vagrant-boxes/commit/fe05b5fd2e3f8296da1e537efd2ed7506ae59569)

## [2.5.3] - 2026-05-08

### Changed

- Refined documentation for consuming published Vagrant boxes to improve clarity, structure, and consistency, making it more accessible to new users and reducing ambiguity through a consistent style. [826f72ef](https://github.com/electrocucaracha/vagrant-boxes/commit/826f72efa708d910de78c9070b01af072193932a)

## [2.5.2] - 2026-05-08

### Changed

- Optimized the Continuous Integration workflow to detect documentation changes by running Markdown link checks only on modified documentation files and introduced a new "docs" filter for this purpose. [d9638324](https://github.com/electrocucaracha/vagrant-boxes/commit/d9638324ef72034e85482761ec915de432533a9e)

## [2.5.1] - 2026-05-06

### Fixed

- Resolved incompatibilities between zizmor and `ava@7.0.0` by adding a zizmor ignore annotation for secrets usage outside of environment variables and downgrading markdownlint-cli to v0.44.0, ensuring compatibility with the CI's Node.js engine version. [2278a5b7](https://github.com/electrocucaracha/vagrant-boxes/commit/2278a5b776def1e18a7540fb850acd4ea47f56cc)

## [2.5.0] - 2026-05-06

### Added

- Automated version updates are now enabled for dependencies and GitHub Actions, reducing manual maintenance and improving security and reliability by keeping dependencies current. [c7499cf3](https://github.com/electrocucaracha/vagrant-boxes/commit/c7499cf3ff059fe6b51da8cb85d870a9236d2856)

## [2.4.2] - 2026-05-06

### Changed

- Upgraded markdownlint-cli to v0.48.0 to leverage the latest bugfixes and rule updates for enhanced Markdown linting accuracy and adherence to current best practices. [5ef0b6b6](https://github.com/electrocucaracha/vagrant-boxes/commit/5ef0b6b6ffe7c92200376b2b2e4424fe97ccfa54)

## [2.4.1] - 2026-05-06

### Changed

- Standardized YAML linting and formatting configuration was enabled to ensure consistent style across the repository. [e66a5034](https://github.com/electrocucaracha/vagrant-boxes/commit/e66a50347ad86d049b3ed7b86251be78e2cd14b2)

## [2.4.0] - 2026-05-06

### Added

- Enabled a clean and modern documentation site look by introducing Jekyll configuration with the Cayman theme and including Apache-2.0 compliant license and copyright headers. [7529e84a](https://github.com/electrocucaracha/vagrant-boxes/commit/7529e84a72baabc6a4659ca4d5879ca072e55096)

## [2.3.1] - 2026-05-06

### Changed

- Optimized pre-commit checks to tolerate stylistic differences automatically applied by shfmt, allowing for more seamless integration of formatting changes without unnecessary manual intervention. [4d590ba6](https://github.com/electrocucaracha/vagrant-boxes/commit/4d590ba621558239aa7af8ce01a10d6ee47cb3d0)

## [2.3.0] - 2026-05-06

### Added

- Enabled standardized Bash-driven development in the repository by introducing a new Markdown document outlining required workflows and conventions for maintaining compatibility with Bash 3.2 and ensuring ShellSpec coverage passes. [8c441d2e](https://github.com/electrocucaracha/vagrant-boxes/commit/8c441d2e3e9b4eab4128338cb0720e94d36600d0)

## [2.2.0] - 2026-05-06

### Added

- Introduced documentation guidelines for Markdown writing that standardize semantic line break rules and improve consistency and readability of Markdown source across the repository. [347eb48f](https://github.com/electrocucaracha/vagrant-boxes/commit/347eb48f348e2ddbc54e08c5dd659c33b19f2f3c)

## [2.1.1] - 2026-05-06

### Changed

- Stabilized documentation formatting by applying semantic line breaks and adjusting markdownlint compliance to ensure consistent readability and maintainability without altering technical content or user-facing behavior. [3887433d](https://github.com/electrocucaracha/vagrant-boxes/commit/3887433ddfc31745972084ae1aab45f21b886e72)

## [2.1.0] - 2026-05-06

### Added

- Stabilized code quality and maintainability by introducing repository-wide guidelines that standardize formatting and linting checks for contributors. [3094f05c](https://github.com/electrocucaracha/vagrant-boxes/commit/3094f05c86057eb1e8798bd6ac8c7fc152897c0a)

## [2.0.0] - 2026-05-06

### Removed

- Enforces stricter markdownlint rules for line length and unordered list indentation by disabling custom arguments in the pre-commit hook configuration. [929c6065](https://github.com/electrocucaracha/vagrant-boxes/commit/929c6065b0b772054a245d5ff77d1088d89d7100)

## [1.7.1] - 2026-05-05

### Changed

- Upgraded markdownlint pre-commit hook to leverage maintained markdownlint-cli repository and version v0.44.0 for seamless compatibility with current rules and features. [e90eae17](https://github.com/electrocucaracha/vagrant-boxes/commit/e90eae17c7f1326606ffc0d61b08a8633994a0f6)

## [1.7.0] - 2026-05-05

### Added

- Enabled users to navigate and consume published Vagrant boxes more effectively by introducing a comprehensive documentation site featuring tutorials, how-to guides, reference pages, and an explanation of the project's support matrix. [cbbbda60](https://github.com/electrocucaracha/vagrant-boxes/commit/cbbbda60825d5a3b53e9b35becfbb11cddebeed2)

## [1.6.1] - 2026-05-05

### Changed

- Streamlined documentation by clarifying contributor workflow and project overview in separate guides. [91319694](https://github.com/electrocucaracha/vagrant-boxes/commit/91319694cba2065a5e54a2faf67be795d0f61c01)

## [1.6.0] - 2026-05-05

### Added

- Enabled standardized code quality checks and formatting across the project through a pre-commit configuration that includes hooks for trailing whitespace removal, YAML validation, Bash script linting, Markdown linting, and YAML formatting, while selectively ignoring some linter rules to balance strictness with developer convenience. [333a57ff](https://github.com/electrocucaracha/vagrant-boxes/commit/333a57ff53d49891934f348c821fd939a4fa808d)

## [1.5.0] - 2026-05-05

### Added

- Enabled automatic cleanup of running VMs and improved metadata handling in the build script by incorporating distro slugs into box URLs and filenames. [86ae6f8f](https://github.com/electrocucaracha/vagrant-boxes/commit/86ae6f8f029b9dc2c6478d7171885264df13a964)

## [1.4.0] - 2026-05-03

### Added

- Enabled support for Ubuntu 26.04, allowing users to build and deploy boxes using the provided scripts and tools alongside existing supported distros. [6296e573](https://github.com/electrocucaracha/vagrant-boxes/commit/6296e573160dfa5e28961513a10bcabc5c5d3e53)

## [1.3.5] - 2026-05-02

### Fixed

- Resolved issues with Bash instructions and UTM configurations to ensure accurate and consistent behavior across all affected builders. [b6249c6d](https://github.com/electrocucaracha/vagrant-boxes/commit/b6249c6d7211df9b6904b6b388a12230d1574c2a)

## [1.3.4] - 2026-04-29

### Fixed

- Resolved issues related to libvirt and VirtualBox builders by updating autoinstall sources to use distro-specific NoCloud sources for booting into the installed system, and maintaining existing behavior for UTM builds that power off after autoinstall. [1a09a131](https://github.com/electrocucaracha/vagrant-boxes/commit/1a09a1314a693cfd75abbb76c4db06b4bfa369f1)

## [1.3.3] - 2026-04-29

### Fixed

- Linter configuration has been resolved for the project, enabling all codebases to adhere to conventional standards and detect duplicate code. [eeeeb147](https://github.com/electrocucaracha/vagrant-boxes/commit/eeeeb1470ec55a23e984d7ba826680ddbd8880da)

## [1.3.2] - 2026-04-29

### Fixed

- The GitHub Actions workflow for CI was updated to unsync from the original configuration, introducing new settings that override default behavior and impacting validation rules for codebase integrity and execution of specific tools like Git Diff Action. [edd48afc](https://github.com/electrocucaracha/vagrant-boxes/commit/edd48afc4c4b8d8c8a271d07e776ae552ffab73a)

## [1.3.1] - 2026-04-29

### Fixed

- Stabilized linting configuration to ensure consistent editor settings and improve compatibility across various environments and tools. [02b80055](https://github.com/electrocucaracha/vagrant-boxes/commit/02b80055e11f4a9ff2d68990481b5b707955955f)

## [1.3.0] - 2026-04-27

### Added

- Enabled BDD-style shell testing via ShellSpec for users running `make test`, introducing a new CI job and requiring migration steps to update existing tests in the new format. [d38b0f46](https://github.com/electrocucaracha/vagrant-boxes/commit/d38b0f46fc8627706b174925818906c2a4d1ac6a)

## [1.2.0] - 2026-04-27

### Added

- Enabled optional deployment of published artifacts into a web root by introducing two new environment variables: `DEPLOY_WWW` and `WWW_ROOT`, allowing users to control this behavior through configuration. [bb72bfef](https://github.com/electrocucaracha/vagrant-boxes/commit/bb72bfefb245b49f1588d8e855d234e54aab6a45)

## [1.1.0] - 2026-04-27

### Added

- Enabled support for building Ubuntu Vagrant base boxes on macOS targeting arm64 architecture via the UTM provider. [43211d24](https://github.com/electrocucaracha/vagrant-boxes/commit/43211d2486efba0b3a459939c4e49014745cbd01)

## [1.0.0] - 2026-04-26

### Added

- Enabled support for building Ubuntu Vagrant base boxes through Packer templates and provisioning scripts that produce versioned box artifacts, checksums, and metadata files. [842928c5](https://github.com/electrocucaracha/vagrant-boxes/commit/842928c5a20bcf628426fda0977336ef78418a39)
