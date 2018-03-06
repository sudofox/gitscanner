#!/bin/bash

SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR" ]]; then SCRIPTDIR="$PWD"; fi
. "$SCRIPTDIR/includes.sh"

usage() {
        echo "${COLOR_BOLD}Clone all repositories from a GitHub user/organization${COLOR_RESET}"
        echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "<github username>${COLOR_RESET}"
        echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" sudofox${COLOR_RESET}"
        exit;
}

[ -z "$1" ] && usage

REPOS=$(curl -s https://api.github.com/users/$1/repos?per_page=100|jq -r '.[].clone_url')

for repo in $REPOS; do
	if [[ $(comm -23 <(echo $repo| grep -Po "github.com\/\K.+?(?=.git)") <(cat exclude.txt |egrep -v '^[[:blank:]]*#|^[[:blank:]]*$'|sort|uniq)|wc -w) -lt 1 ]]; then
		continue;
	fi
	echo "${COLOR_BOLD}Cloning repository: $repo${COLOR_RESET}..."
	gituser=$(echo -n $repo|awk -F/ '{print $4}')
	if [ ! -d "$SCRIPTDIR/repositories/$gituser" ]; then
		mkdir -p "$SCRIPTDIR/repositories/$gituser"
	fi
	pushd "$SCRIPTDIR/repositories/$gituser"
	git clone $repo
	popd
done
