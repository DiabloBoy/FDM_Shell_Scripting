#!/usr/bin/env bash
#End the script immediately if any command or pipe exits with a non-zero status.
set -eo pipefail

recyclebin="/home/recyclebin"
restorefile="/home/.restore.info"

# the basic restore function
# Uses the sed command to remove lines
restore() {
      for each_match in $path_matches
          do
              file_name_inode=$( echo $each_match | sed 's/:.*//')
              file_restore_path=$( echo $each_match | sed 's/.*://')

              # Exit if not rewriting
              if [ -f $file_restore_path ]; then 

                read -p "Do you want to overwrite $fileName? (y/n)" yn
                case $yn in
                    [Yy]* ) continue;;
                    [Nn]* ) exit 1;;
                    * ) echo "Please answer yes or no."; exit 1;;
                esac
              fi
              
              dir_path=$(echo ${file_restore_path%/*})

              # Check for a directory, if not make it
              if [ ! -d $dir_path ]; then
                mkdir $dir_path
              fi

              # Proceed to move files and clear .restore.info 
              mv $recyclebin/$file_name_inode $file_restore_path
              sed -i "\'$each_match'd" $restorefile

              echo "The file/directory $fileName has been restored"

          done
}


# check if argument is provided
if [ ! -z $1 ]; then

    fileName=$1
    if [ ! $(grep -q "$fileName" $restorefile) ]; then
        IFS=$'\n'
        path_matches=$(grep -h "$fileName" $restorefile)
        restore
    else
        echo "File does not exist"
        
        exit 1
    fi

else
    echo "No filename provided"
    
    exit 1
fi



