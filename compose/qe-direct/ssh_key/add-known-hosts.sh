#!/usr/bin/env sh

mkdir -p "/home/${1:-aiida}/.ssh"

touch "/home/${1:-aiida}/.ssh/known_hosts"
chmod 666 "/home/${1:-aiida}/.ssh/known_hosts"
for hostname in $(echo $KNOWN_HOSTNAMES | sed "s/,/ /g")
do
  echo "adding known_host $hostname"
  ssh-keygen -R $hostname
  ssh-keyscan -H $hostname >> "/home/${1:-aiida}/.ssh/known_hosts"
done
