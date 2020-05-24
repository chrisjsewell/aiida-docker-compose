FROM ubuntu:18.04 AS compile-image
LABEL maintainer="AiiDA Team"

ARG QE_GIT_TAG="qe-6.5"
ARG QE_MAKE="pwall"

ENV LANG=C.UTF-8

# removes all floating-point exceptions
# see https://github.com/marvel-nccr/quantum-mobile/issues/52
ENV FFLAGS="-O3 -g -ffpe-summary=none"

RUN apt-get update && apt-get install -y \
      build-essential \
      wget \
      gfortran \
      openmpi-bin \
      libopenmpi-dev \
      libfftw3-dev \
      libfftw3-mpi-dev \
      liblapack-dev \
      libblas-dev

RUN wget https://gitlab.com/QEF/q-e/-/archive/${QE_GIT_TAG}/q-e-${QE_GIT_TAG}.tar.bz2 -O - | tar -xj
RUN cd q-e-${QE_GIT_TAG} && ./configure && make ${QE_MAKE} && make install && make clean

RUN mkdir /tmp/libs && \
    mkdir /tmp/bin && \
    ldd /usr/local/bin/*.x | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' /tmp/libs/ && \
    cp /usr/local/bin/*.x /tmp/bin/


FROM ubuntu:18.04 AS build-image
LABEL maintainer="AiiDA Team"

RUN apt-get update && apt-get install -y \
    openmpi-bin \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=compile-image /tmp/bin /usr/local/bin
COPY --from=compile-image /tmp/libs /usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib
# fix https://github.com/open-mpi/ompi/issues/4948
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none

# set user profile
ARG NB_USER="qeuser"
RUN useradd -m -s /bin/bash ${NB_USER}
RUN mkdir -p /home/${NB_USER}/ && \
    chown ${NB_USER}:${NB_USER} /home/${NB_USER}
USER ${NB_USER}
WORKDIR "/home/${NB_USER}/"

COPY --chown=qeuser:qeuser examples examples

# allow ssh connections
EXPOSE 22
