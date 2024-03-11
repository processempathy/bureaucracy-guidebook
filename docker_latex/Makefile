docker: docker_build docker_live

docker_build:
	docker build -t latex_debian .

docker_live:
	docker run -it --rm \
                -v `pwd`:/scratch -w /scratch/ \
                --user $(id -u):$(id -g) \
                latex_debian /bin/bash
