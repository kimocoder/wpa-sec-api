#!/bin/bash
source ./creds.txt
HELP=0
VERSION="v1.1"

if [[ $WPASECKEY == "" ]]; then
	echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
	exit
fi

if [[ $* == "" ]]; then
	echo "Usage: $0 <options> <directory or filename> (-h for help)"
	exit
fi

while getopts ":f:d:" arg; do
  case $arg in
    f) FILE=$OPTARG;;
    d) DIRECTORY=$OPTARG;;
  esac
done

if [[ $* == "-h" ]]; then
	echo "upload-pcapng by Czechball, part of wpa-sec-api scripts"
	echo "wpa-sec-api version $VERSION"
	echo "https://github.com/Czechball/wpa-sec-api"
	echo
	printf "Options:\n	-f		filename to upload\n	-d		direcory with captures (will upload all .pcapng files and move them to a subdirectory named uploaded)"
	echo
	exit
fi

if [[ $1 == "-f" ]]; then
	if [[ $FILE == "" ]]; then
		echo "Usage: $0 -f <file path>"
	else
		echo "Uploading $FILE..."
		if (test -f $FILE); then
			curl "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'
		else
			echo "$FILE is not a valid file. Aborting"
		fi
	fi
elif [[ $1 == "-d" ]]; then
	if [[ $DIRECTORY == "" ]]; then
		echo "Usage: $0 -d <directory path>"
	else
		if (test -d $DIRECTORY); then
			echo "Uploading all .pcapng* files from $DIRECTORY"
			FILES=$(find $DIRECTORY/ -name "*.pcapng*")
			for FILE in $FILES ; do
				echo "Uploading $FILE..."
				curl "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'
			done
			echo
		else
			"$DIRECTORY is not a valid directory. Aborting"
		fi
	fi
else
	echo "Usage: $0 <options> <directory or filename> (-h for help)"
	exit
fi
