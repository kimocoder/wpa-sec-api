#!/bin/bash
VERSION="v1.2"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"
GUI=false
USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'

source "$SCRIPTPATH"/creds.txt

show_usage ()
{
	echo "Invalid arguments. Usage: $0 <file> <options> Use $0 -h for help"
	exit 1
}

zenity_error ()
{
	zenity --error --ellipsize --text="$1"
	exit 1
}

if ping "wpa-sec.stanev.org" -c 1 -w 5 > /dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: wpa-sec.stanev.org couldn't be reached, check your internet connection"
	exit
fi

while getopts "d:hg?:*:" arg; do
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
	g )
		if which zenity >/dev/null; then
			echo -e "Running in GUI mode..."
			GUI=true
		else
			echo -e "\e[91mERROR\e[0m: Zenity not found."
		fi
	;;
	\? ) show_usage
	;;
	* )  show_usage
	;;
  esac
done
shift $(( OPTIND-1 ))

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
		if test -f "$FILE"; then
			if [[ $GUI = true ]]; then
				(curl "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE"\
					-b "key=$WPASECKEY"\
					-A "$USER_AGENT" -# -o /tmp/curl-wpasec-output 2>&1 | while IFS= read -r -n1 char; do
				    [[ $char =~ [0-9] ]] && keep=1 ;
				    [[ $char == % ]] && echo "$progress" && progress="" && keep=0 ;
				    [[ $keep == 1 ]] && progress="$progress$char" ;
				done) | zenity --progress --title="Uploading..." --text="$FILE" --auto-kill --time-remaining --auto-close
				RESULT=$(cat /tmp/curl-wpasec-output)
				if echo "$RESULT" | grep "No valid handshakes" > /dev/null; then
					zenity_error "No valid handshakes/PMKIDs found."
				elif echo "$RESULT" | grep "Not a valid capture file" > /dev/null; then
					zenity_error "Not a valid capture file."
				elif echo "$RESULT" | grep "was already submitted" > /dev/null; then
					zenity_error "File was already uploaded before."
				fi
				HS_COUNT=$(echo "$RESULT" | grep "EAPOL pairs (best)" | sed 's/[^0-9]*//g')
				PM_COUNT=$(echo "$RESULT" | grep "PMKID (best)" | sed 's/[^0-9]*//g')
				TOTAL_COUNT=$(( HS_COUNT + PM_COUNT ))
				zenity --info --title="Success" --text="$TOTAL_COUNT handshakes uploaded from $FILE" --ellipsize
			else
				printf "Uploading %s... " "$FILE"
				RESULT=$(curl -s "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A "$USER_AGENT" 2>/dev/null)
				if echo "$RESULT" | grep "No valid handshakes" > /dev/null; then
					echo -e "\e[91mno valid handshakes/PMKIDs found.\e[0m"
				elif echo "$RESULT" | grep "Not a valid capture file" > /dev/null; then
					echo -e "\e[91mnot a valid capture file.\e[0m"
				elif echo "$RESULT" | grep "was already submitted" > /dev/null; then
					echo -e "\e[91mfile was already uploaded before.\e[0m"
				fi
				HS_COUNT=$(echo "$RESULT" | grep "EAPOL pairs (best)" | sed 's/[^0-9]*//g')
				PM_COUNT=$(echo "$RESULT" | grep "PMKID (best)" | sed 's/[^0-9]*//g')
				TOTAL_COUNT=$(( HS_COUNT + PM_COUNT ))
				echo -e "\e[92m$TOTAL_COUNT handshakes\e[0m"
			fi
		else
			echo "$FILE is not a valid file. Aborting"
		fi
else
	if test -d "$DIRECTORY"; then
		mapfile -t FILES < <(find "$DIRECTORY"/ -maxdepth 1 -print -exec file {} \; | grep "pcapng capture file" | awk '{print substr($1,1,length($1)-1)}')
		if [[ $FILES == "" ]]; then
			echo -e "\e[91mERROR\e[0m: No valid capture files found in $DIRECTORY"
			exit
		fi
		mkdir -p "$DIRECTORY"/uploaded || { echo -e "\e[91mERROR\e[0m: Cannot create uploaded directory" ; exit 1; }
		echo "Uploading all capture files from $DIRECTORY and moving to $DIRECTORY/uploaded"
		C=0
		for FILE in "${FILES[@]}" ; do
			HS_COUNT=""
			PM_COUNT=""
			C=$(( C + 1 ))
			printf "Uploading %s... [%s/%s]: " "$FILE" "$C" "${#FILES[@]}"
			RESULT=$(curl -s "https://wpa-sec.stanev.org/?submit" -X POST -F "file=@$FILE" -b "key=$WPASECKEY" -A "$USER_AGENT" 2>/dev/null)
			if echo "$RESULT" | grep "No valid handshakes" > /dev/null; then
				echo -e "\e[91mno valid handshakes/PMKIDs found.\e[0m"
			elif echo "$RESULT" | grep "Not a valid capture file" > /dev/null; then
				echo -e "\e[91mnot a valid capture file.\e[0m"
			else
			HS_COUNT=$(echo "$RESULT" | grep "EAPOL pairs (best)" | sed 's/[^0-9]*//g')
			PM_COUNT=$(echo "$RESULT" | grep "PMKID (best)" | sed 's/[^0-9]*//g')
			TOTAL_COUNT=$(( HS_COUNT + PM_COUNT ))
			TOTAL_DIR_COUNT=$(( TOTAL_DIR_COUNT + TOTAL_COUNT ))
			echo -e "\e[92m$TOTAL_COUNT handshakes\e[0m"
			fi
			mv "$FILE" "$DIRECTORY"/uploaded || { echo -e "\e[91mERROR\e[0m: Cannot move $FILE to uploaded" ; exit 1; }
		done
		echo -e "\e[92mUploaded $TOTAL_DIR_COUNT handshakes in total from $C files.\e[0m"
	else
		echo "$DIRECTORY is not a valid directory. Aborting"
	fi
fi
