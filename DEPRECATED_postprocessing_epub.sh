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

cp ../bin/main.epub .

unzip main.epub
rm main.epub

cd EPUB

mv content.opf content.opf_ORIGINAL
head -n 4 content.opf_ORIGINAL > content.opf
cat << EOF >> content.opf
<dc:title id="t1">Process Empathy: A Field Guide for Effective Bureaucrats</dc:title>
<meta refines="#t1" property="title-type">main</meta>
<dc:title id="t2">First Edition</dc:title>
<meta refines="#t2" property="title-type">edition</meta>
EOF
tail -n +8 content.opf_ORIGINAL >> content.opf

cd media
for f in *.pdf; do
    filename=`echo $f | cut -d'.' -f1`;
    echo $filename;
    #pdf2svg $f ${filename}.svg;
    #docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdf2svg $f ${filename}.svg;
    docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdftoppm $f ${filename}.png -png;
    mv "${filename}.png-1.png" "${filename}.png"
done
rm -rf *.pdf


cd ../text/
# replace <embed src="../media/file11.pdf"
# with    <img src="../media/file11.svg"
for f in *.xhtml; do
    # instead of embedded images, just point to the PNG as an IMG
    sed -i '' 's/<embed/<img/' $f

    # replace PDF with PNG for images
    sed -i '' 's/\(media\/.*\)pdf"/\1png"/' $f
done
cd ..
sed -i '' 's/<embed/<img/' nav.xhtml
sed -i '' 's/\(media\/.*\)pdf"/\1png"/' nav.xhtml

sed -i '' 's/Effective Bureaucrats image/Effective Bureaucrats/g' nav.xhtml
sed -i '' 's/\.\.\/media/media/g' nav.xhtml

cd ..
zip new_main.epub -r *

# EOF
