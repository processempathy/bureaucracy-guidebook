


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

# review notes to self
notes:
	grep -E -R "[A-Z]{5,}" latex/*.tex

out: pdf html epub

# graph of dilemmas
dilgraph:
	grep "%GV " latex/dilemmas_and_trilemmas.tex | sed 's/%GV //'  | sed 's/.*"";//'

# list of all the dilemma keywords
dilgraphkeywords:
	grep "%GV " latex/dilemmas_and_trilemmas.tex | cut -d">" -f2 | grep "%GV" -v | grep dilemma -v | sort | uniq


# https://pandoc.org/MANUAL.html and https://pandoc.org/demos.html
# --standalone:  without it, you'd only get a snippet instead of a complete document.        https://pandoc.org/MANUAL.html#option--standalone
# --citeproc:    Process the citations in the file, replacing them with rendered citations and adding a bibliography.
docx: pdf
	cd latex; \
         pandoc main.tex -o main.docx \
         --metadata-file pandoc_metadata.yml \
         --standalone \
         --citeproc \
         --bibliography=biblio_bureaucracy.bib

html: pdf
	cd latex; \
         pandoc main.tex -f latex \
             -t html --standalone -o main.html \
             --metadata-file pandoc_metadata.yml \
             --citeproc \
             --mathjax \
             --bibliography=biblio_bureaucracy.bib
#	cd ..; convert_html_pdf_to_png.sh


pdf:
	cd latex; \
         pdflatex -shell-escape main; \
         makeglossaries main; \
         bibtex main; \
         pdflatex -shell-escape main; \
         pdflatex -shell-escape main


# https://pandoc.org/epub.html
# --gladtex converts maths into SVG images on your local machine.
epub: html
	cd latex; \
		pandoc main.tex -f latex \
		--metadata-file pandoc_metadata.yml \
		--epub-metadata=epub_metadata.xml \
		--toc \
		--gladtex \
		-t epub


rm:
	cd latex; rm -rf *

uz:
	cd latex; unzip bureaucracy-guidebook.zip; rm bureaucracy-guidebook.zip; git status

clean:
	cd latex; rm -f *.aux *.bbl *.blg *.glg *.glo *.gls *.ist *.log *.out *.toc *.html *.pdf *.xref *.tmp *.mt* *.ma* *.lg *.i* *.dvi *.css *.4* *.svg; rm -rf main-epub

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

dout:
	time docker run --rm \
           -v `pwd`:/scratch -w /scratch/ \
           --user $(id -u):$(id -g) \
           latex_debian make epub
	open latex/main.pdf
