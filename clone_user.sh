#!/bin/bash

SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR" ]]; then SCRIPTDIR="$PWD"; fi
. "$SCRIPTDIR/formatting.sh"

usage() {
        echo "${COLOR_BOLD}Clone all repositories from a GitHub user/organization${COLOR_RESET}"
        echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "<github username>${COLOR_RESET}"
        echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" sudofox${COLOR_RESET}"
        exit;
}

[ -z "$1" ] && usage

REPOS=$(curl -s https://api.github.com/users/$1/repos|jq -r '.[].clone_url')

for repo in $REPOS; do
	echo "${COLOR_BOLD}Cloning repository: $repo${COLOR_RESET}..."
	gituser=$(echo -n $repo|awk -F/ '{print $4}')
	if [ ! -d "$SCRIPTDIR/repositories/$gituser" ]; then
		mkdir -p "$SCRIPTDIR/repositories/$gituser"
	fi
	pushd "$SCRIPTDIR/repositories/$gituser"
	git clone $repo
	popd
done
