#!/bin/bash
VERSION="v1.3"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit 1; } >/dev/null 2>&1 ; pwd -P )"

if test -f "$SCRIPTPATH"/config.txt; then
	read -p "config.txt already exists, do you want to create a new one? (Y/n) " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		:
	else
		exit
	fi
else
	echo "Creating a new config.txt file..."
fi

read -r -p "Enter your dwpa backend url [default: https://wpa-sec.stanev.org/]: " DWPAURL
DWPAURL=${DWPAURL:-https://wpa-sec.stanev.org/}
read -r -p "Enter your dwpa (wpa-sec) key: " DWPAKEY
read -r -p "Enter your Wigle API name (from https://wigle.net/account): " WIGLEAPINAME
read -r -p "Enter your Wigle API key: " WIGLEAPIKEY
wigle_question()
{
read -r -p "Enable Wigle.net uploads? (true/false) [default: true] " ENABLE_WIGLE_UPLOAD
}
wigle_question
ENABLE_WIGLE_UPLOAD=${ENABLE_WIGLE_UPLOAD:-true}
if [[ "$ENABLE_WIGLE_UPLOAD" != "true" && "$ENABLE_WIGLE_UPLOAD" != "false" ]]; then
	echo "Please enter a correct value (true/false)"
	wigle_question
fi

echo "#!/bin/bash" > "$SCRIPTPATH"/config.txt || { echo -e "\e[91mERROR\e[0m: Can't write to $SCRIPTPATH/config.txt" ; exit 1; }
echo "CONF_VERSION=\"$VERSION\"" >> "$SCRIPTPATH"/config.txt
echo >> "$SCRIPTPATH"/config.txt
echo "DWPAURL=\"$DWPAURL\"" >> "$SCRIPTPATH"/config.txt
echo "DWPAKEY=\"$DWPAKEY\"" >> "$SCRIPTPATH"/config.txt
echo "WIGLEAPINAME=\"$WIGLEAPINAME\"" >> "$SCRIPTPATH"/config.txt
echo "WIGLEAPIKEY=\"$WIGLEAPIKEY\"" >> "$SCRIPTPATH"/config.txt
echo "ENABLE_WIGLE_UPLOAD=\"$ENABLE_WIGLE_UPLOAD\"" >> "$SCRIPTPATH"/config.txt

echo "config.txt written succesfully, you can now start using the rest of the scripts."