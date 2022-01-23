



docker: docker_build docker_run

docker_build:
	docker build -t latex_debian .

docker_run:
	docker run -it --rm \
           -v `pwd`:/scratch \
           --user $(id -u):$(id -g) \
           latex_debian /bin/bash