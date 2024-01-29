FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

RUN apt-get update && \
    apt-get install sudo curl git xdg-utils build-essential rlwrap emacs -y && \
    apt-get clean

USER vscode
WORKDIR /home/vscode

RUN /workspaces/ciao/ciao-boot.sh configure && \
    /workspaces/ciao/ciao-boot.sh build && \
    /workspaces/ciao/ciao-boot.sh install

RUN ciao get ciaopp && ciao get lpdoc