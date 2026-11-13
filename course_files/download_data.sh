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
wget --continue -O dropbox_data.zip "https://www.dropbox.com/scl/fo/9gj9fvm3phlgz8jf27atw/ACM3JSA5IqPnjnEIcLTSx0w?rlkey=jfn2qgequjtdazand89ytoary&st=oysvdj11&dl=1"

# unzip the file
unzip dropbox_data.zip
