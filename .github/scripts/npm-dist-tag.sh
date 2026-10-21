#!/usr/bin/env bash

set -euo pipefail

# Prints the dist-tag to publish a release under. branch_tag is the tag the release branch implies:
# latest on main, maintenance-<major>.x on a maintenance branch, or either with -next for a
# prerelease. A stable release takes latest only when it is newer than npm's current latest, so a
# maintenance release becomes latest until the next major ships, and latest never moves backwards.
resolve_dist_tag() {
	local branch_tag="$1"
	local version="$2"
	local current_latest="$3"
	local newest

	case "${branch_tag}" in
	*-next | next)
		printf '%s\n' "${branch_tag}"
		return
		;;
	*) ;;
	esac

	newest="$(printf '%s\n%s\n' "${current_latest}" "${version}" | sort -V | tail -n 1)"
	if [[ ${version} != "${current_latest}" && ${newest} == "${version}" ]]; then
		printf 'latest\n'
	elif [[ ${branch_tag} == 'latest' ]]; then
		printf 'Error: %s is not newer than the latest release on npm (%s)\n' "${version}" "${current_latest}" >&2
		return 1
	else
		printf '%s\n' "${branch_tag}"
	fi
}

main() {
	local current_latest npm_tag
	: "${NPM_TAG:?}" "${FINAL_VERSION:?}" "${GITHUB_OUTPUT:?}"

	current_latest="$(npm view @rokt/react-native-sdk dist-tags.latest)"
	npm_tag="$(resolve_dist_tag "${NPM_TAG}" "${FINAL_VERSION}" "${current_latest}")"
	printf 'Publishing %s under %s (latest on npm: %s)\n' "${FINAL_VERSION}" "${npm_tag}" "${current_latest}"
	printf 'npm-tag=%s\n' "${npm_tag}" >>"${GITHUB_OUTPUT}"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	main "$@"
fi
