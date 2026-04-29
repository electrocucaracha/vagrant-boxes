# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2026
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

DOCKER_CMD ?= $(shell which docker 2> /dev/null || which podman 2> /dev/null || echo docker)

test:
	@command -v shellspec > /dev/null || curl -fsSL https://git.io/shellspec | sh -s -- --yes
	@PATH="$(HOME)/.local/bin:$$PATH" shellspec

.PHONY: lint
lint:
	sudo -E $(DOCKER_CMD) run --rm -v $$(pwd):/tmp/lint \
	-e RUN_LOCAL=true \
	-e USE_FIND_ALGORITHM=true \
	-e VALIDATE_ALL_CODEBASE=true \
	-e VALIDATE_BASH_EXEC=false \
	-e VALIDATE_BIOME_FORMAT=false \
	-e VALIDATE_GIT_COMMITLINT=false \
	-e VALIDATE_JSCPD=false \
	-e LINTER_RULES_PATH=/ \
	ghcr.io/super-linter/super-linter

.PHONY: fmt
fmt:
	command -v shfmt > /dev/null || curl -s "https://i.jpillora.com/mvdan/sh!!?as=shfmt" | bash
	find . \( -path './spec' -o -path './spec/*' \) -prune -o -type f \( -name '*.sh' -o -name '.credentialsrc' \) -print0 | xargs -0r shfmt -l -w -s
	command -v yamlfmt > /dev/null || curl -s "https://i.jpillora.com/google/yamlfmt!!" | bash
	find . -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0r yamlfmt
	npx --yes prettier . --write --ignore-unknown
