#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2026
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o errexit
set -o pipefail
if [[ ${DEBUG:-false} == "true" ]]; then
	set -o xtrace
fi

trap "make fmt" EXIT

if ! command -v uvx >/dev/null; then
	curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uvx pre-commit autoupdate

# Update GitHub Action commit hashes
gh_actions=$(grep -r "uses: [A-Za-z0-9_.-]*/[\_a-z\-]*@" .github/ | sed 's/@.*//' | awk -F ': ' '{ print $3 }' | sort -u)
exceptions=('reviewdog/action-misspell' 'actions/attest-build-provenance' 'GrantBirki/git-diff-action')
# Actions pinned to a specific version and excluded from auto-updates.
# Remove an entry only once the underlying issue is confirmed resolved.
# austenstone/copilot-cli: v3.0+ depends on actions/setup-copilot@v0 which does
# not yet exist publicly; keep at v2.0 until that action is released.
# super-linter/super-linter: v8.6.0 bundles ava@7.0.0, which currently fails
# under the container's Node.js/npm engine constraints; keep at v8.5.0 until a
# fixed upstream release is available.
readonly pinned_actions=('austenstone/copilot-cli' 'super-linter/super-linter')
for action in $gh_actions; do
	is_pinned=false
	for pinned in "${pinned_actions[@]}"; do
		if [[ $action == "$pinned" ]]; then
			is_pinned=true
			break
		fi
	done
	if [[ $is_pinned == "true" ]]; then
		echo "Skipping auto-update for pinned action: $action"
		continue
	fi
	if [[ ${exceptions[*]} =~ (^|[^[:alpha:]])$action([^[:alpha:]]|$) ]]; then
		commit_hash=$(git ls-remote "https://github.com/$action" | grep 'refs/tags/[v]\?[0-9][0-9\.]*\^{}$' | sed 's|refs/tags/[vV]\?[\.]\?||g; s|\^{}$||g' | sort -u -k2 -V | tail -1 | awk '{ printf "%s # %s\n",$1,$2 }')
	else
		commit_hash=$(git ls-remote "https://github.com/$action" | grep 'refs/tags/[v]\?[0-9][0-9\.]*$' | sed 's|refs/tags/[vV]\?[\.]\?||g' | sort -u -k2 -V | tail -1 | awk '{ printf "%s # %s\n",$1,$2 }')
	fi
	# shellcheck disable=SC2267
	grep -ElRZ "uses: $action@" .github/ | xargs -0 -l sed -i -e "s|uses: $action@.*|uses: $action@$commit_hash|g"
done
