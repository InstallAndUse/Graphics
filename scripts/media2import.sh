#
# This is simple script for importing media files from source (such as memory cards)
# to destination (such as local storage), creating date directories and renaming them by timestamp
# of given file in desired format. Other features of script: integrity check (using sha256sum).
#
#

#
# Author: Anton TETERIN (https://og2k.com)
# Source: https://github.com/InstallAndUse/Graphics
#
# History:
# 2023-05-07  * init /A
# 2023-05-08  + read flags from CLI /A
# 2023-05-16  * moved from rsync to file 'for' itiration /A
# 2023-06-27  * upgrading /A
# 2023-06-28  * path with spaces variables /A
# 2023-06-29  + hash comparison /A
#             + removal on successful integrity verification /A
# 2023-06-30  + add note to subdir, if specified /A
#



function ts() {
    # change d
    ts=$(date)
    echo $(date )
}

# default help
usage () {
    echo "Usage: $0 -s - source, -d destination, -n note";
    exit 1;
}


# TODO: skip files which specified extensions (*.LRV, *.THM)
# TODO: remove files with specififed extensions (*.LRV, *.THM)

# read flags
while getopts s:d:n: flag
do
    case "${flag}" in
        s) src=${OPTARG};;
        d) dst=${OPTARG};;
        n) note=${OPTARG};;
        ?) usage;;
    esac
done


# read source path, by default current path (if not given)
# assuming not recursive, only in-directory files will be imported
if [ -z $src ]; then
    read -p "[ $(ts) ]: Source      [$(pwd)]: " src
    if [ -z ${src} ]; then
        src="$(pwd)"
    fi
fi

# read destination path, by default current path (if not given)
if [ -z $dst ]; then
    read -p "[ $(ts) ]: Destination [$(pwd)]: " dst
    if [ -z ${dst} ]; then
        dst="$(pwd)"
    fi
fi

# read noteription, by default empty
if [ -z $note ]; then
    read -p "[ $(ts) ]: Note of session/event: " note
    if [ -z ${note} ]; then
        note=""
    else
        # adding hyphen before note, if it is not empty
        note=" - ${note}"
    fi
fi

# source and destination can not be the same, exit
if [ ${src} = ${dst} ]; then
    echo "[ $(ts) ]: Source and destination are the same, exiting..."
    exit 2
fi

# # itirating files
#     # calculate total size for source files, as they will be copied (not recursive for directory)
# done
# echo "The size of all NN files is YY bytes (YY/1024 MB = YY/1024/104) GB."


echo "[ $(ts) ]: ----- [ Transfer details ] ---------------------------------------------"

# check that source directory exists, otherwise - exit
if [ -d "$src" ]; then
    # TODO: src, dst total and free disk space before transfer
    files_src_total_amount=0
    files_src_total_size=0
    for file in "$src"/*; do
        file_size="$( stat -f %z "$file" )"
        # echo "[ $(ts) ]: file: ${file} adding file_size: $(( $file_size/1024/1024 )) MB."
        files_src_total_size=$(( $files_src_total_size+$file_size ))
        files_src_total_amount=$(( $files_src_total_amount+1 ))
    done
    echo "[ $(ts) ]: Source:      [${src}]"
    # TODO: add nice GB figures (need to use awk or bc)
    echo "[ $(ts) ]: Total of $files_src_total_amount src files, total size is $(( $files_src_total_size/1024/1024 )) MB)."

else
    echo "[ $(ts) ]: src dir does not exist, exiting..."
    exit 2
fi

echo "[ $(ts) ]: Destination: [${dst}]"
echo "[ $(ts) ]: Note:        [${note}]"

# confirm
read -p "[ $(ts) ]: Confirm (Y): " confirm
if [ ${confirm} = "Y" ]; then
    echo "[ $(ts) ]: Preparing to transfer..."

    # check and create destination directory, if needed
    if ! [ -d "$dst" ]; then
        read -p "[ $(ts) ]: dst dir does not exist, do you want to create?" confirm
        if [ ${confirm} = "Y" ]; then
            mkdir -v -p -m 700 "$dst"
            echo "[ $(ts) ]: dst dir created."
        fi
    fi


    files_copied_filename=()
    files_copied_total_size=0
    files_error_filename=()

    # itirating files
    for file in "$src"/*; do
        # echo "[ $(ts) ]: src dir:       ["$src"]"

        filename="$(basename "$file")"
        # figure out when is the creation date
        file_mdate="$( stat -f %Sm -t %Y-%m-%d "$file" )"
        file_size="$( stat -f %z "$file" )"

        # appending note, if specified
        if [ -z "$note" ]; then
            dst_subdir="${file_mdate}"
        else
            dst_subdir="${file_mdate}${note}"
        fi

        # create subdirectory for creation date
        mkdir -p "$dst"/"$dst_subdir"
        # TODO: echo 'show which file is being copied out of total' in the same status line below
        echo "[ $(ts) ]: src dst: ["$src"], file: [${filename}], modification date is: ${file_mdate}, ( $(( ${file_size}/1024/1024 )) MB )"

        # TODO: linux/BSD check for shasum function, if it does not run properly on linux
        # calulating src hash sum
        src_hash=$( shasum -a 256 "$file" | cut -d ' ' -f 1)
        # echo "[ $(ts) ]: src sha256sum: [${src_hash}]"
        echo "[ $(ts) ]: dst subdir: ["$dst"/"$dst_subdir"]"

        # main operation
        # echo "[ $(ts) ] copying.."
        cp "$file" "$dst"/"$dst_subdir"

        # calulating dst hash sum
        dst_hash=$( shasum -a 256 "${dst}/${dst_subdir}/${filename}" | cut -d ' ' -f 1)
        # echo "[ $(ts) ]: dst sha256sum: [${dst_hash}]"

        # if shasum is the same, add to statistics and remove file
        if [ ${src_hash} = ${dst_hash} ]; then
            # add to files_copied array
            files_copied_filename+=("$filename")
            files_copied_total_size+=$file_size

            # TODO: add summarize sized of copied file ${file_size}
            # echo "[ $(ts) ]: src and dst hashes are the same, removing src file"
            rm "${file}"
        else
            echo "[ $(ts) ]: src and dst hashes are different, src file will not be removed."
            files_error_filename+=("$file")
        fi

        # TODO: add original file with fullpath to array:
        # files_src[]="${file}]"

        # TODO: add copied file with fullpath to array:
        # files_dst[]="$dst"/"$dst_subdir"/${filename}
    done

    # TODO: src, dst total and free disk space before transfer
    # TODO: src, dst total and free disk space after copy
    # TODO: time taken to transfer
    # TODO: avarage transfer speed

    # TODO: unmount src disk ?
    # diskutil unmount /Volumes/empty

    # TODO: open latest directory created?

    # TODO: output total amount of files and size
    # itirate files
        # read creation date of file
        #dst_subdir="${dst}/${file_creation_date}${note}"

    # TODO: list subdirs, that created (in order to see, where to files are transferred)

else
    # not confirmed
    echo "[ $(ts) ]: Operation is not confirmed."
    exit 1
fi