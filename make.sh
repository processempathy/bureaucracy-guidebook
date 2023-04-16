#!/usr/bin/env bash

# This script produces multiple formats of the same content.
# Latex source code in the latex/ folder is used to create
# * PDF for printing a paper book
# * PDF for electronic format
# * EPUB
# * HTML
# The conversion process uses Latex commands and pandoc,
# both of which are in a container

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value
set -o xtrace    # set -x : show commands as the script executes

echo "use:"
echo "$0 pdf_not_bound; $0 pdf_for_binding; $0 epub_pandoc; $0 html_pandoc; $0 html_latex2html"
echo "or"
echo "/usr/bin/time $0 all"


# from https://stackoverflow.com/a/48843074/1164295
if (! docker stats --no-stream ); then
  # On Mac OS this would be the terminal command to launch Docker
  open /Applications/Docker.app
 #Wait until Docker daemon is running and has completed initialisation
while (! docker stats --no-stream ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  sleep 1
done
fi


function pdf_not_bound {
  pwd
  tex_file="latex/main_pdf_not_bound.tex"
  cp latex/main.tex ${tex_file}
  sed -i '' "s/boundbooktrue/boundbookfalse/" ${tex_file}
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" ${tex_file}
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" ${tex_file}
  sed -i '' "s/togglefalse{showbacktotoc}/toggletrue{showbacktotoc}/" ${tex_file}
  sed -i '' "s/toggletrue{glossaryinmargin}/togglefalse{glossaryinmargin}/" ${tex_file}
  sed -i '' "s/toggletrue{boundbook}/togglefalse{boundbook}/" ${tex_file}
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log1_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_pdf_not_bound         > log2_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_pdf_not_bound                 > log3_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log4_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log5_pdf_not_bound.log
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f latex/main_pdf_not_bound.pdf bin/bureaucracy_not_bound.pdf

  mv ${tex_file} ${tex_file}.log
}

function pdf_for_binding {
  pwd
  tex_file="latex/main_for_binding.tex"
  cp latex/main.tex ${tex_file}
  # book is going to be bound; set boolean to true
  sed -i '' "s/boundbookfalse/boundbooktrue/" ${tex_file}
  # toggle variable for same purpose
  sed -i '' "s/togglefalse{boundbook}/toggletrue{boundbook}/" ${tex_file}
  # book has page numbers; set toggle to true
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" ${tex_file}
  sed -i '' "s/toggletrue{glossaryinmargin}/togglefalse{glossaryinmargin}/" ${tex_file}
  # because this uses pdflatex, glossary substitution works; set toggle to true
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" ${tex_file}
  # books don't need hyperlinks to the toc; set toggle to false
  sed -i '' "s/toggletrue{showbacktotoc}/togglefalse{showbacktotoc}/" ${tex_file}
  # book is black-and-white; don't use blue for hyperlink
  sed -i '' "s/colorlinks=true,/colorlinks=false,/" ${tex_file}
  # when colorlinks=false, hyperref package uses rectangles around tex. Disable those
  sed -i '' "s/usepackage\[pagebackref\]{hyperref}/usepackage[pagebackref,hidelinks]{hyperref}/" ${tex_file}
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log1_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_for_binding         > log2_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_for_binding                 > log3_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log4_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log_for_binding5.log
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f latex/main_for_binding.pdf bin/bureaucracy_for_binding.pdf

  mv ${tex_file} ${tex_file}.log

  pwd
  cd bin/
    # https://stackoverflow.com/a/22796608/1164295
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian gs   -sDEVICE=pdfwrite   -dProcessColorModel=/DeviceGray   -dColorConversionStrategy=/Gray   -dPDFUseOldCMS=false   -dNOPAUSE -dBATCH -q   -o bureaucracy_for_binding_grayscale.pdf -f bureaucracy_for_binding.pdf
  cd ..
  pwd

}

function pandoc_preprocess {

  # Pandoc can't handle "toggle" being used in files other than the file where the toggle was defined,
  # so merge all \input{}  so that all content is in one file, as per
  # https://tex.stackexchange.com/a/21840/235813
  #cd latex
  #time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latexpand --keep-comments --output main_merged.tex --fatal main.tex
  #cd ..
  #cp latex/main_merged.tex latex/main_html_pandoc.tex

  FOLDER_NAME=${1}
  TEX_NAME=${2}

  TEX_FILE_PATH=${FOLDER_NAME}/${TEX_NAME}

  rm -rf ${FOLDER_NAME}
  mkdir ${FOLDER_NAME}
  cp -r latex/* ${FOLDER_NAME}
  rm -rf ${FOLDER_NAME}/main_*
  mv ${FOLDER_NAME}/main.tex ${TEX_FILE_PATH}

  # DEPRECATED -- fancy and fragile
  # python3 evaluate_boolean_toggles.py ${tex_file}
  for f in ${FOLDER_NAME}/*.tex; do
      # haspagenumbers == true
      #cat $f | grep "iftoggle" | sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\1/'
      # haspagenumbers == false
      sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\2/g' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{glossarysubstitutionworks}{(.*)}{(.*)}/\2/g' $f
      # showminitoc == true
      sed -i '' -E 's/\\iftoggle{showminitoc}{(.*)}{(.*)}/\1/g' $f
      # showbacktotoc == true
      sed -i '' -E 's/\\iftoggle{showbacktotoc}{(.*)}{(.*)}/\1/g' $f
      # Wikipedia in margin == false
      sed -i '' -E 's/\\iftoggle{WPinmargin}{(.*)}{(.*)}/\2/g' $f
      # clearpage after each section == false
      sed -i '' -E 's/\\iftoggle{cpforsection}{(.*)}{(.*)}/\2/g' $f
      # show glossary in margin == false
      sed -i '' -E 's/\\iftoggle{glossaryinmargin}{\\marginpar{\[Glossary\]}}{}//g' $f
      # boundbook == false
      sed -i '' -E 's/\\iftoggle{boundbook}{(.*)}{(.*)}/\2/g' $f
      # pandoc doesn't like textsuperscript; https://pandoc.org/MANUAL.html#superscripts-and-subscripts and https://github.com/jgm/pandoc-citeproc/issues/128
      sed -i '' -E 's/\\textsuperscript{(.*)}/\1/g' $f
      #sed -i '' -E 's/\\textsuperscript//g' $f
#      sed -i '' -E 's/\\textsuperscrip//' $f
#      sed -i '' -E 's/{,}//g' $f
  done


  # The version of Pandoc I'm using doesn't understand \newif
  # https://github.com/jgm/pandoc/issues/6096
  sed -i '' "/documentclass\[oneside\]{book}/d" ${TEX_FILE_PATH}
  sed -i '' "/\\usepackage.*{geometry}/d" ${TEX_FILE_PATH}

  sed -i '' "/\\newif/d" ${TEX_FILE_PATH}
  sed -i '' "/\\else/d" ${TEX_FILE_PATH}
  sed -i '' "/\\fi/d" ${TEX_FILE_PATH}
  sed -i '' "/\\boundbook/d" ${TEX_FILE_PATH}
  sed -i '' "/\\ifboundbook/d" ${TEX_FILE_PATH}

  #sed -i '' "s/haspagenumberstrue/haspagenumbersfalse/" ${tex_file}
  #sed -i '' "s/glossarysubstitutionworkstrue/glossarysubstitutionworksfalse/" ${tex_file}

}

function epub_pandoc {
  pwd

  pandoc_preprocess TEMPORARY_epub_source_html_source_latex main_epub_pandoc.tex

  cd TEMPORARY_epub_source_html_source_latex;
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pandoc main_epub_pandoc.tex -f latex \
	       --epub-metadata=metadata_epub.xml \
	       --citeproc \
		--bibliography=biblio_bureaucracy.bib \
		--table-of-contents \
		--number-sections \
		--epub-cover-image=images/bureaucrat_empathizing_with_coworkers_in_office_breakroom.png \
		--gladtex \
		-t epub3 \
		-o main_epub_pandoc.epub
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f TEMPORARY_epub_source_html_source_latex/main_epub_pandoc.epub bin/bureaucracy.epub
  postprocess_epub
}

# --ascii = 	Use only ASCII characters in output.
function html_pandoc {
  pwd

  pandoc_preprocess TEMPORARY_html_pandoc_source_latex main_html_pandoc.tex

  cd TEMPORARY_html_pandoc_source_latex; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pandoc main_html_pandoc.tex -f latex \
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
    pwd
    cd ..
  pwd
  postprocess_html
}

function html_latex2html {

  rm -rf TEMPORARY_html_latex2html_source_latex
  mkdir TEMPORARY_html_latex2html_source_latex
  cp -r latex/* TEMPORARY_html_latex2html_source_latex/
  rm -rf TEMPORARY_html_latex2html_source_latex/main_*
  mv TEMPORARY_html_latex2html_source_latex/main.tex TEMPORARY_html_latex2html_source_latex/main_html_latex2html.tex

  for f in TEMPORARY_html_latex2html_source_latex/*.tex; do
      # haspagenumbers == true
      #cat $f | grep "iftoggle" | sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\1/'
      # haspagenumbers == false
      sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\2/' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{glossarysubstitutionworks}{(.*)}{(.*)}/\2/' $f
      # showminitoc == true
      sed -i '' -E 's/\\iftoggle{showminitoc}{(.*)}{(.*)}/\1/' $f
      # showbacktotoc == true
      sed -i '' -E 's/\\iftoggle{showbacktotoc}{(.*)}{(.*)}/\1/' $f
  done

  #sed -i '' "s/toggletrue{haspagenumbers}/togglefalse{haspagenumbers}/" latex/main_html_latex2html.tex
  #sed -i '' "s/toggletrue{glossarysubstitutionworks}/togglefalse{glossarysubstitutionworks}/" latex/main_html_latex2html.tex

  pwd
	cd TEMPORARY_html_latex2html_source_latex
    # Need to get glossary and bibliography before generating HTML
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_html_latex2html > log1_latex2html.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_html_latex2html         > log2_latex2html.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_html_latex2html                 > log3_latex2html.log; \

    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latex2html main_html_latex2html \
		-index_in_navigation \
		-contents_in_navigation \
		-next_page_in_navigation \
		-previous_page_in_navigation \
		-show_section_numbers \
		-split 2 \
		-verbosity 2 \
		-html_version "5.0"
  cd ..
  pwd
}

function postprocess_epub {
  pwd
  rm -rf TEMPORARY_epub_source_html
  mkdir TEMPORARY_epub_source_html
  cd TEMPORARY_epub_source_html/

  pwd
  cp ../bin/bureaucracy.epub .

  unzip bureaucracy.epub
  rm bureaucracy.epub

  cd EPUB
  pwd

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
      time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdftoppm $f ${filename}.png -png;
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

      sed -i '' 's/>\[sec:introduction\]</>1</' $f
      sed -i '' 's/>\[sec:why-bur-hard\]</>4</' $f
      sed -i '' 's/>\[sec:individual-in-org\]</>5</' $f
      sed -i '' 's/>\[sec:process\]</>8</' $f
      sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' $f

  done
  pwd
  cd ..
  pwd
  sed -i '' 's/<embed/<img/' nav.xhtml
  sed -i '' 's/\(media\/.*\)pdf"/\1png"/' nav.xhtml

  sed -i '' 's/Effective Bureaucrats image/Effective Bureaucrats/g' nav.xhtml
  sed -i '' 's/\.\.\/media/media/g' nav.xhtml

  cd ..
  zip bureaucracy.epub -r *
  pwd
  mkdir -p ../bin/
  mv -f bureaucracy.epub ../bin/bureaucracy_improved.epub
  cd ..
  pwd
}

function postprocess_html {
  pwd
  # replace PDF with PNG for images
  sed -i '' 's/\("images\/.*\)pdf"/\1png"/' TEMPORARY_html_pandoc_source_latex/main.html

  # instead of embedded images, just point to the PNG as an IMG
  sed -i '' 's/<embed/<img/' TEMPORARY_html_pandoc_source_latex/main.html

  # replace tilted quote with straight quote
  #sed -i '' "s/’/'/g" main.html
  #sed -i '' 's/“/"/g' main.html

  # single quote
  sed -i '' "s/&#x2018;/'/g" TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' "s/&#x2019;/'/g" TEMPORARY_html_pandoc_source_latex/main.html

  # CAVEAT: ampersand needs to be escaped in the output because it means "match" for sed
  # space
  sed -i '' "s/&#xA0;/\&nbsp;/g" TEMPORARY_html_pandoc_source_latex/main.html

  # double quote
  sed -i '' 's/&#x201D;/"/g' TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' 's/&#x201C;/"/g' TEMPORARY_html_pandoc_source_latex/main.html

  # copyright symbol
  #sed -i '' 's/&#xA9;/\(C\)/g' latex/main.html

  # em dash
  sed -i '' 's/&#x2013;/--/g' TEMPORARY_html_pandoc_source_latex/main.html

  # footnote return indicator
  sed -i '' 's/&#x21A9;&#xFE0E;/\&nbsp;Return to text/g' TEMPORARY_html_pandoc_source_latex/main.html

  # fix hyperlinked chapter numbers
  # CAVEAT: this is a fragile fix since the chapter numbers are hard-coded.
  sed -i '' 's/>\[sec:introduction\]</>1</' TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' 's/>\[sec:why-bur-hard\]</>4</' TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' 's/>\[sec:individual-in-org\]</>5</' TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' 's/>\[sec:process\]</>8</' TEMPORARY_html_pandoc_source_latex/main.html
  sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' TEMPORARY_html_pandoc_source_latex/main.html

  cp TEMPORARY_html_pandoc_source_latex/main.html latex/main.html
  pwd
}

function all {
  rm -rf TEMPORARY_*
  # The following could be launched using independent subshells
  #   since they are each independent
  # I don't have the CPUs or memory to support that
  pdf_not_bound
  pdf_for_binding
  html_pandoc
  html_latex2html
  epub_pandoc
}

# from https://www.baeldung.com/linux/run-function-in-script
# dollarsign variables in bash: https://stackoverflow.com/a/5163260/1164295
case "$1" in
    "") ;;
    all) "$@"; exit;;
    pdf_not_bound) "$@"; exit;;
    pdf_for_binding) "$@"; exit;;
    epub_pandoc) "$@"; exit;;
    html_pandoc) "$@"; exit;;
    html_latex2html) "$@"; exit;;
    *) echo "Unkown function: $1()"; exit 2;;
esac
