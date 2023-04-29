#!/usr/bin/env bash
#End the script immediately if any command or pipe exits with a non-zero status.
set -eo pipefail

recyclebin="$HOME/recyclebin"
restorefile=$HOME/.restore.info

# the basic restore function
# Uses the sed command to remove lines
restore() {
    mv $recyclebin/$fileName $originalDir
    sed -i "\'$search'd" $restorefile


    echo "The file $fileName had been restored"
}


# check if argument is provided
if [ ! -z $1 ]; then
    fileName=$1
    search=$(grep "$fileName" $restorefile)
    originalDir=$(grep $fileName $restorefile | grep -o "\/.\+")
else
    echo "Please enter file name:"
    
    exit 1
fi

# Restore the file, if it is present in .restore.info
if [ -f "$originalDir" ]; then
    read -p "Do you want to overwrite $fileName? y/n: " yn
    case $yn in
        [Yy]* ) restore;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no."
            exit 1;;
    esac
    # if the file exists call restore function
elif [ -f "$recyclebin/$fileName" ]; then
    restore
else
    echo "File does not exist"
    
    exit 1
fi
