FROM mcr.microsoft.com/devcontainers/base:jammy

USER vscode
WORKDIR /home/vscode

# Install dependencies for Ubuntu Jammy
RUN apt-get update && \
    apt-get install -y xdg-utils

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin local-install