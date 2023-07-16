#!/bin/bash

# error handling on parameter counts less than 2. 
if [ $# -lt 2 ]; 
then
    echo "2 parameters required. first parameter is for a directory, second parameter is for a search string."
    echo "error - program terminated."
    exit 1
else
    filesdir=$1
    searchstr=$2

# error handling, if the first parameter isn't a directory.
    if [ ! -d "$filesdir" ]; 
    then
    	echo "first parameter '$filesdir' : not a directory."
    	echo "error - program terminated."
	exit 1
    else

# file and string counts(duplication is subtracted).
	raw01=`find $filesdir | xargs grep -rch $searchstr`
	raw02=`find $filesdir -type f | xargs grep -rch $searchstr`

	for var in $raw01
	do
		if [ $var -ne 0 ];
		then
			filecnt01=$((filecnt01+1))
			stringcnt01=$((stringcnt01+var))
		fi
	done

	for var in $raw02
        do
                if [ $var -ne 0 ];
                then
                        filecnt02=$((filecnt02+1))
                        stringcnt02=$((stringcnt02+var))
                fi
        done

# output the search result.
	echo "The number of files are $((filecnt01-filecnt02)) and the number of matching lines are $((stringcnt01-stringcnt02))."
    	echo "program execution completed."
    fi
fi
