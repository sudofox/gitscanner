#!/bin/bash

SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR" ]]; then SCRIPTDIR="$PWD"; fi
. "$SCRIPTDIR/formatting.sh"

usage() {
        echo "${COLOR_BOLD}Clone all repositories from all members of a GitHub organization${COLOR_RESET}"
        echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "<github organization name>${COLOR_RESET}"
        echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" Sudomemo${COLOR_RESET}"
        exit;
}

[ -z "$1" ] && usage

USERS=$(curl -sL https://api.github.com/orgs/$1/members|jq -r '.[].login')

for orguser in $USERS; do
	echo "${COLOR_BOLD}Cloning repositories from $orguser...${COLOR_RESET}..."
	$SCRIPTDIR/clone_user.sh $orguser
done
