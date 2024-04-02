FROM ubuntu:jammy

USER root

RUN apt-get update && \
    apt-get install -y \
        git \
        sudo \
        curl \
        rlwrap \
        emacs-nox \
        bash-completion && \
    apt-get clean

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
USER gitpod
WORKDIR /home/gitpod

SHELL ["/bin/bash", "-c"]

RUN curl https://ciao-lang.org/boot -sSfL | sh -s -- --prebuilt-bin local-install

ENV PATH="/home/gitpod/.ciaoroot/v1.23.0-m1/build/bin:${PATH}"
