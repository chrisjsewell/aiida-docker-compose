#!/bin/bash

# This script is executed whenever the docker container is (re)started.

# Debugging.
set -x

# Environment.
export SHELL=/bin/bash

# Update the list of installed aiida plugins.
# reentry scan

# TODO this is a horrible hack, to account for the fact that
# (a) aiida-core currently hard-codes the hostname (this should be the fix)
# (b) I haven't yet found an obvious way to map the rmq containers port to the localhost of this container
echo $RMQHOST
sed -i "s/amqp:\/\/127.0.0.1/amqp:\/\/${RMQHOST}/g" ${AIIDA_PKG}/manage/external/rmq.py
