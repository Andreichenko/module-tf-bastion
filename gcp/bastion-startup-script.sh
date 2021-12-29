#!/bin/bash


# Output information about what this script is doing.
function info {
  echo "startup-script: $@"
}

# GCP startup scripts are run on each boot.
info Determining whether this script has been run before. . .
if [ -r /metadata_startup_script-has_run ] ; then
info THis script has been run, as the /metadata_startup_script-has_run file exists.
info Exiting...
exit 0
fi
touch /metadata_startup_script-has_run