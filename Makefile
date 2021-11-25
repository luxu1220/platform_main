.PHONY: install

PIP_INDEX_URL ?= https://mirrors.aliyun.com/pypi/simple/

# DOCKER IMAGE REGISTRY
REGISTRY ?= hub.docker.com
IMAGE_NAME ?= luxu1220/platform_main
IMAGE_TAG ?= v0.1

# initialize project develop environment
pyenv:
	pyenv virtualenv 3.9.4 platform_main
	pyenv local platform_main

# install local dependencies
install:
	pip install --upgrade --index-url ${PIP_INDEX_URL} pip
	pip install --upgrade --index-url ${PIP_INDEX_URL} -r requirements/local.txt

# make this project online
online:
	docker-compose up -d --remove-orphans
	docker-compose ps

docker-run:
	docker run -it --rm --name platform_main \
	-e READ_DOT_ENV_FILE=True \
	-v $$(pwd):/app \
	-p 8000:8000 \
	${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
	python main.py

local-run:
	READ_DOT_ENV_FILE=True python main.py run

consumer:
	READ_DOT_ENV_FILE=True python rmq_consumer.py

# build docker image
docker-build:
	docker build --build-arg PIP_INDEX_URL=${PIP_INDEX_URL} -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .

# push docker image to private hub
docker-push:
	docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

docker-build-push: docker-build docker-push

migrate:
	alembic upgrade head

cleandb:
	alembic downgrade head
