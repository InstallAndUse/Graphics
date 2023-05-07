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
#

function ts() {
    return $(date)
}

# read arguments
# src
# dst
#desc


# read source, by default current path (if not given)
# assuming not recursive, only in-directory files will be imported
echo "Source [$(pwd)]:"
read src
if [ ${src} != "" ]l then
    src = "$(pwd)"
fi

# read destination, by default current path (if not given)
echo "Destination [$(pwd)]:"
read dst
if [ ${dst} != "" ]l then
    dst = "$(pwd)"
fi

# source and destination can not be the same, exit
if [ ${src} -eq ${dst} ]; then
    echo "[$ts] Source and destination are the same, exiting..."
    exit 2
fi

# read description, by default empty
echo "Description of session/event:"
read desc
if [ ${desc} != "" ]l then
    # adding hyphen before description, if it is not empty
    desc = " - ${desc}"
fi

# create filelist from source
# TODO: output total amount of files and size
# itirate files
    # read creation date of file
    dst_subdir="${dst}/${file_creation_date}${desc}"
    # read creation date and time of file
    file_new_name="$(read creation date and time, format)-${file}"
    # output debug
    echo "[ $(ts()) ] src: [${src}/${file], dst: [${dst_subdir}/${file_new_name}]"
    # hash before move
    # TODO: perhaps, replace with rsync (if there will be any sense)
    # TODO: check if file exists
    mv -v ${src}/${file} ${dst_subdir}/${file_new_name}
    # hash after
    # TODO: compare hashes, output result