#!/bin/bash

# Search all our repositories and their history for a string.

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR" ]]; then SCRIPTDIR="$PWD"; fi
. "$SCRIPTDIR/formatting.sh"

usage() {
        echo "${COLOR_BOLD}Search all downloaded repositories, and history, for a string. Takes regex.${COLOR_RESET}"
        echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "<string>${COLOR_RESET}"
        echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" sudofox${COLOR_RESET}"
        exit;
}

[ -z "$1" ] && usage

REPOLIST=$(find "$SCRIPTDIR/repositories/" -maxdepth 2 -mindepth 2)

for repo in $REPOLIST; do
	reponame=$(echo -n $repo|awk -F/ '{print $3"/"$4}')
	echo "${COLOR_BOLD}Searching repository $reponame${COLOR_RESET}..."
	pushd $repo
	git --no-pager grep ''"$1"'' $(git rev-list --all)
	popd
done
