#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_directory}/npm-dist-tag.sh"

check_count=0

assert_tag() {
	local description="$1"
	local branch_tag="$2"
	local version="$3"
	local current_latest="$4"
	local expected="$5"
	local actual

	# shellcheck disable=SC2310 # a failing resolve is an expected outcome here, recorded as 'error'
	actual="$(resolve_dist_tag "${branch_tag}" "${version}" "${current_latest}" 2>/dev/null || printf 'error')"
	check_count=$((check_count + 1))

	if [[ ${actual} != "${expected}" ]]; then
		printf 'not ok  %s: expected %s, got %s\n' "${description}" "${expected}" "${actual}" >&2
		exit 1
	fi

	printf 'ok  %s -> %s\n' "${description}" "${actual}"
}

assert_tag 'main release' 'latest' '5.2.0' '5.1.2' 'latest'
assert_tag 'next major from main' 'latest' '6.0.0' '5.2.0' 'latest'
assert_tag 'main release older than latest fails' 'latest' '5.2.1' '5.3.0' 'error'
assert_tag 'main release equal to latest fails' 'latest' '5.2.0' '5.2.0' 'error'
assert_tag 'maintenance release before the next major' 'maintenance-5.x' '5.2.0' '5.1.2' 'latest'
assert_tag 'maintenance release after the next major' 'maintenance-5.x' '5.2.1' '6.0.0' 'maintenance-5.x'
assert_tag 'maintenance release equal to latest' 'maintenance-5.x' '5.2.0' '5.2.0' 'maintenance-5.x'
assert_tag 'versions compare numerically' 'maintenance-5.x' '5.10.0' '5.9.1' 'latest'
assert_tag 'prerelease on main' 'next' '6.0.0-beta.1' '5.2.0' 'next'
assert_tag 'prerelease on a maintenance branch' 'maintenance-5.x-next' '5.3.0-beta.1' '5.2.0' 'maintenance-5.x-next'

printf '\n%s checks, 0 failures\n' "${check_count}"
