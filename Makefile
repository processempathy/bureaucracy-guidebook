


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


# review notes to self
notes:
	grep -E -R "[A-Z]{5,}" latex/*.te

out: pdf html

# https://pandoc.org/MANUAL.html and https://pandoc.org/demos.html
# --standalone:  without it, you'd only get a snippet instead of a complete document.        https://pandoc.org/MANUAL.html#option--standalone
# --citeproc:    Process the citations in the file, replacing them with rendered citations and adding a bibliography.
docx: pdf
	cd latex; \
         pandoc main.tex -o main.docx \
         --standalone \
         --citeproc \
         --bibliography=biblio_bureaucracy.bib

html: pdf
	cd latex; \
         pandoc main.tex -f latex \
             -t html --standalone -o main.html \
             --citeproc \
             --mathjax \
             --bibliography=biblio_bureaucracy.bib
	cd ..; convert_html_pdf_to_png.sh


pdf:
	cd latex; \
         pdflatex main; \
         makeglossaries main; \
         pdflatex main; \
         bibtex main; \
         pdflatex main; \
         pdflatex main

clean:
	cd latex; rm *.aux *.bbl *.blg *.glg *.glo *.gls *.ist *.log *.out *.toc

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
	docker run --rm \
           -v `pwd`:/scratch -w /scratch/ \
           --user $(id -u):$(id -g) \
           latex_debian make html
 

