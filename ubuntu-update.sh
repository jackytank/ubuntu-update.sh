#!/bin/bash

# bash script to update Ubuntu Linux. Written on 16.04 LTS Server
# Written by Ted LeRoy with help from Google and the Linux community
# Follow or contribute on GitHub here:
# https://github.com/TedLeRoy/ubuntu-update.sh

# Defining Colors for text output if we are in a TTY
if [[ -t 1 ]]; then
    red=$( tput setaf 1 );
    yellow=$( tput setaf 3 );
    green=$( tput setaf 2 );
    normal=$( tput sgr 0 );
fi

# Defining Header
HEADER="
ubuntu-update.sh Copyright (C) 2018 Ted LeRoy

Easily update, upgrade, and clean up your Ubuntu system with this bash script.

This program comes with ABSOLUTELY NO WARRANTY see
https://github.com/TedLeRoy/ubuntu-update.sh/blob/master/LICENSE.md

This is free software, and you are welcome to redistribute it
under certain conditions.

See https://github.com/TedLeRoy/ubuntu-update.sh/blob/master/LICENSE.md
for details."

# Defining USAGE Variable to print usage for -h or undefined args

USAGE="
Usage: sudo bash ubuntu-update.sh [-ugdrh]
       No option - Run all options (recommended)
       -u Don't run apt-get update
       -g Don't run apt-get upgrade -y
       -d Don't run apt-get dist-upgrade -y
       -r Don't run apt-get auto-remove
       -h Display Usage and exit
"

# Evaluating Command Line args and setting case variables for later use

while getopts ":ugdrh" OPT; do
  case ${OPT} in
    u ) uOff=1
      ;;
    g ) gOff=1
      ;;
    d ) dOff=1
      ;;
    r ) rOff=1
      ;;
    h ) hOn=1
      ;;
    \?) noOpt=1
  esac
done

# Checking whether script is being run as root

if [[ ${UID} != 0 ]]; then
    echo "${red}
    This script must be run as root or with sudo permissions.
    Please run using sudo.${normal}
    "
    exit 1
fi

# Executing based on option selection

if [[ -n $hOn || $noOpt ]]; then
    echo "${red}$USAGE${normal}"
    exit 2
fi

# Display HEADER

echo "${red}$HEADER${normal}"

if [[ ! -n $uOff ]]; then
    echo -e "
${green}#############################
#     Updating Data Base    #
#############################${normal}
"
apt-get update | tee /tmp/update-output.txt
fi

if [[ ! -n $gOff ]]; then
    echo -e "
${green}##############################
# Upgrading Operating System #
##############################${normal}
"
apt-get upgrade -y | tee -a /tmp/update-output.txt
fi

if [[ ! -n $dOff ]]; then
    echo -e "
${green}#############################
#   Starting Full Upgrade   #
#############################${normal}
"
apt-get dist-upgrade -y | tee -a /tmp/update-output.txt
echo -e "
${green}#############################
#   Full Upgrade Complete   #
#############################${normal}
"
fi

if [[ ! -n $rOff ]]; then
    echo -e "
${green}#############################
#    Starting Apt Clean     #
#############################${normal}
"
apt-get clean | tee -a /tmp/update-output.txt
echo -e "
${green}#############################
#     Apt Clean Complete    #
#############################${normal}
"
fi

# Check for existence of update-output.txt and exit if not there.

if [ -f "/tmp/update-output.txt"  ]

then

# Search for issues user may want to see and display them at end of run.

  echo -e "
${green}#####################################################
#   Checking for actionable messages from install   #
#####################################################${normal}
"
  egrep -wi --color=auto 'warning|error|critical|reboot|restart|autoclean|autoremove' /tmp/update-output.txt | uniq
  echo -e "
${green}#############################
#    Cleaning temp files    #
#############################${normal}
"

  rm /tmp/update-output.txt
  echo -e "
${green}#############################
#     Done with upgrade     #
#############################${normal}
"

exit 0

else

# Exit with message if update-output.txt file is not there.

  echo -e "
${green}#########################################################
# No items to check given your chosen options. Exiting. #
#########################################################${normal}
"

fi

exit 0
