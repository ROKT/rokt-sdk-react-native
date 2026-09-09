#!/usr/bin/env bash

set -euo pipefail

path_scope() {
	local path="$1"

	case "${path}" in
	README.md | CHANGELOG.md | MIGRATING.md | Rokt.Widget/README.md | RoktSampleApp/README.md | ExpoTestApp/README.md)
		printf 'docs\n'
		;;
	.cortex/* | .github/ISSUE_TEMPLATE/* | .github/pull_request_template.md)
		printf 'docs\n'
		;;
	Rokt.Widget/android/*)
		printf 'android\n'
		;;
	Rokt.Widget/ios/*)
		printf 'ios\n'
		;;
	Rokt.Widget/src/* | Rokt.Widget/plugin/* | Rokt.Widget/* | RoktSampleApp/* | ExpoTestApp/* | VERSION)
		printf 'shared\n'
		;;
	.github/workflows/* | .github/actions/* | .github/scripts/* | .github/dependabot.yml | .github/CODEOWNERS | .trunk/*)
		printf 'full\n'
		;;
	AGENTS.md | CLAUDE.md | SECURITY.md | RELEASING.md | LICENSE | .editorconfig | .gitignore)
		printf 'full\n'
		;;
	*)
		printf 'full\n'
		;;
	esac
}

decide_selection() {
	local branch="$1"
	local status path scope selection='docs'
	local has_changes=0

	if [[ ${branch} == 'main' || ${branch} == hotfix/* || ${branch} == release/* ]]; then
		printf 'full\n'
		return
	fi

	while IFS=$'\t' read -r status path _; do
		[[ -n ${status} ]] || continue
		has_changes=1

		case "${status}" in
		A | M | D) ;;
		*)
			printf 'full\n'
			return
			;;
		esac

		scope="$(path_scope "${path}")"
		case "${scope}" in
		docs) ;;
		full)
			printf 'full\n'
			return
			;;
		shared)
			selection='shared'
			;;
		android)
			if [[ ${selection} == 'ios' || ${selection} == 'shared' ]]; then
				selection='shared'
			else
				selection='android'
			fi
			;;
		ios)
			if [[ ${selection} == 'android' || ${selection} == 'shared' ]]; then
				selection='shared'
			else
				selection='ios'
			fi
			;;
		*)
			printf 'full\n'
			return
			;;
		esac
	done

	if [[ ${has_changes} -eq 0 ]]; then
		printf 'full\n'
	else
		printf '%s\n' "${selection}"
	fi
}

collect_changes() {
	local base_ref="${SELECTOR_BASE_REF:-origin/main}"

	if ! git rev-parse --verify --quiet "${base_ref}" >/dev/null; then
		printf 'Unable to resolve comparison base %s\n' "${base_ref}" >&2
		return 0
	fi

	git diff --name-status "${base_ref}...HEAD" || return 0
}

emit_github_output() {
	local selection="$1"
	local build_package=false
	local android=false
	local ios=false

	case "${selection}" in
	docs) ;;
	android)
		build_package=true
		android=true
		;;
	ios)
		build_package=true
		ios=true
		;;
	shared | full)
		build_package=true
		android=true
		ios=true
		;;
	*)
		selection='full'
		build_package=true
		android=true
		ios=true
		;;
	esac

	printf 'selection=%s\n' "${selection}"
	printf 'build_package=%s\n' "${build_package}"
	printf 'android=%s\n' "${android}"
	printf 'ios=%s\n' "${ios}"
}

main() {
	local mode="${1:-selection}"
	local branch changes selection

	branch="${SELECTOR_HEAD_BRANCH:-${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-$(git branch --show-current)}}}"
	changes="$(collect_changes)"

	if [[ ${SELECTOR_FORCE_FULL:-false} == 'true' ]]; then
		selection='full'
	else
		selection="$(decide_selection "${branch}" <<<"${changes}")"
	fi

	if [[ ${mode} == '--github-output' ]]; then
		emit_github_output "${selection}" | tee -a "${GITHUB_OUTPUT}"
	else
		printf '%s\n' "${selection}"
	fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	main "$@"
fi
