
FROM phusion/baseimage:0.11 AS compile-image

ENV DEBIAN_FRONTEND=noninteractive

# ARG PYTHON_VERSION="3.7"
# TODO requires https://stackoverflow.com/a/57642085/5033292
# then could use python${PYTHON_VERSION}

ARG DOCKER_TAG="1.2.1"

RUN /sbin/install_clean \
    python3 \
    python3-dev \
    python3-pip \
    python3-distutils \
    python3-venv \
    git \
    build-essential \
    gcc

# build in virtual env
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 install -U setuptools wheel
COPY requirements.${REQUIREMENTS}.txt .
RUN pip3 install -r requirements.${REQUIREMENTS}.txt

FROM phusion/baseimage:0.11 AS build-image
# Ubuntu 18.04 LTS image that correctly manages daemon processes
# see: https://github.com/phusion/baseimage-docker
LABEL maintainer="AiiDA Team"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Fix locales.
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
# without this tzlocal complains
ENV TZ Europe/Zurich

RUN /sbin/install_clean \
    vim \
    ssh \
    locales \
    bzip2 \
    zip \
    unzip \
    graphviz \
    netcat \
    python3-distutils
# even though all the python binaries are in venv folder
# distuils is still searched for in root folder /usr!

# add user (no password) and setup owned folders
ARG NB_USER="aiida"
RUN useradd -m -s /bin/bash ${NB_USER}
RUN mkdir -p /home/${NB_USER}/ && \
    mkdir -p /home/${NB_USER}/.aiida && \
    chown ${NB_USER}:${NB_USER} /home/${NB_USER}/ && \
    chown ${NB_USER}:${NB_USER} /home/${NB_USER}/.aiida && \
    echo 'eval "$(_VERDI_COMPLETE=source verdi)"' >> /home/${NB_USER}/.bashrc

# copy python files
COPY --from=compile-image --chown=aiida:aiida /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV AIIDA_PKG="/opt/venv/lib/python3.6/site-packages/aiida"

# copy default aiida configuration files
COPY --chown=aiida:aiida aiida-configs /home/${NB_USER}/aiida-configs

USER ${NB_USER}
WORKDIR "/home/${NB_USER}/"
RUN reentry scan

# make aiida configuration and object store persistent
VOLUME [ "/home/${NB_USER}/.aiida" ]

USER root
COPY startup.sh /etc/my_init.d/40_startup.sh
