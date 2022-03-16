#!/bin/bash

# This was made by a bash noob
# The comments are to remind me how I made it
# I'm half just making it to learn how to use bash

# These are for changing text color, colors with 1 before ; are bold
T_RED='\033[1;31m'
T_GREEN='\033[1;32m'
T_BYELLOW='\033[1;33m'
T_YELLOW='\033[0;33m'
T_NOCOLOR='\033[0m'

# Here are the dependencies
GIT_DEPS="git"
SDK_DEPS="cmake gcc-arm-none-eabi gcc g++"
# openocd might be for advanced debugging, not installed by default
# OPENOCD_DEPS="gdb-multiarch automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev"
# I don't want vscode stuff
# VSCODE_DEPS="wget"
UART_DEPS="minicom"

MISSING_PACKAGES=""
for PACKAGE_CATEGORY in GIT SDK UART
do
	# -e allows \n to print a new line
	echo -e "\n --- $PACKAGE_CATEGORY Dependencies "
	# This creates a new variable name by adding _DEPS to the end
	PACKAGE_VARIABLE="${PACKAGE_CATEGORY}_DEPS"
	# The ! turns the string variable name into an actual variable
	for PACKAGE in ${!PACKAGE_VARIABLE}
	do
		OUTPUT_STRING="$PACKAGE"
		# ${#VARIABLE_NAME} gives string length
		while [ ${#OUTPUT_STRING} -lt 24 ];
		do
			# While string is too short, add a char to end
			OUTPUT_STRING="${OUTPUT_STRING}-"
		done
		# Now check if that package is installed
		if command -v "$PACKAGE" >/dev/null 2>&1; then
			printf "${OUTPUT_STRING}${T_GREEN}[Installed]\n${T_NOCOLOR}"
		else
			printf "${OUTPUT_STRING}${T_RED}[ Missing ]\n${T_NOCOLOR}"
			# If the missing packages variable is empty
			if [ ${#PACKAGE} -eq 0 ]; then
					MISSING_PACKAGES="${PACKAGE}"
			else
					MISSING_PACKAGES="${MISSING_PACKAGES} ${PACKAGE}"
			fi
		fi
	done
done
# Ask if they would like to install these
printf "\nWould you to install missing packages? [Y/n] "
read USER_INPUT
printf "\n"
if [ "$USER_INPUT" = "y" ] || [ "$USER_INPUT" = "Y" ]; then
	INSTALL_APT_PACKAGES=1
else
	INSTALL_APT_PACKAGES=0
fi
printf "\n"

# Now ask about the git stuff
if command -v "git" >/dev/null 2>&1; then
	echo There are also git repos made by Raspberry that can be downloaded
	ESSENTIAL_REPOS="pico-sdk picotool"
	OPTIONAL_REPOS="pico-examples pico-playground pico-extras picoprobe"
	# Ask until you get valid response
	while [ 1 -eq 1 ]
	do
		for REPO_TYPE in ESSENTIAL OPTIONAL
		do
			echo -e "\n --- $REPO_TYPE Repositories"
			REPO_VARIABLE="${REPO_TYPE}_REPOS"
			for REPO in ${!REPO_VARIABLE}
			do
				printf "${REPO}\n"
			done
		done
		echo -e "\nWhat would you like to do?"
		echo "[A = Install All]               [E = Install Essential]"
		echo "[C = Choose Which To Install]   [N = Install None]"
		read USER_INPUT
		printf "\n"
		if [ "$USER_INPUT" = "a" ] || [ "$USER_INPUT" = "A" ]; then
			# All git repos are going to be Installed
			echo Installing all git thingies
			INSTALL_GIT_REPOS=1
			break
		elif [ "$USER_INPUT" = "e" ] || [ "$USER_INPUT" = "E" ]; then
			#statements
			echo Intalling essential git repoz
			INSTALL_GIT_REPOS=2
			break
		elif [ "$USER_INPUT" = "c" ] || [ "$USER_INPUT" = "C" ]; then
			echo Why do you have to be awkward...
			INSTALL_GIT_REPOS=3
			break
		elif [ "$USER_INPUT" = "n" ] || [ "$USER_INPUT" = "N" ]; then
			echo Not installing git stuff
			INSTALL_GIT_REPOS=0
			break
		else
			echo Unrecognised user input
		fi
	done
	# If user selected custom, allow them to select the repos
	if [ ${INSTALL_GIT_REPOS} -eq 3 ]; then
		GIT_REPO_LIST=""
		INSTALLING_NON_PICOTOOL=0
		for REPO_TYPE in ESSENTIAL OPTIONAL; do
			REPO_VARIABLE="${REPO_TYPE}_REPOS"
			for REPO in ${!REPO_VARIABLE}; do
				while [ 1 -eq 1 ]; do
					printf "\n${REPO}"
					if [ "${REPO}" = "picotool" ]; then
						printf " is for controlling the pico from terminal"
					elif [ "${REPO}" = "pico-sdk" ]; then
						printf " is essential for compiling C++ code for the pico"
					elif [ "${REPO}" = "picoprobe" ]; then
						printf " is for debugging a pico with another pico"
					fi
					printf "\nInstall this repo? [Y/n] "
					read USER_INPUT
					if [ ${USER_INPUT} = "y" ] || [ ${USER_INPUT} = "Y" ]; then
						if [ "$REPO" != "picotool" ]; then
							INSTALLING_NON_PICOTOOL=1
						fi
						GIT_REPO_LIST="${GIT_REPO_LIST} ${REPO}"
						break
					elif [ ${USER_INPUT} = "n" ] || [ ${USER_INPUT} = "N" ]; then
						break
					else
						echo Invalid input
					fi
				done
			done
		done
	fi
	if [ ${INSTALL_GIT_REPOS} -ne 0 ]; then
		# Ask where to install the repos
		if [ $INSTALL_GIT_REPOS -eq 3 ]; then
			# If the only repo is picotool we don't need a
			if [ $INSTALLING_NON_PICOTOOL -eq 1 ]; then
				while [ 1 -eq 1 ]; do
					echo "Provide a directory to clone git repos or leave blank to use current directory"
					read USER_INPUT
					if [[ -d "${USER_INPUT}" ]]; then
						GIT_REPO_DESTINATION=USER_INPUT
						break
					elif [[ ${#USER_INPUT} -eq 0 ]]; then
						GIT_REPO_DESTINATION=$PWD
						break
					fi
				done
			fi
		else
			while [ 1 -eq 1 ]; do
				echo "Provide a directory to clone git repos or leave blank to use current directory"
				read USER_INPUT
				if [[ -d "${USER_INPUT}" ]]; then
					GIT_REPO_DESTINATION=$USER_INPUT
					break
				elif [[ ${#USER_INPUT} -eq 0 ]]; then
					GIT_REPO_DESTINATION=$PWD
					break
				fi
			done
		fi
	fi
else
	printf "\n${T_RED}WARNING - Git not installed so cannot install repos${T_NOCOLOR}\n"
fi

# Now begin installing

# Install apt packages
if [ $INSTALL_APT_PACKAGES -eq 1 ];
then
	printf "${T_BYELLOW} Installing packages with apt${T_NOCOLOR}\n"
	printf "${T_YELLOW} sudo apt update ${T_NOCOLOR}\n"
	sudo apt update
	printf "${T_YELLOW} sudo apt install ${MISSING_PACKAGES} ${T_NOCOLOR}\n"
	echo "I should sudo apt install ${MISSING_PACKAGES}"
fi

# Install git repos
if [ $INSTALL_GIT_REPOS -ne 0 ]; then
	GITHUB_PREFIX="https://github.com/raspberrypi/"
	GITHUB_SUFFIX=".git"
	SDK_BRANCH="master"
	if [ $INSTALL_GIT_REPOS -eq 1 ]; then 		# Install all
		GIT_REPO_LIST="${ESSENTIAL_REPOS} ${OPTIONAL_REPOS}"
	elif [ $INSTALL_GIT_REPOS -eq 2 ]; then 	# Install essential
		GIT_REPO_LIST="${ESSENTIAL_REPOS}"
	fi
	printf "${T_BYELLOW}Installing repos with git${T_NOCOLOR}\n"
	printf "${T_YELLOW}Changing directory to ${GIT_REPO_DESTINATION}${T_NOCOLOR}\n"
	cd "${GIT_REPO_DESTINATION}"
	for REPO in $GIT_REPO_LIST; do
		REPO_URL = "${GITHUB_PREFIX}${REPO}${GITHUB_SUFFIX}"
		if [ "${REPO}" = "pico-sdk" ]; then
			printf "${T_YELLOW}Cloning pico-sdk master branch${T_NOCOLOR}\n"
			git clone -b $SKD_BRANCH $REPO_URL
			printf "${T_RED}You may need to sudo nano ~/.bashrc to change export PICO_SDK_PATH location${T_NOCOLOR}\n"
			# Next line kinda shows the user if the variable already exists
			export -p | grep PICO_SDK_PATH
			printf "${T_YELLOW}Exporting PICO_SDK_PATH variable${T_NOCOLOR}\n"
			export PICO_SDK_PATH=${PWD}/pico-sdk
		elif [ "${REPO}" = "picotool" ]; then
			printf "${T_YELLOW}Cloning picotool${T_NOCOLOR}\n"
			# Need to move this to
		fi
		echo "git clone ${REPO}"
	done
fi
