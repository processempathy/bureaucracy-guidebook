#!/usr/bin/env bash

# PANDOC does a great job converting LATEX to EPUB.
# This file provides a few tweaks to the EPUB to make
# the document look even better.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

rm -rf TEMPORARY_EPUB
mkdir TEMPORARY_EPUB
cd TEMPORARY_EPUB/

cp ../latex/main.epub .

unzip main.epub
rm main.epub


# EOF
