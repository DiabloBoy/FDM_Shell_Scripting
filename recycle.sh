#!/bin/bash

# End the script immediately if any command or pipe exits with a non-zero status.
set -eo pipefail

recyclebin="$HOME/recyclebin"
restorefile="$HOME/.restore.info"

# Check for recycle bin directory, if not found create it using the mkdir 
[ ! -d $recyclebin ] && mkdir -p "$recyclebin"


# Check for .restore.info, if not found create it using the touch
[ ! -f $restorefile ] && touch "$restorefile"


# Initialization of options

verbose=false
interactive=false
directories=false

setOptions() {
    while getopts ":ivr" option; 
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

# Call the setOptions Function providing user inputs as arguments
 setOptions $@ 

# Shifts the argument list so the optionals are removed, and allows the script to process filenames
for a; do
   shift
   case $a in
   -*) opts+=("$a");;
   *) set -- "$@" "$a";;
   esac
done


# This checks if no filenames are provided
  if [ -z $1 ]; then
    echo "Please enter a filename"
    
    exit 1
    fi

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi  


# Recycle Basic Functions
recycle() {

    echo "Calling Recycle"

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
                
                if [ $verbose ]; then
                    echo "removed '$fileName', you can find it in recyclebin folder"
                fi
            else
                echo "Attempting to delete recycle - operation aborted"
            fi
        done
}



# To remove multiple files, using a for loop
# $@ is an array ($1, $2 ...)
for fileName in $@

    do
    echo  $interactive 
    echo  $directories

    if [ -d $1 ] && [ "$directories" = false ] ; then
    echo "$1 is a directory, please enter a file"
    exit 1
     fi
    
        if [[ -d $fileName  &&  $directories ]] || [ -f $fileName ]; then

        if [ $interactive ]; then
        
            #echo $interactive;

            read -p "Are you sure you want to delete $fileName (y/n)?" yn
            case $yn in 
                [Nn]* ) exit 1;;
            esac

        fi
            recycle

        else
            echo "The file $fileName does not exist"
        fi  

    done

