
ARG DEBIAN_VERSION=buster-slim

FROM debian:${DEBIAN_VERSION}


# the following is from https://github.com/qdm12/basedevcontainer/blob/master/debian.Dockerfile
# CA certificates
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -r /var/cache/* /var/lib/apt/lists/*

# https://www.nongnu.org/chktex/ = Lint for LaTeX
# the following is from https://github.com/qdm12/latexdevcontainer/blob/master/Dockerfile
ARG CHKTEX_VERSION=1.7.6
WORKDIR /tmp/workdir
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends g++ make wget
RUN wget -qO- http://download.savannah.gnu.org/releases/chktex/chktex-${CHKTEX_VERSION}.tar.gz | \
    tar -xz --strip-components=1
RUN ./configure && \
    make && \
    mv chktex /tmp && \
    rm -r *

WORKDIR /tmp/texlive

ARG TEXLIVE_VERSION=2021
ARG TEXLIVE_MIRROR=http://ctan.math.utah.edu/ctan/tex-archive/systems/texlive/tlnet
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget gnupg cpanminus && \
    wget -qO- ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz | \
    tar -xz --strip-components=1 && \
    export TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1 && \
    export TEXLIVE_INSTALL_NO_WELCOME=1 && \
    cd && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/texlive /usr/local/texlive/${TEXLIVE_VERSION}/*.log


