#!/usr/bin/env bash

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value
set -o xtrace    # set -x : show commands as the script executes

echo "use:"
echo "$0 pdf; $0 epub_pandoc; $0 html_pandoc"
echo "or"
echo "$0 all"

function pdf {
  pwd
  sed -i '' "s/haspagenumbersfalse/haspagenumberstrue/" latex/main.tex
  sed -i '' "s/glossarysubstitutionworksfalse/glossarysubstitutionworkstrue/" latex/main.tex
  cp latex/main.tex latex/main_EDITED_BY_SED_BY_MAKEFILE.tex
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main > log1.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main         > log2.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main                 > log3.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main > log4.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main > log5.log
    cd ..
  sed -i '' "s/haspagenumberstrue/haspagenumbersfalse/" latex/main.tex
  sed -i '' "s/glossarysubstitutionworkstrue/glossarysubstitutionworksfalse/" latex/main.tex
  mv -f latex/main.pdf bin/bureaucracy.pdf
}

function epub_pandoc {
  cd latex;
    docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pandoc main.tex -f latex \
	       --epub-metadata=metadata_epub.xml \
	       --citeproc \
		--bibliography=biblio_bureaucracy.bib \
		--table-of-contents \
		--number-sections \
		--epub-cover-image=images/bureaucrat_empathizing_with_coworkers_in_office_breakroom.png \
		--gladtex \
		-t epub3 \
		-o main.epub
    cd ..
  mv -f latex/main.epub bin/bureaucracy.epub
  postprocess_epub
}

# --ascii = 	Use only ASCII characters in output.
function html_pandoc {
  cd latex; \
    docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pandoc main.tex -f latex \
		-t html --standalone \
		-o main.html \
		--metadata-file metadata_pandoc.yml \
		--citeproc \
		--table-of-contents \
		--ascii \
		--toc-depth 2 \
		--number-sections \
		--mathjax \
		--bibliography=biblio_bureaucracy.bib
    cd ..
  postprocess_html
}


function postprocess_epub {
  pwd
  rm -rf TEMPORARY_EPUB
  mkdir TEMPORARY_EPUB
  cd TEMPORARY_EPUB/

  cp ../bin/bureaucracy.epub .

  unzip bureaucracy.epub
  rm bureaucracy.epub

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
  zip bureaucracy.epub -r *
  pwd
  mv -f bureaucracy.epub ../bin/bureaucracy.epub
  cd ..
}

function postprocess_html {
  # replace PDF with PNG for images
  sed -i '' 's/\("images\/.*\)pdf"/\1png"/' latex/main.html

  # instead of embedded images, just point to the PNG as an IMG
  sed -i '' 's/<embed/<img/' latex/main.html

  # replace tilted quote with straight quote
  #sed -i '' "s/’/'/g" main.html
  #sed -i '' 's/“/"/g' main.html

  # single quote
  sed -i '' "s/&#x2018;/'/g" latex/main.html
  sed -i '' "s/&#x2019;/'/g" latex/main.html

  # CAVEAT: ampersand needs to be escaped in the output because it means "match" for sed
  # space
  sed -i '' "s/&#xA0;/\&nbsp;/g" latex/main.html

  # double quote
  sed -i '' 's/&#x201D;/"/g' latex/main.html
  sed -i '' 's/&#x201C;/"/g' latex/main.html

  # copyright symbol
  #sed -i '' 's/&#xA9;/\(C\)/g' latex/main.html

  # em dash
  sed -i '' 's/&#x2013;/--/g' latex/main.html

  # footnote return indicator
  sed -i '' 's/&#x21A9;&#xFE0E;/\&nbsp;return to text/g' latex/main.html

  # fix hyperlinked chapter numbers
  # CAVEAT: this is a fragile fix since the chapter numbers are hard-coded.
  sed -i '' 's/>\[sec:introduction\]</>1</' latex/main.html
  sed -i '' 's/>\[sec:why-bur-hard\]</>4</' latex/main.html
  sed -i '' 's/>\[sec:individual-in-org\]</>5</' latex/main.html
  sed -i '' 's/>\[sec:process\]</>8</' latex/main.html
  sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' latex/main.html

}

function all {
  pdf
  html_pandoc
  epub_pandoc
}

# from https://www.baeldung.com/linux/run-function-in-script
# dollarsign variables in bash: https://stackoverflow.com/a/5163260/1164295
case "$1" in
    "") ;;
    all) "$@"; exit;;
    pdf) "$@"; exit;;
    epub_pandoc) "$@"; exit;;
    html_pandoc) "$@"; exit;;
    *) echo "Unkown function: $1()"; exit 2;;
esac
