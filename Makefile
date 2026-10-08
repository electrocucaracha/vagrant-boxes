# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2026
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

DOCKER_CMD ?= $(shell which docker 2> /dev/null || which podman 2> /dev/null || echo docker)
SUDO_CMD ?=

test:
	@command -v shellspec > /dev/null || curl -fsSL https://git.io/shellspec | sh -s -- --yes
	@PATH="$(HOME)/.local/bin:$$PATH" shellspec

.PHONY: test coverage
KCOV_IMAGE ?= kcov/kcov:latest-alpine
SHELLSPEC_VERSION ?= 0.28.1
SHELLSPEC_DIR := test/lib/shellspec

$(SHELLSPEC_DIR)/bin/shellspec:
	@echo "→ Cloning ShellSpec $(SHELLSPEC_VERSION)..."
	@git clone --quiet --depth 1 --branch $(SHELLSPEC_VERSION) \
		https://github.com/shellspec/shellspec.git $(SHELLSPEC_DIR)

coverage: $(SHELLSPEC_DIR)/bin/shellspec
	@command -v "$(DOCKER_CMD)" > /dev/null 2>&1 || { echo "Container runtime '$(DOCKER_CMD)' is required for coverage." >&2; exit 1; }
	@echo "→ Running ShellSpec with line coverage..."
	@$(DOCKER_CMD) run --rm \
	  -v "$(CURDIR):/workspace" \
	  -w /workspace \
	  "$(KCOV_IMAGE)" \
	  /bin/sh -ec 'apk add --no-cache coreutils gawk jq python3 >/dev/null; ln -sf /usr/bin/python3 /usr/local/bin/python; SUDO_CMD=true test/lib/shellspec/bin/shellspec --no-warning-as-failure --kcov --kcov-options "--exclude-pattern=/.shellspec,/spec/,/coverage/,/report/,/test/lib/" --kcov-path spec/kcov-shellspec.sh'

.PHONY: cleanup
cleanup:
	rm -rf node_modules
	rm -rf .tox/ .venv/

.PHONY: lint
lint: cleanup
	$(SUDO_CMD) $(DOCKER_CMD) run --rm -v $$(pwd):/tmp/lint --platform linux/amd64 \
	-e RUN_LOCAL=true \
	-e FILTER_REGEX_EXCLUDE='test/lib/.*|coverage/.*' \
	-e USE_FIND_ALGORITHM=true \
	-e VALIDATE_ALL_CODEBASE=true \
	-e LINTER_RULES_PATH=/ \
	ghcr.io/super-linter/super-linter

.PHONY: fmt
fmt: cleanup
	command -v shfmt > /dev/null || curl -s "https://i.jpillora.com/mvdan/sh!!?as=shfmt" | bash
	shfmt -l -w -s -i 4 .
	command -v shfmt > /dev/null || curl -fsSL "https://i.jpillora.com/mvdan/sh!!?as=shfmt" | bash
	find . \( -path './spec' -o -path './spec/*' -o -path './test/lib' -o -path './test/lib/*' \) -prune -o -type f \( -name '*.sh' -o -name '.credentialsrc' \) -print0 | xargs -0r shfmt -l -w -s
	npx --yes textlint . --ignore-path .textlintignore --fix
	npx --yes prettier . --write --ignore-unknown
	command -v yamlfmt > /dev/null || curl -fsSL "https://i.jpillora.com/google/yamlfmt!!" | bash
	find . -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0r yamlfmt
