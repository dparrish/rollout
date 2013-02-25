#!/bin/bash

# A very crude install script

echo -e "rollout host? : \c"
read rollout
if [[ -z $rollout ]]
then
  echo -e "exiting"
  exit 100
fi

echo -e "What are the space separated DNS search domains? : \c"
read search
if [[ -z $search ]]
then
  echo -e "exiting"
  exit 101
fi

resolvConf="nameserver $rollout
search $search"

# we currently make assumptions as to the repo layout.
#
aptConf="deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise main
deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates main
deb http://$rollout/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security main
deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise universe
deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates universe
deb http://$rollout/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security universe
deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise multiverse
deb http://$rollout/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb http://$rollout/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security multiverse"

echo -e "$resolvConf" > /etc/resolv.conf
echo -e "$aptConf" > /etc/apt/sources.list

sudo apt-get update
sudo apt-get -y install libwww-perl libio-socket-ssl-perl liberror-perl &&
wget -O- http://$rollout/rollout/rollout | sudo perl - -u http://$rollout/rollout -o setup

echo -e "Run rollout and apply configuration? <y | n> [n] :\c"
read answer
answer=$(echo $answer | tr [[:upper:]] [[:lower:]])
if [[ -z $answer || $answer != ${answer%%[^y]*} ]]
then
  answer="-s"
fi

sudo rollout --no_step_labels -o network -f network $answer
sudo rollout --no_step_labels -k motd $answer
