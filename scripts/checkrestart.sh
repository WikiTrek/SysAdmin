#!/bin/bash
# Summary: Check system and services for need to restart
# Usage: sudo sh checkrestart.sh
# Author: Luca Mauri
# -------------------------------------------------

printf "\033[1;97mStart upgrade and remove\033[0m\n"
printf "\033[1;97m========================\033[0m\n"
sudo apt autoremove
sudo apt upgrade
echo

printf '\033[1;97mCheck if reboot is needed\033[0m\n'
printf '\033[1;97m=========================\033[0m\n'
if [ -f /var/run/reboot-required ]; then
  echo 'YES, reboot required'
else
  echo "NO, don't reboot"
fi
echo

printf '\033[1;97mList all services that specifically needs restart\033[0m\n'
printf '\033[1;97m=================================================\033[0m\n'
if [ -f /var/run/reboot-required.pkgs ]; then
  cat /var/run/reboot-required.pkgs
else
  echo "NO service needs restart"
fi

echo
printf '\033[1;97mDone\033[0m\n'
printf '\033[1;97m====\033[0m\n'