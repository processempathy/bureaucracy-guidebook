# Many targets have been moved into "make.sh"
# because I was running into translation problems with launching 
# sed commands and bash scripts from this Makefile.
# The DEPRECATED commands have been left here 
# 1) in case I want to revert back to this Makefile-based approach and
# 2) as an example for folks interested in the build process


help:
	@echo "make help"
	@echo "      this message"
	@echo "==== Targets outside container ===="
	@echo "make docker_build"
	@echo "      create container"
	@echo "make docker_live"
	@echo "      run container"
	@echo "make docker"
	@echo "      build and run docker"
	@echo "==== Targets inside container ===="
	@echo "make pdf"
	@echo "      generate pdf from .tex files using pdflatex"
	@echo "make html"
	@echo "      generate HTML from .tex files using pandoc"

# the following commands are for use inside the Docker image


# what are all the things I haven't done yet? (As indicated by TODO.)
todo:
	grep -R -i TODO latex/*.tex

spaces:
	grep -R "\\\\ \\\\\\\\" latex/*.tex


# review notes to self
notes:
	grep -E -R "[A-Z]{5,}" latex/*.tex

DEPRECATED_out: pdf html epub

# graph of dilemmas
dilgraph:
	grep "%GV " latex/dilemmas_and_trilemmas.tex | sed 's/%GV //'  | sed 's/.*"";//'

# list of all the dilemma keywords
dilgraphkeywords:
	grep "%GV " latex/dilemmas_and_trilemmas.tex | cut -d">" -f2 | grep "%GV" -v | grep dilemma -v | sort | uniq


# https://pandoc.org/MANUAL.html and https://pandoc.org/demos.html
# --standalone		without it, you'd only get a snippet instead of a complete document.		https://pandoc.org/MANUAL.html#option--standalone
# --citeproc		Process the citations in the file, replacing them with rendered citations and adding a bibliography.
# --metadata-file	Read metadata from the supplied YAML (or JSON) file.				https://pandoc.org/MANUAL.html#option--metadata-file
DEPRECATED_docx: pdf
	cd latex; \
		pandoc main.tex -o main.docx \
		--metadata-file metadata_pandoc.yml \
		--standalone \
		--table-of-contents \
		--number-sections \
		--citeproc \
		--bibliography=biblio_bureaucracy.bib
	mv latex/main.docx bin/

#DEPRECATED_html: pdf html_latex2html html_pandoc
DEPRECATED_html: pdf html_pandoc

# "split 0" makes one giant HTML file.
# maximum verbosity is 4. Using 4 slows the process down due to printing to terminal
DEPRECATED_html_latex2html: 
	cd latex; latex2html main \
		-index_in_navigation \
		-contents_in_navigation \
		-next_page_in_navigation \
		-previous_page_in_navigation \
		-show_section_numbers \
		-split 2 \
		-verbosity 2 \
		-html_version "5.0"


# --ascii = 	Use only ASCII characters in output. 
DEPRECATED_html_pandoc: 
	cd latex; \
		pandoc main.tex -f latex \
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
#	$(shell ./convert_html_pdf_to_png.sh)


# toggle the boolean for page numbers being present
# default should be "false"; toggle to "true" during PDF compilation
# -shell-escape enables TeX to execute other commands
DEPRECATED_pdf: clean
	$(shell sed -i '' 's/haspagenumbersfalse/haspagenumberstrue/' latex/main.tex)
	cp latex/main.tex latex/main_EDITED_BY_SED_BY_MAKEFILE.tex
	cd latex; \
		pdflatex -shell-escape main; \
		makeglossaries main; \
		bibtex main; \
		pdflatex -shell-escape main; \
		pdflatex -shell-escape main
	mv latex/main.pdf bin/
	mv bin/main.pdf bin/bureaucracy.pdf
	$(shell sed -i '' 's/haspagenumbersfalse/haspagenumbersfalse/' latex/main.tex)

# https://pandoc.org/epub.html
# --gladtex converts maths into SVG images on your local machine.
# Enclose TeX math in <eq> tags in HTML output. The resulting HTML can then be processed by GladTeX to produce SVG images of the typeset formulas and an HTML file with these images embedded.

# BHP removed
# --metadata-file metadata_pandoc.yml
# so there's no conflict with the epub metadata
DEPRECATED_epub: html
	cd latex; \
		pandoc main.tex -f latex \
		--epub-metadata=metadata_epub.xml \
		--citeproc \
		--bibliography=biblio_bureaucracy.bib \
		--table-of-contents \
		--number-sections \
		--epub-cover-image=images/bureaucrat_empathizing_with_coworkers_in_office_breakroom.png \
		--gladtex \
		-t epub3 \
		-o main.epub
	mv latex/main.epub bin/
	mv bin/main.epub bin/bureaucracy.epub


rm:
	rm -rf TEMPORARY_*
	rm -rf latex/*
	rm -rf bookcover/*


uz:
	cd latex; unzip -qq bureaucracy-guidebook.zip; rm -f bureaucracy-guidebook.zip
	cd bookcover; unzip  -qq bureaucracy-bookcover_using_bookcover.zip; rm -f bureaucracy-bookcover_using_bookcover.zip
	git status

clean:
	rm -rf TEMPORARY_*; cd latex; rm -f *.aux *.bbl *.blg *.glg *.glo *.gls *.ist *.log *.out *.toc *.html *.pdf *.epub *.xref *.tmp *.mt* *.ma* *.lg *.i* *.dvi *.css *.4* *.svg *.csv; rm -rf main-epub; rm -rf main/;

# the following commands are for use outside the Docker image

# see also
# https://gordonlesti.com/building-a-latex-docker-image/
# https://github.com/pycnic/docker-texlive/blob/master/Dockerfile
docker: docker_build docker_live

docker_build:
	docker build -t latex_debian .

docker_live:
	docker run -it --rm \
		-v `pwd`:/scratch -w /scratch/ \
		--user $(id -u):$(id -g) \
		latex_debian /bin/bash

DEPRECATED_dpdf:
	time docker run --rm \
		-v `pwd`:/scratch -w /scratch/ \
		--user $(id -u):$(id -g) \
		latex_debian make pdf 

DEPRECATED_dout:
	time docker run --rm \
		-v `pwd`:/scratch -w /scratch/ \
		--user $(id -u):$(id -g) \
		latex_debian make epub
	open bin/bureaucracy.pdf
	echo "to clean up the HTML and EPUB you need to run"
	echo "./postprocessing_epub.sh"
	echo "./postprocessing_html.sh"
	echo "to complete the process"
	echo "and then run Kindle Previewer to generate KPF and MOBI"
