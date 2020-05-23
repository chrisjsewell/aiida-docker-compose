#!/bin/bash

# This script is executed whenever the docker container is (re)started.

# Debugging.
set -x

# Environment.
export SHELL=/bin/bash

# set the timezone
# echo ${CONTAINER_TIMEZONE} > /etc/timezone
# echo "Container timezone set to: $CONTAINER_TIMEZONE"
# TODO this fixes:
# /usr/local/lib/python3.6/dist-packages/tzlocal/unix.py:158: UserWarning: Can not find any timezone configuration, defaulting to UTC.
# but then causes:
# ValueError: Timezone offset does not match system offset: 7200 != 0. Please, check your config files.
# potential fix https://medium.com/developer-space/be-careful-while-playing-docker-about-timezone-configuration-e7a2217e9b76

# Update the list of installed aiida plugins.
# reentry scan

# TODO this is a horrible hack, to account for the fact that
# (a) aiida-core currently hard-codes the hostname (this should be the fix)
# (b) I haven't yet found an obvious way to map the rmq containers port to the localhost of this container
echo $RMQHOST
sed -i "s/amqp:\/\/127.0.0.1/amqp:\/\/${RMQHOST}/g" ${AIIDA_PKG}/manage/external/rmq.py

# TODO potentially wait until database, rabbitmq ready
# e.g. using netstat -an | grep 5672 > /dev/null; if [ 0 != $? ]; then echo 1; fi;
# or nc -vz database 5432 | grep open and nc -vz messaging 5672 | grep open