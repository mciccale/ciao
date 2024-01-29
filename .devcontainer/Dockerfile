FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

RUN apt-get update && \
    apt-get install sudo curl git xdg-utils build-essential rlwrap emacs -y && \
    apt-get clean

USER vscode
WORKDIR /home/vscode

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin get devenv