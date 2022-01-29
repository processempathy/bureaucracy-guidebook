# Source: http://github.com/thomasWeise/docker-texlive-full/
# specifically https://github.com/thomasWeise/docker-texlive-full/blob/master/image/Dockerfile

# License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
# The license applies to the way the image is built, while the
# software components inside the image are under the respective
# licenses chosen by their respective copyright holders.

ARG DEBIAN_VERSION=buster-slim

FROM debian:${DEBIAN_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Initial update." &&\
    apt-get update &&\
# prevent doc and man pages from being installed
# the idea is based on https://askubuntu.com/questions/129566
    echo "Preventing doc and man pages from being installed." &&\
    printf 'path-exclude /usr/share/doc/*\npath-include /usr/share/doc/*/copyright\npath-exclude /usr/share/man/*\npath-exclude /usr/share/groff/*\npath-exclude /usr/share/info/*\npath-exclude /usr/share/lintian/*\npath-exclude /usr/share/linda/*\npath-exclude=/usr/share/locale/*' > /etc/dpkg/dpkg.cfg.d/01_nodoc 
# install utilities
RUN echo "Installing utilities." &&\
    apt-get install -f -y --no-install-recommends apt-utils &&\
# get and update certificates, to hopefully resolve mscorefonts error
    echo "Get and update certificates for mscorefonts." &&\
    apt-get install -f -y --no-install-recommends ca-certificates &&\
    update-ca-certificates 
# install some utilitites and nice fonts, e.g., for Chinese and others
RUN apt-get install -f -y --no-install-recommends \
          curl \
          wget \
          fontconfig \ 
# install TeX Live and ghostscript as well as other tools
          dvipng \
          ghostscript \
          gnuplot \
          make \
          latexmk \
          poppler-utils \
          psutils \
          tex4ht \
          texlive-base \
          texlive-bibtex-extra \
          #texlive-binaries \
          #texlive-extra-utils \
          #texlive-font-utils \
          #texlive-fonts-extra \
          #texlive-fonts-extra-links \
          #texlive-fonts-recommended \
          #texlive-formats-extra \
          #texlive-lang-all \
          texlive-latex-base \
          texlive-latex-extra \
          texlive-latex-recommended \
          #texlive-luatex \
          #texlive-metapost \
          #texlive-pictures \
          #texlive-plain-generic \
          #texlive-pstricks \
          #texlive-publishers \
          #texlive-science \
          #texlive-xetex \
          texlive-bibtex-extra &&\
# delete Tex Live sources and other potentially useless stuff
    echo "Delete TeX Live sources and other useless stuff." &&\
    (rm -rf /usr/share/texmf/source || true) &&\
    (rm -rf /usr/share/texlive/texmf-dist/source || true) &&\
    find /usr/share/texlive -type f -name "readme*.*" -delete &&\
    find /usr/share/texlive -type f -name "README*.*" -delete &&\
    (rm -rf /usr/share/texlive/release-texlive.txt || true) &&\
    (rm -rf /usr/share/texlive/doc.html || true) &&\
    (rm -rf /usr/share/texlive/index.html || true) &&\
# update font cache
    echo "Update font cache." &&\
    fc-cache -fv &&\
# clean up all temporary files
    echo "Clean up all temporary files." &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /etc/ssh/ssh_host_* &&\
# delete man pages and documentation
    echo "Delete man pages and documentation." &&\
    rm -rf /usr/share/man &&\
    mkdir -p /usr/share/man &&\
    find /usr/share/doc -depth -type f ! -name copyright -delete &&\
    find /usr/share/doc -type f -name "*.pdf" -delete &&\
    find /usr/share/doc -type f -name "*.gz" -delete &&\
    find /usr/share/doc -type f -name "*.tex" -delete &&\
    (find /usr/share/doc -type d -empty -delete || true) &&\
    mkdir -p /usr/share/doc &&\
    rm -rf /var/cache/apt/archives &&\
    mkdir -p /var/cache/apt/archives &&\
    rm -rf /tmp/* /var/tmp/* &&\
    (find /usr/share/ -type f -empty -delete || true) &&\
    (find /usr/share/ -type d -empty -delete || true) &&\
    mkdir -p /usr/share/texmf/source &&\
    mkdir -p /usr/share/texlive/texmf-dist/source &&\
    echo "All done."


# as per https://askubuntu.com/a/687676
# https://github.com/jgm/pandoc/releases/
ARG PANDOC_VER=2.17.0.1
RUN wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-1-amd64.deb
RUN dpkg -i pandoc-${PANDOC_VER}-1-amd64.deb

WORKDIR /scratch/
