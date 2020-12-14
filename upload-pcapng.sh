#!/bin/bash
VERSION="v1.2"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"

source "$SCRIPTPATH"/creds.txt

if ping "wpa-sec.stanev.org" -c 1 -w 5 > /dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: wpa-sec.stanev.org couldn't be reached, check your internet connection"
	exit
fi

while getopts "d:h?:*:" arg; do
	case ${arg} in
	d ) DIRECTORY="$OPTARG";;
	h )
		echo "upload-pcapng by Czechball, part of wpa-sec-api scripts"
		echo "wpa-sec-api version $VERSION"
		echo "https://github.com/Czechball/wpa-sec-api"
		echo
		printf "Usage:\n\
	%s <file.pcapng> or %s -d <direcory>
Options:\n\
	-d		direcory with captures (will upload all network capture files and move them to a subdirectory named uploaded)" "$0" "$0"
		echo
		exit
	;;
	\? ) echo "Invalid arguments. Use $0 -h for help"; exit
	;;
	* )  echo "Invalid arguments. Use $0 -h for help"; exit
	;;
  esac
done

if [[ $WPASECKEY == "" ]]; then
	echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
	exit
fi

if [[ $DIRECTORY == "" ]]; then
	FILE="$1"
	if [[ $FILE == "" ]]; then
		echo -e "\e[91mERROR\e[0m: No file specified. Use $0 -h for help"
		exit
	fi
		echo "Uploading $FILE..."
		if test -f "$FILE"; then
			curl "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'
		else
			echo "$FILE is not a valid file. Aborting"
		fi
else
	if test -d "$DIRECTORY"; then
		mkdir -p "$DIRECTORY"/uploaded || { echo -e "\e[91mERROR\e[0m: Cannot create uploaded directory" ; exit 1; }
		echo "Uploading all capture files from $DIRECTORY and moving to $DIRECTORY/uploaded"
		FILES=$(find "$DIRECTORY"/ -print -exec file {} \; | grep "pcapng capture file" | awk '{print substr($1,1,length($1)-1)}')
		for FILE in $FILES ; do
			echo "Uploading $FILE..."
			curl "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'
			mv "$FILE" "$DIRECTORY"/uploaded || { echo -e "\e[91mERROR\e[0m: Cannot move $FILE to uploaded" ; exit 1; }
			echo
		done
	else
		echo "$DIRECTORY is not a valid directory. Aborting"
	fi
fi
