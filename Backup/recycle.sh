#!/bin/bash

# End the script immediately if any command or pipe exits with a non-zero status.
set -eo pipefail

recyclebin="/home/recyclebin"
restorefile="/home/.restore.info"

# Check for recycle bin directory, if not found create it using the mkdir 
[ ! -d $recyclebin ] && mkdir -p "$recyclebin"


# Check for .restore.info, if not found create it using the touch
[ ! -f $restorefile ] && touch "$restorefile"


# Initial optionals
verbose=false
interactive=false
directories=false

setOptions() {
    while getopts ":vir" option; 
        do
            case $option in
                i) interactive=true;;
                v) verbose=true;;
                vi) interactive=true;verbose=true;;  
                iv) interactive=true;verbose=true;;
                r) directories=true;;
                *) echo "Invalid option, you can specify [v] for verbose, [i] for interactive, or [r] for directory removal"; exit 1;;
            esac
        done    
}

# Process optionals 
setOptions $@

# Shifts the argument list so the optionals are removed, later you will be only processing filenames
for a; do
   shift
   case $a in
   -*) opts+=("$a");;
   *) set -- "$@" "$a";;
   esac
done

# Recycle Basic Functions
recycle() {
    file_paths=$fileName

    # If the defined path is a directory, list all files recursively
    if [ -d $file_paths ]; then
       file_paths=$(find $file_paths -type f)
    fi
    
    for each_file in $file_paths
        do
            if [ "$each_file" != "$(basename $BASH_SOURCE)" ]; then
                inode=$(stat -c '%i' $each_file)
                fileinode="$(basename $each_file)_$inode"

                mv $each_file $recyclebin/$fileinode
                echo "$fileinode:$(readlink -f $each_file)" >> $restorefile
                
                if [ "$verbose" = true ]; then
                    echo "removed '$fileName', it is in the recycle bin"
                fi
            else
                echo "Trying to delete the shell source file itself, skipping"
            fi
        done

    if [ -d $file_paths ]; then
        rm -rf $fileName
    fi
}

# To remove multiple files, using a for loop
# $@ is an array ($1, $2 ...)

if [ $@ ]; then
    for fileName in $@
        do
            if [[ -d $fileName && "$directories" = true ]] || [ -f $fileName ]; then

                  if [ "$interactive" = true ]; then
                    read -p "Are you sure you want to delete $fileName (y/n)?" yn
                    case $yn in 
                        [Nn]* ) exit 1;;
                    esac

                 fi
                 recycle
            else
                echo "Invalid file $fileName or a directory specified, use [-r] for recursively removing directories"
            fi  

        done
else
    echo "No filename provided"
fi

