#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_directory}/select-pr-jobs.sh"

check_count=0

assert_selection() {
	local description="$1"
	local branch="$2"
	local expected="$3"
	local changes="$4"
	local actual

	actual="$(decide_selection "${branch}" <<<"${changes}")"
	check_count=$((check_count + 1))

	if [[ ${actual} != "${expected}" ]]; then
		printf 'not ok  %s: expected %s, got %s\n' "${description}" "${expected}" "${actual}" >&2
		exit 1
	fi

	printf 'ok  %s -> %s\n' "${description}" "${actual}"
}

assert_output() {
	local description="$1"
	local selection="$2"
	local expected="$3"
	local actual

	actual="$(emit_github_output "${selection}" | tr '\n' ' ')"
	check_count=$((check_count + 1))

	if [[ ${actual} != "${expected}" ]]; then
		printf 'not ok  %s: expected %s, got %s\n' "${description}" "${expected}" "${actual}" >&2
		exit 1
	fi

	printf 'ok  %s\n' "${description}"
}

assert_selection 'root documentation only' 'feature/docs' 'docs' "$(printf 'M\tREADME.md')"
assert_selection 'repository metadata only' 'feature/catalog' 'docs' "$(printf 'M\t.cortex/catalog/react-native-sdk.yaml')"
assert_selection 'Android native only' 'feature/android' 'android' "$(printf 'M\tRokt.Widget/android/build.gradle')"
assert_selection 'iOS native only' 'feature/ios' 'ios' "$(printf 'M\tRokt.Widget/ios/RNRoktWidget.mm')"
assert_selection 'shared TypeScript only' 'feature/shared' 'shared' "$(printf 'M\tRokt.Widget/src/Rokt.tsx')"
assert_selection 'package configuration only' 'feature/package' 'shared' "$(printf 'M\tRokt.Widget/package.json')"
assert_selection 'Expo plugin only' 'feature/plugin' 'shared' "$(printf 'M\tRokt.Widget/app.plugin.js')"
assert_selection 'sample app only' 'feature/sample' 'shared' "$(printf 'M\tRoktSampleApp/App.tsx')"
assert_selection 'Expo app only' 'feature/expo' 'shared' "$(printf 'M\tExpoTestApp/App.tsx')"
assert_selection 'Android plus iOS' 'feature/native' 'shared' "$(printf 'M\tRokt.Widget/android/build.gradle\nM\tRokt.Widget/ios/RNRoktWidget.mm')"
assert_selection 'shared before workflow fails closed' 'feature/mixed' 'full' "$(printf 'M\tRokt.Widget/src/Rokt.tsx\nM\t.github/workflows/pull-request.yml')"
assert_selection 'workflow before shared fails closed' 'feature/mixed' 'full' "$(printf 'M\t.github/workflows/pull-request.yml\nM\tRokt.Widget/src/Rokt.tsx')"
assert_selection 'workflow change' 'feature/workflow' 'full' "$(printf 'M\t.github/workflows/pull-request.yml')"
assert_selection 'dependency automation change' 'feature/dependabot' 'full' "$(printf 'M\t.github/dependabot.yml')"
assert_selection 'unknown path' 'feature/unknown' 'full' "$(printf 'M\tconfig/runtime.yaml')"
assert_selection 'rename' 'feature/rename' 'full' "$(printf 'R100\tREADME.md\tdocs/README.md')"
assert_selection 'copy' 'feature/copy' 'full' "$(printf 'C100\tREADME.md\tdocs/README.md')"
assert_selection 'type change' 'feature/type' 'full' "$(printf 'T\tREADME.md')"
assert_selection 'unknown status' 'feature/status' 'full' "$(printf 'X\tREADME.md')"
assert_selection 'broken pairing' 'feature/status' 'full' "$(printf 'B\tREADME.md')"
assert_selection 'unmerged status' 'feature/status' 'full' "$(printf 'U\tREADME.md')"
assert_selection 'empty change list' 'feature/empty' 'full' ''
assert_selection 'hotfix branch' 'hotfix/urgent' 'full' "$(printf 'M\tREADME.md')"
assert_selection 'release branch' 'release/5.2.0' 'full' "$(printf 'M\tREADME.md')"

assert_output 'docs output skips package and platforms' 'docs' 'selection=docs build_package=false android=false ios=false '
assert_output 'Android output selects package and Android' 'android' 'selection=android build_package=true android=true ios=false '
assert_output 'iOS output selects package and iOS' 'ios' 'selection=ios build_package=true android=false ios=true '
assert_output 'full output selects package and both platforms' 'full' 'selection=full build_package=true android=true ios=true '
assert_output 'unknown output fails closed to full' 'unexpected' 'selection=full build_package=true android=true ios=true '

printf '\n%s checks, 0 failures\n' "${check_count}"
