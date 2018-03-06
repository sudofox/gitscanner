# sudofox/gitscanner

Tools/utilities to clone every repository from a GitHub user or organization, and all the members of organization; and to scan over the entire commit history to find interesting things

This will take up a lot of disk space!

Requires installation of jq utility to parse GitHub API responses

### clone_organization_users.sh

`./clone_organization_users.sh organizationname`

Iterate through an organization's users and clone all their stuff

### clone_user.sh

`./clone_user.sh username`

Clone all repos from a user

### search.sh

Takes regex, search through all repos and all their commit history for interesting strings that may be or may have been part of the repo

`./search.sh '[0-9]{1,}regex'`

### exclude.txt

Exclude repositories that are just forks or are too massive to manage/search/store

One per line. Format:

`username/reponame`

