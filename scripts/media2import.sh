#
# this is simple script for importing media files from source (such as memory cards)
# to destination (such as local storage), creating date directories and renaming them by timestamp
# of given file in desired format
#

#
# Author: Anton TETERIN (https://og2k.com)
# Source: https://github.com/InstallAndUse/Graphics
#
# History:
# 2023-05-07  * init /A
# 2023-05-08  + read flags from CLI /A
# 2023-05-16  * moved from rsync to file 'for' itiration /A
#

function ts() {
    return $(date)
}

# read flags
usage () {
    echo "Usage: $0 -s - source, -d destination, -n note";
    exit 1;
}
while getopts s:d:n: flag
do
    case "${flag}" in
        s) src=${OPTARG};;
        d) dst=${OPTARG};;
        n) note=${OPTARG};;
        ?) usage;;
    esac
done


# read source, by default current path (if not given)
# assuming not recursive, only in-directory files will be imported
if [ -z ${src} ]; then
    read -p "Source      [$(pwd)]: " src
    if [ -z ${src} ]; then
        src="$(pwd)"
    fi
fi

# read destination, by default current path (if not given)
if [ -z ${dst} ]; then
    read -p "Destination [$(pwd)]: " dst
    if [ -z ${dst} ]; then
        dst="$(pwd)"
    fi
fi

# read noteription, by default empty
if [ -z ${note} ]; then
    read -p "Note of session/event: " note
    if [ -z ${note} ]; then
        note=""
    else
        # adding hyphen before noteription, if it is not empty
        note=" - ${note}"
    fi
fi

# source and destination can not be the same, exit
if [ ${src} = ${dst} ]; then
    echo "Source and destination are the same, exiting..."
    exit 2
fi


# confirm
echo "Source:      [${src}]"
echo "Destination: [${dst}]"
echo "Note:        [${note}]"

read -p "Confirm (Y): " confirm
if [ ${confirm} = "Y" ]; then
    echo "Reading source and beginning to move..."

    # check that source directory exists, otherwise - exit
    if ! [ -d ${src} ]; then
        echo "Source directory does not exist, exiting..."
        exit 2
    fi

    # check and create destination directory, if needed
    if [ -d ${dst} ]; then
        mkdir -p -m 700 ${dst}
    fi

    # itirating files
    for file in ${src}/*; do
        file_mdate="$( stat -f %Sm -t %Y-%m-%d ${file} )"
        echo "Filename: ${file}, it's modification date is: ${file_mdate}"
        mkdir -p ${dst}/${file_mdate}
        echo "[ $(ts) ] src: [${file}] dst: [${dst}/${file_mdate}]"
        cp -v ${file} ${dst}/${file_mdate}
    done

    # TODO: output total amount of files and size
    # itirate files
        # read creation date of file
        #dst_subdir="${dst}/${file_creation_date}${note}"
        # read creation date and time of file
        #file_new_name="$(read creation date and time, format)-${file}"
        # output debug
        # hash before move
        # TODO: check if file exists
        # hash after
        # TODO: compare hashes, output result

else
    # not confirmed
    echo "Operation is not confirmed."
    exit 1
fi