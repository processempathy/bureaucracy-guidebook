#!/usr/bin/env bash

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value
set -o xtrace    # set -x : show commands as the script executes

echo "use:"
echo "$0 pdf_not_bound; $0 pdf_for_binding; $0 epub_pandoc; $0 html_pandoc"
echo "or"
echo "$0 all"

function pdf_not_bound {
  pwd
  cp latex/main.tex latex/main_pdf_not_bound.tex
  sed -i '' "s/boundbooktrue/boundbookfalse/" latex/main_pdf_not_bound.tex
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" latex/main_pdf_not_bound.tex
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" latex/main_pdf_not_bound.tex
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log1_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_pdf_not_bound         > log2_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_pdf_not_bound                 > log3_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log4_pdf_not_bound.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log5_pdf_not_bound.log
    cd ..
  mv -f latex/main_pdf_not_bound.pdf bin/bureaucracy_not_bound.pdf
}

function pdf_for_binding {
  pwd
  cp latex/main.tex latex/main_for_binding.tex
  sed -i '' "s/boundbookfalse/boundbooktrue/" latex/main_for_binding.tex
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" latex/main_for_binding.tex
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" latex/main_for_binding.tex
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log1_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_for_binding         > log2_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_for_binding                 > log3_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log4_for_binding.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_for_binding > log_for_binding5.log
    cd ..
  mv -f latex/main_for_binding.pdf bin/bureaucracy_for_binding.pdf

}

function epub_pandoc {
  pwd

  # Pandoc can't handle "toggle" being used in files other than the file where the toggle was defined,
  # so merge all \input{}  so that all content is in one file, as per
  # https://tex.stackexchange.com/a/21840/235813
  #cd latex
  #time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latexpand --keep-comments --output main_merged.tex --fatal main.tex
  #cd ..
  #mv latex/main_merged.tex latex/main_epub_pandoc.tex

  rm -rf TEMPORARY_epub_source
  mkdir TEMPORARY_epub_source
  cp -r latex/* TEMPORARY_epub_source/
  rm -rf TEMPORARY_epub_source/main_*
  mv TEMPORARY_epub_source/main.tex TEMPORARY_epub_source/main_epub_pandoc.tex

  # DEPRECATED -- fancy and fragile
  # python3 evaluate_boolean_toggles.py TEMPORARY_epub_source/main_epub_pandoc.tex
  for f in TEMPORARY_epub_source/*.tex; do
      # haspagenumbers == true
      #cat $f | grep "iftoggle" | sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\1/'
      # haspagenumbers == false
      sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\2/' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{glossarysubstitutionworks}{(.*)}{(.*)}/\2/' $f
      # showminitoc == true
      sed -i '' -E 's/\\iftoggle{showminitoc}{(.*)}{(.*)}/\1/' $f
  done


  # The version of Pandoc I'm using doesn't understand \newif
  # https://github.com/jgm/pandoc/issues/6096
  sed -i '' "/documentclass\[oneside\]{book}/d" TEMPORARY_epub_source/main_epub_pandoc.tex
  sed -i '' "/\\usepackage.*{geometry}/d" TEMPORARY_epub_source/main_epub_pandoc.tex

  sed -i '' "/\\newif/d" TEMPORARY_epub_source/main_epub_pandoc.tex
  sed -i '' "/\\else/d" TEMPORARY_epub_source/main_epub_pandoc.tex
  sed -i '' "/\\fi/d" TEMPORARY_epub_source/main_epub_pandoc.tex
  sed -i '' "/\\boundbook/d" TEMPORARY_epub_source/main_epub_pandoc.tex
  sed -i '' "/\\ifboundbook/d" TEMPORARY_epub_source/main_epub_pandoc.tex

  #sed -i '' "s/haspagenumberstrue/haspagenumbersfalse/" TEMPORARY_epub_source/main_epub_pandoc.tex
  #sed -i '' "s/glossarysubstitutionworkstrue/glossarysubstitutionworksfalse/" TEMPORARY_epub_source/main_epub_pandoc.tex
  cd TEMPORARY_epub_source;
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
    cd ..
  mv -f TEMPORARY_epub_source/main_epub_pandoc.epub bin/bureaucracy.epub
  postprocess_epub
}

# --ascii = 	Use only ASCII characters in output.
function html_pandoc {
  pwd

  # Pandoc can't handle "toggle" being used in files other than the file where the toggle was defined,
  # so merge all \input{}  so that all content is in one file, as per
  # https://tex.stackexchange.com/a/21840/235813
  #cd latex
  #time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latexpand --keep-comments --output main_merged.tex --fatal main.tex
  #cd ..
  #cp latex/main_merged.tex latex/main_html_pandoc.tex

  rm -rf TEMPORARY_html_pandoc_source
  mkdir TEMPORARY_html_pandoc_source
  cp -r latex/* TEMPORARY_html_pandoc_source/
  rm -rf TEMPORARY_html_pandoc_source/main_*
  mv TEMPORARY_html_pandoc_source/main.tex TEMPORARY_html_pandoc_source/main_html_pandoc.tex

  # DEPRECATED -- fancy and fragile
  # python3 evaluate_boolean_toggles.py TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  for f in TEMPORARY_html_pandoc_source/*.tex; do
      # haspagenumbers == true
      #cat $f | grep "iftoggle" | sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\1/'
      # haspagenumbers == false
      sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\2/' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{glossarysubstitutionworks}{(.*)}{(.*)}/\2/' $f
      # showminitoc == true
      sed -i '' -E 's/\\iftoggle{showminitoc}{(.*)}{(.*)}/\1/' $f
  done

  # The version of Pandoc I'm using doesn't understand \newif
  # https://github.com/jgm/pandoc/issues/6096
  sed -i '' "/documentclass\[oneside\]{book}/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  sed -i '' "/\\usepackage.*{geometry}/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex

  sed -i '' "/\\newif/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  sed -i '' "/\\else/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  sed -i '' "/\\fi/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  sed -i '' "/\\boundbook/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  sed -i '' "/\\ifboundbook/d" TEMPORARY_html_pandoc_source/main_html_pandoc.tex

  #sed -i '' "s/toggletrue{haspagenumbers}/togglefalse{haspagenumbers}/" TEMPORARY_html_pandoc_source/main_html_pandoc.tex
  #sed -i '' "s/toggletrue{glossarysubstitutionworks}/togglefalse{glossarysubstitutionworks}/" TEMPORARY_html_pandoc_source/main_html_pandoc.tex

  cd TEMPORARY_html_pandoc_source; \
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
    cd ..
  postprocess_html
}

function html_latex2html {

  cp latex/main.tex latex/main_html_l2h.tex
  sed -i '' "s/toggletrue{haspagenumbers}/togglefalse{haspagenumbers}/" latex/main_html_l2h.tex
  #sed -i '' "s/toggletrue{glossarysubstitutionworks}/togglefalse{glossarysubstitutionworks}/" latex/main_html_l2h.tex

	cd latex
    # Need to get glossary and bibliography before generating HTML
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main_pdf_not_bound > log1_latex2html.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries main_pdf_not_bound         > log2_latex2html.log; \
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex main_pdf_not_bound                 > log3_latex2html.log; \

    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latex2html main_html_l2h \
		-index_in_navigation \
		-contents_in_navigation \
		-next_page_in_navigation \
		-previous_page_in_navigation \
		-show_section_numbers \
		-split 2 \
		-verbosity 2 \
		-html_version "5.0"
  cd ..
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
  done
  cd ..
  sed -i '' 's/<embed/<img/' nav.xhtml
  sed -i '' 's/\(media\/.*\)pdf"/\1png"/' nav.xhtml

  sed -i '' 's/Effective Bureaucrats image/Effective Bureaucrats/g' nav.xhtml
  sed -i '' 's/\.\.\/media/media/g' nav.xhtml

  cd ..
  zip bureaucracy.epub -r *
  pwd
  mv -f bureaucracy.epub ../bin/bureaucracy_improved.epub
  cd ..
}

function postprocess_html {
  # replace PDF with PNG for images
  sed -i '' 's/\("images\/.*\)pdf"/\1png"/' TEMPORARY_html_pandoc_source/main.html

  # instead of embedded images, just point to the PNG as an IMG
  sed -i '' 's/<embed/<img/' TEMPORARY_html_pandoc_source/main.html

  # replace tilted quote with straight quote
  #sed -i '' "s/’/'/g" main.html
  #sed -i '' 's/“/"/g' main.html

  # single quote
  sed -i '' "s/&#x2018;/'/g" TEMPORARY_html_pandoc_source/main.html
  sed -i '' "s/&#x2019;/'/g" TEMPORARY_html_pandoc_source/main.html

  # CAVEAT: ampersand needs to be escaped in the output because it means "match" for sed
  # space
  sed -i '' "s/&#xA0;/\&nbsp;/g" TEMPORARY_html_pandoc_source/main.html

  # double quote
  sed -i '' 's/&#x201D;/"/g' TEMPORARY_html_pandoc_source/main.html
  sed -i '' 's/&#x201C;/"/g' TEMPORARY_html_pandoc_source/main.html

  # copyright symbol
  #sed -i '' 's/&#xA9;/\(C\)/g' latex/main.html

  # em dash
  sed -i '' 's/&#x2013;/--/g' TEMPORARY_html_pandoc_source/main.html

  # footnote return indicator
  sed -i '' 's/&#x21A9;&#xFE0E;/\&nbsp;return to text/g' TEMPORARY_html_pandoc_source/main.html

  # fix hyperlinked chapter numbers
  # CAVEAT: this is a fragile fix since the chapter numbers are hard-coded.
  sed -i '' 's/>\[sec:introduction\]</>1</' TEMPORARY_html_pandoc_source/main.html
  sed -i '' 's/>\[sec:why-bur-hard\]</>4</' TEMPORARY_html_pandoc_source/main.html
  sed -i '' 's/>\[sec:individual-in-org\]</>5</' TEMPORARY_html_pandoc_source/main.html
  sed -i '' 's/>\[sec:process\]</>8</' TEMPORARY_html_pandoc_source/main.html
  sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' TEMPORARY_html_pandoc_source/main.html

}

function all {
  rm -rf TEMPORARY_*
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
