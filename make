#!/usr/bin/env bash

# This script produces multiple formats of the same content.
# Latex source code in the latex/ folder is used to create
#
#   * PDF for book = pdf_for_printing_and_binding
#      * small page size (5.5"x8.5")
#      * on paper, so no hyperlinks
#      * no margin notes
#      * binding margin
#      * both sides of paper (duplex)
#   * PDF for printing on 8.5"x11" paper = pdf_85x11_print_single_sided
#      * on paper, so no hyperlinks
#      * margin notes
#      * no binding margin
#      * single sided page (simplex)
#   * PDF for electronic format = pdf_85x11_electronic_single_sided
#      * 8.5"x11"
#      * hyperlinks
#      * margin notes
#      * no binding margin
#      * single sided page (simplex)
#   * EPUB
#   * HTML
# The conversion process uses Latex commands and pandoc,
# both of which are in a container

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value
set -o xtrace    # set -x : show commands as the script executes

echo "use:"
echo "$0 pdf_not_bound; $0 pdf_for_binding; $0 epub_pandoc; $0 html_pandoc; $0 html_latex2html; $0 bookcover;"
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


function pdf_85x11_electronic_single_sided {
  echo "[trace] inside pdf_85x11_electronic_single_sided; start function"
  
  pwd
  filename="main_pdf_85x11_electronic_single_sided"
  tex_file="latex/"${filename}".tex"
  cp latex/main.tex ${tex_file}
  sed -i '' "s/boundbooktrue/boundbookfalse/" ${tex_file}
  sed -i '' "s/toggletrue{narrowpage}/togglefalse{narrowpage}/" ${tex_file}
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" ${tex_file}
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" ${tex_file}
  sed -i '' "s/togglefalse{showbacktotoc}/toggletrue{showbacktotoc}/" ${tex_file}
  sed -i '' "s/toggletrue{glossaryinmargin}/togglefalse{glossaryinmargin}/" ${tex_file}
  sed -i '' "s/toggletrue{printedonpaper}/togglefalse{printedonpaper}/" ${tex_file}
  sed -i '' "s/toggletrue{showminitoc}/togglefalse{showminitoc}/" ${tex_file}
  #sed -i '' "s/togglefalse{WPinmargin}/toggletrue{WPinmargin}/" ${tex_file}
  sed -i '' "s/toggletrue{cpforsection}/togglefalse{cpforsection}/" ${tex_file}
  cd latex

    # previous I used " > log1_${filename}.log" but I've switched to "| tee" to see the progress.

    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log1_${filename}.log
    #sed -i -E 's/href +/href/' ${filename}.idx # https://github.com/processempathy/bureaucracy-guidebook/issues/16
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries ${filename} | tee log2_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex ${filename} | tee log3_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log4_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log5_${filename}.log
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f latex/${filename}.pdf bin/bureaucracy_${filename}.pdf

  mv ${tex_file} ${tex_file}.log

  echo "[trace] inside pdf_85x11_electronic_single_sided; end function"

}

function pdf_85x11_print_single_sided {
  echo "[trace] inside pdf_85x11_print_single_sided; start function"

  pwd
  filename="main_pdf_85x11_print_single_sided"
  tex_file="latex/"${filename}".tex"
  cp latex/main.tex ${tex_file}
  sed -i '' "s/boundbooktrue/boundbookfalse/" ${tex_file}
  sed -i '' "s/toggletrue{narrowpage}/togglefalse{narrowpage}/" ${tex_file}
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" ${tex_file}
  sed -i '' "s/togglefalse{glossarysubstitutionworks}/toggletrue{glossarysubstitutionworks}/" ${tex_file}
  sed -i '' "s/toggletrue{showbacktotoc}/togglefalse{showbacktotoc}/" ${tex_file}
  sed -i '' "s/togglefalse{glossaryinmargin}/toggletrue{glossaryinmargin}/" ${tex_file}
  sed -i '' "s/togglefalse{printedonpaper}/toggletrue{printedonpaper}/" ${tex_file}
  sed -i '' "s/toggletrue{showminitoc}/togglefalse{showminitoc}/" ${tex_file}
  sed -i '' "s/toggletrue{WPinmargin}/togglefalse{WPinmargin}/" ${tex_file}
  sed -i '' "s/toggletrue{cpforsection}/togglefalse{cpforsection}/" ${tex_file}
  sed -i '' "s/colorlinks=false/colorlinks=true/" ${tex_file}  # remove the boxes around hyperlinks
  sed -i '' "s/linkcolor=blue/linkcolor=black/" ${tex_file}
  sed -i '' "s/citecolor=green/citecolor=black/" ${tex_file}
  sed -i '' "s/filecolor=magenta/filecolor=black/" ${tex_file}
  sed -i '' "s/urlcolor=cyan/urlcolor=black/" ${tex_file}
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log1_${filename}.log
    #sed -i -E 's/href +/href/' ${filename}.idx # for https://github.com/processempathy/bureaucracy-guidebook/issues/16
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries ${filename} | tee log2_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex ${filename} | tee log3_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log4_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log5_${filename}.log
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f latex/${filename}.pdf bin/bureaucracy_${filename}.pdf

  mv ${tex_file} ${tex_file}.log

  echo "[trace] inside pdf_85x11_print_single_sided; end function"

}


function pdf_for_printing_and_binding {
  echo "[trace] inside pdf_for_printing_and_binding; start function"

  pwd
  filename="main_pdf_for_printing_and_binding"
  tex_file="latex/"${filename}".tex"
  cp latex/main.tex ${tex_file}
  # book is going to be bound; set boolean to true
  sed -i '' "s/boundbookfalse/boundbooktrue/" ${tex_file}
  # toggle variable for same purpose
  sed -i '' "s/togglefalse{printedonpaper}/toggletrue{printedonpaper}/" ${tex_file}
  sed -i '' "s/togglefalse{narrowpage}/toggletrue{narrowpage}/" ${tex_file}
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
  sed -i '' "s/toggletrue{showminitoc}/togglefalse{showminitoc}/" ${tex_file}
  sed -i '' "s/toggletrue{WPinmargin}/togglefalse{WPinmargin}/" ${tex_file}
  sed -i '' "s/toggletrue{cpforsection}/togglefalse{cpforsection}/" ${tex_file}
  sed -i '' "s/togglefalse{shortsectiontitle}/toggletrue{shortsectiontitle}/" ${tex_file}
  sed -i '' "s/colorlinks=true/colorlinks=false/" ${tex_file}
  sed -i '' "s/linkcolor=blue/linkcolor=black/" ${tex_file}
  sed -i '' "s/filecolor=magenta/filecolor=black/" ${tex_file}
  sed -i '' "s/urlcolor=cyan/urlcolor=black/" ${tex_file}
  cd latex
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} | tee log1_${filename}.log
    #sed -i -E 's/href +/href/' ${filename}.idx  # https://github.com/processempathy/bureaucracy-guidebook/issues/16
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian makeglossaries ${filename} | tee log2_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian bibtex ${filename} | tee  log3_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} > log4_${filename}.log
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape ${filename} > log5_${filename}.log
    pwd
    cd ..
  pwd
  mkdir -p bin/
  mv -f latex/${filename}.pdf bin/bureaucracy_${filename}.pdf

  mv ${tex_file} ${tex_file}.log

  pwd
  cd bin/
    # https://stackoverflow.com/a/22796608/1164295
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian gs   -sDEVICE=pdfwrite   -dProcessColorModel=/DeviceGray   -dColorConversionStrategy=/Gray   -dPDFUseOldCMS=false   -dNOPAUSE -dBATCH -q   -o bureaucracy_${filename}_grayscale.pdf -f bureaucracy_${filename}.pdf
  cd ..
  pwd

  echo "[trace] inside pdf_for_printing_and_binding; end function"

}

function pandoc_preprocess {

  echo "[trace] inside pandoc_preprocess; start function"

  # Pandoc can't handle "toggle" being used in files other than the file where the toggle was defined,

  # option 1 of 2 (DEPRECATED) for Pandoc's inability to handle toggle in other .text files is
  # to merge all \input{}  so that all content is in one file, as per
  # https://tex.stackexchange.com/a/21840/235813
  #cd latex
  #time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian latexpand --keep-comments --output main_merged.tex --fatal main.tex
  #cd ..
  #cp latex/main_merged.tex latex/main_html_pandoc.tex

  # option 2 of 2 is to cycle through all .tex files and set the toggle value
  FOLDER_NAME=${1}
  TEX_NAME=${2}

  TEX_FILE_PATH=${FOLDER_NAME}/${TEX_NAME}

  rm -rf ${FOLDER_NAME}
  mkdir ${FOLDER_NAME}
  cp -r latex/* ${FOLDER_NAME}
  rm -rf ${FOLDER_NAME}/main_*
  mv ${FOLDER_NAME}/main.tex ${TEX_FILE_PATH}

  # option 2a, DEPRECATED -- fancy and fragile attempt to parse latex using Python:
  # python3 evaluate_boolean_toggles.py ${tex_file}

  # option 2b: flip the toggle using sed
  # caveat: use of regex is relatively fragile due to line breaks and greedy search for pairs of {}
  for f in ${FOLDER_NAME}/*.tex; do

      # in the situation where haspagenumbers == true
      #cat $f | grep "iftoggle" | sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\1/'
      # xor, when haspagenumbers == false
      sed -i '' -E 's/\\iftoggle{haspagenumbers}{(.*)}{(.*)}/\2/g' $f

      # printedonpaper == false
      sed -i '' -E 's/\\iftoggle{printedonpaper}{(.*)}{(.*)}/\2/g' $f
      # narrowpage == false
      sed -i '' -E 's/\\iftoggle{narrowpage}{(.*)}{(.*)}/\2/g' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{glossarysubstitutionworks}{(.*)}{(.*)}/\2/g' $f
      # glossarysubstitutionworks == false
      sed -i '' -E 's/\\iftoggle{shortsectiontitle}{(.*)}{(.*)}/\2/g' $f
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

      # the "work_distribution_in_flat_organization" contains tables in math environment that can't be converted by pandoc
      sed -i '' -E 's/\$\\left\\{//g' $f
      sed -i '' -E 's/\\right\.\$//g' $f

      # pandoc doesn't like textsuperscript; see
      # https://pandoc.org/MANUAL.html#superscripts-and-subscripts and
      # https://github.com/jgm/pandoc-citeproc/issues/128
      sed -i '' -E 's/\\textsuperscript{(.*)}/\1/g' $f
      #sed -i '' -E 's/\\textsuperscript//g' $f
#      sed -i '' -E 's/\\textsuperscrip//' $f
#      sed -i '' -E 's/{,}//g' $f
  done


  # The version of Pandoc I'm using doesn't understand \newif
  # https://github.com/jgm/pandoc/issues/6096
  sed -i '' "/documentclass\[oneside\]{book}/d" ${TEX_FILE_PATH}
  sed -i '' "/\\usepackage.*{geometry}/d" ${TEX_FILE_PATH}

  # pandoc can't process these conditionals, so remove them
  sed -i '' "/\\newif/d" ${TEX_FILE_PATH}
  sed -i '' "/\\else/d" ${TEX_FILE_PATH}
  sed -i '' "/\\fi/d" ${TEX_FILE_PATH}
  sed -i '' "/\\boundbook/d" ${TEX_FILE_PATH}
  sed -i '' -E "s/\\ifboundbook.*/%removed_ifboundbook/" ${TEX_FILE_PATH}

  # DEPRECATED since I'm using toggles
  #sed -i '' "s/haspagenumberstrue/haspagenumbersfalse/" ${tex_file}
  #sed -i '' "s/glossarysubstitutionworkstrue/glossarysubstitutionworksfalse/" ${tex_file}

  # to decrease my own confusion, even though all "iftoggle" statements have been eliminated using sed above,
  sed -i '' "s/togglefalse{haspagenumbers}/toggletrue{haspagenumbers}/" ${TEX_FILE_PATH}
  sed -i '' "s/toggletrue{narrowpage}/togglefalse{narrowpage}/" ${TEX_FILE_PATH}

  echo "[trace] inside pandoc_preprocess; end function"

}

function docx_pandoc {
  echo "[trace] inside docx_pandoc; start function"

  pwd

  pandoc_preprocess TEMPORARY_docx main_docx_pandoc.tex

  cd TEMPORARY_docx;
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pandoc main_docx_pandoc.tex -f latex \
               --epub-metadata=metadata_epub.xml \
               --citeproc \
                --bibliography=biblio_bureaucracy.bib \
                --table-of-contents \
                --number-sections \
                --gladtex \
                -o main_pandoc.docx
    pwd
    cd ..
  pwd
  echo "[trace] inside docx_pandoc; end function"

}

function epub_pandoc {
  echo "[trace] inside epub_pandoc; start function"

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

  echo "[trace] inside epub_pandoc; end function"

}

# --ascii = 	Use only ASCII characters in output.
function html_pandoc {
  echo "[trace] inside html_pandoc; start function"

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

  echo "[trace] inside html_pandoc; end function"

}

function html_latexml {
  # https://www.peterkrautzberger.org/0136/
  # https://news.ycombinator.com/item?id=39137755

  rm -rf TEMPORARY_html_latexml_source_latex
  mkdir TEMPORARY_html_latexml_source_latex
  cp -r latex/* TEMPORARY_html_latexml_source_latex/
  rm -rf TEMPORARY_html_latexml_source_latex/main_*
  mv TEMPORARY_html_latexml_source_latex/main.tex TEMPORARY_html_latexml_source_latex/main_html_latexml.tex

  # the result of running
  # latexml --dest=mydoc.xml main.tex
  # is 
  # "2 warnings; 101 errors; 1 fatal error; 2 missing files[mdframed.sty, tcolorbox.sty]."
  # and no output file is created.
  # as of 2024-01-26 I don't see a way to address the errors latexml is encountering.

  # the follow-on command needed to produce HTML is 
  #   latexmlpost --dest=mydoc.html --format=html5 mydoc.xml
  # but there's not XML file to process due to the fatal errors in step 1.

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
  echo "[trace] inside postprocess_epub; start function"

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
  echo "[trace] inside postprocess_html; start function"

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

  sed -i '' 's/ \. /\. /g' TEMPORARY_html_pandoc_source_latex/main.html

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

function bookcover {
  echo "[trace] inside bookcover; start function"

  pwd
  cd bookcover
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main > log1_pdflatex.log;
    time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdflatex -shell-escape main > log1_pdflatex.log;
  cd ..
  cp bookcover/main.pdf bin/bookcover.pdf

  # using GhostScript to combine PDFs works but the resulting PDFs lose hyperlinks
  # gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=merged_file.pdf -dBATCH bookcover/main.pdf bin/bureaucracy_for_binding.pdf

  # TODO: add to all PDFs?
  time docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian pdftk bookcover/main.pdf bin/bureaucracy_main_pdf_for_printing_and_binding.pdf cat output bin/bureaucracy_main_pdf_for_printing_and_binding_with_cover.pdf

  pwd
  echo "[trace] inside bookcover; end function"
}

function all {
  echo "[trace] inside all; start function"
  echo "[trace] removing temporary directories"
  rm -rf TEMPORARY_*
  # The following could be launched using independent subshells
  #   since they are each independent
  # I don't have the CPUs or memory to support that
  echo "[trace] finished temporary directory removal; calling pdf_85x11_electronic_single_sided"
  pdf_85x11_electronic_single_sided
  echo "[trace] finished pdf_85x11_electronic_single_sided; calling pdf_85x11_print_single_sided"
  pdf_85x11_print_single_sided
  echo "[trace] finished pdf_85x11_print_single_sided; calling pdf_for_printing_and_binding"
  pdf_for_printing_and_binding
  echo "[trace] finished pdf_for_printing_and_binding; calling bookcover"
  bookcover
  echo "to review the generated PDF, use"
  open bin/bureaucracy_main_pdf_for_printing_and_binding_with_cover.pdf
  echo "[trace] finished bookcover; calling html_pandoc"
  html_pandoc
  html_latex2html
  docx_pandoc
  epub_pandoc
  echo "[trace] inside all; end function"
}

function shell {
  docker run -it --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` latex_debian /bin/bash
}

# from https://www.baeldung.com/linux/run-function-in-script
# dollarsign variables in bash: https://stackoverflow.com/a/5163260/1164295
case "$1" in
    "") ;;
    all) "$@"; exit;;
    pdf_85x11_electronic_single_sided) "$@"; exit;;
    pdf_85x11_print_single_sided) "$@"; exit;;
    pdf_for_printing_and_binding) "$@"; exit;;
    bookcover) "$@"; exit;;
    epub_pandoc) "$@"; exit;;
    docx_pandoc) "$@"; exit;;
    html_pandoc) "$@"; exit;;
    html_latex2html) "$@"; exit;;
    shell) "$@"; exit;;
    *) echo "Unkown function: $1()"; exit 2;;
esac

# bureaucracy_main_pdf_85x11_electronic_single_sided.pdf
# bureaucracy_main_pdf_85x11_print_single_sided.pdf
# bureaucracy_main_pdf_for_printing_and_binding.pdf
# bureaucracy_main_pdf_for_printing_and_binding_grayscale.pdf

# EOF
