#!/bin/bash

SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR" ]]; then SCRIPTDIR="$PWD"; fi
. "$SCRIPTDIR/includes.sh"

usage() {
	echo "${COLOR_BOLD}Clone all repositories from a GitHub user/organization${COLOR_RESET}"
	echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "<github username>${COLOR_RESET}"
	echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" sudofox${COLOR_RESET}"
	exit
}

[ -z "$1" ] && usage

# curl -s https://api.github.com/users/$1/repos?per_page=100|jq -r '.[].clone_url'

# get_repo_page (user, page)
function get_repo_page() {
	GIT_USER=$1
	GIT_PAGE=$2
	URL="https://api.github.com/users/$GIT_USER/repos?per_page=100&page=$GIT_PAGE"
	# fetch the page
	RESULT=$(curl -sL $URL)
	# check for error
	if [ "$(jq -r 'map(type)[0]' <<<$RESULT)" == "string" ] && [ "$(jq 'has("message")' <<<$RESULT)" == "true" ]; then
		echo "${COLOR_RED}Error:${COLOR_RESET} "$(echo $RESULT | jq -r '.message') >&2
		exit 1
	fi

	echo "$RESULT" | jq -r '.[].clone_url'

}

# do until result count < 100

PAGE=1
REPOS=""

while true; do
	NEXT_PAGE=$(get_repo_page $1 $PAGE) || exit $?
	# append lines to REPOS
	REPOS="$REPOS"$'\n'"$NEXT_PAGE"
	# if count < 100, break
	COUNT=$(echo "$NEXT_PAGE" | wc -l)
	if [ $COUNT -lt 100 ]; then
		break
	fi
	PAGE=$((PAGE + 1))
done

echo "$REPOS" > repocache.txt

for repo in $REPOS; do
	if [[ $(comm -23 <(echo $repo | grep -Po "github.com\/\K.+?(?=\.git)") <(cat exclude.txt | egrep -v '^[[:blank:]]*#|^[[:blank:]]*$' | sort | uniq) | wc -w) -lt 1 ]]; then
		continue
	fi

	gituser=$(echo -n $repo | awk -F/ '{print $4}')
	gitrepo=$(echo -n $repo | awk -F/ '{print $5}' | sed 's/\.git//')

	echo "${COLOR_RESET}${COLOR_BOLD}Cloning repository: ${COLOR_RESET}$repo...${COLOR_DIM}"

	if [ ! -d "$SCRIPTDIR/repositories/$gituser" ]; then
		mkdir -p "$SCRIPTDIR/repositories/$gituser"
	fi

	# if the repo doesn't exist, clone it
	if [ ! -d "$SCRIPTDIR/repositories/$gituser/$gitrepo" ]; then
		pushd "$SCRIPTDIR/repositories/$gituser" > /dev/null
		git clone $repo
	else
		# otherwise, pull the latest changes
		pushd "$SCRIPTDIR/repositories/$gituser/$gitrepo" > /dev/null
		git pull
	fi
	popd > /dev/null
done

echo -e "${COLOR_RESET}"