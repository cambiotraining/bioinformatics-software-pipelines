#!/usr/bin/env bash

set -euo pipefail

# check if user is running this from within the course_files directory
CURRENT_DIR=$(basename $PWD)
if [ "$CURRENT_DIR" != "course_files" ]; then
  echo "Please run this script from within the course_files directory."
  exit 1
fi

# download the data from dropbox
# allow checkpointing and resuming downloads
wget --continue -O dropbox_data.zip "https://www.dropbox.com/scl/fo/hof2gmftr8iq1744jkwnd/AOE_vgyKxphI63OAA5dCzqM?rlkey=k929x9ipitvuexrf72u7hbth9&st=muryirlr&dl=1"

# unzip the file
unzip dropbox_data.zip
