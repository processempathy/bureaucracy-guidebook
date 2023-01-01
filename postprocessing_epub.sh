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

cd EPUB/media
for f in *.pdf; do
    filename=`echo $f | cut -d'.' -f1`;
    echo $filename;
    #pdf2svg $f ${filename}.svg;
    docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdf2svg $f ${filename}.svg;
done
rm -rf *.pdf


cd ../text/
# replace <embed src="../media/file11.pdf"
# with    <img src="../media/file11.svg"
for f in *.xhtml; do
    # instead of embedded images, just point to the PNG as an IMG
    sed -i '' 's/<embed/<img/' $f

    # replace PDF with PNG for images
    sed -i '' 's/\("media\/.*\)pdf"/\1svg"/' $f
done
cd ..
sed -i '' 's/<embed/<img/' nav.xhtml
sed -i '' 's/\("media\/.*\)pdf"/\1svg"/' nav.xhtml

zip new_main.epub -r *

# EOF
