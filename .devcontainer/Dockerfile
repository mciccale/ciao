FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        curl \
        rlwrap \
        emacs-nox && \
    apt-get clean

# Set user and working directory
USER vscode
WORKDIR /home/vscode

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin local-install
