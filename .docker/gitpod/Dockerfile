FROM gitpod/workspace-full

USER root

RUN apt-get update && \
    apt-get install sudo curl git xdg-utils build-essential rlwrap -y && \
    apt-get clean

USER gitpod
WORKDIR /home/gitpod

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin local-install
