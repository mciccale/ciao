FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

RUN apt-get update && \
    apt-get install sudo curl git xdg-utils build-essential rlwrap emacs -y && \
    apt-get clean

USER vscode
WORKDIR /home/vscode

RUN ./ciao-boot.sh configure && \
    ./ciao-boot.sh build && \
    ./ciao-boot.sh install

RUN ciao get ciaopp && ciao get lpdoc