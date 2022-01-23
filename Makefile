


help:
	@echo "make help"
	@echo "      this message"
	@echo "==== Targets outside container ===="
	@echo "make docker"
	@echo "      build and run docker"
	@echo "==== Targets inside container ===="
	@echo "make pdf"
	@echo "      generate pdf from .tex files"

# the following commands are for use inside the Docker image

pdf:
	cd latex; pdflatex main

# the following commands are for use outside the Docker image

# see also 
# https://gordonlesti.com/building-a-latex-docker-image/
# https://github.com/pycnic/docker-texlive/blob/master/Dockerfile
docker: docker_build docker_run

docker_build:
	docker build -t latex_debian .

docker_run:
	docker run -it --rm \
           -v `pwd`:/scratch \
           --user $(id -u):$(id -g) \
           latex_debian /bin/bash
