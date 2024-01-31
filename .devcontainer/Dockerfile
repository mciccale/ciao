FROM mcr.microsoft.com/devcontainers/base:jammy

USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        imagemagick \
        emacs-nox \
        texlive-latex-base \
        texlive-binaries \
        ghostscript && \
    apt-get clean

# Adjust ImageMagick policy
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

# Set user and working directory
USER vscode
WORKDIR /workspaces/ciao
