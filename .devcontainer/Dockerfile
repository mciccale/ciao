FROM mcr.microsoft.com/devcontainers/base:jammy

USER vscode
WORKDIR /home/vscode

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin local-install

ENV PATH="/home/vscode/.ciaoroot/v1.22.0-m7/build/bin:${PATH}"