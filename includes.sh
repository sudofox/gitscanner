#!/bin/bash

# Provides quick formatting vars to other scripts
# as well as some useful utils

COLOR_BOLD=$(tput bold);
COLOR_RESET=$(tput sgr0);
COLOR_DIM=$(tput dim);
COLOR_RED=$(tput setaf 1);
COLOR_GREEN=$(tput setaf 2);
COLOR_BLUE=$(tput setaf 4);

# strip out lines from a file starting with # (comment) or blank

load_config () {
	cat $1 |egrep -v '^[[:blank:]]*#|^[[:blank:]]*$'
}
