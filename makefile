SHELL := /bin/bash # to enable source command in run_app

MODULE=beetaone/random-hash-generator
VERSION_NAME=v2.0.0

create_image:
	docker build -t ${MODULE}:${VERSION_NAME} . -f docker/Dockerfile
.phony: create_image

run_image:
	docker run --rm -p 80:80 -v /dev/urandom:/mnt/random --network random_hash_generator_network --name random-hash-generator --env-file=./.env ${MODULE}:${VERSION_NAME}
.phony: run_image

create_network:
	docker network create random_hash_generator_network
.phony: create_network

run_docker_compose:
	docker-compose -f docker/docker-compose.yml up
.phony: run_docker_compose

stop_docker_compose:
	docker-compose -f docker/docker-compose.yml down
.phony: stop_docker_compose

run_test:
	docker-compose -f test/docker-compose.test.yml up
.phony: run_test

stop_test:
	docker-compose -f test/docker-compose.test.yml down
.phony: stop_test

push_latest:
	docker image push ${MODULE}:${VERSION_NAME}
.phony: push_latest

create_and_push_multi_platform:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7 -t ${MODULE}:${VERSION_NAME} --push . -f docker/Dockerfile
.phony: create_and_push_multi_platform

run_echo:
	docker run --rm -p 9000:9000 \
	-e PORT=9000 \
	-e LOG_HTTP_BODY=true \
	-e LOG_HTTP_HEADERS=true \
	--network random_hash_generator_network \
	--name echo \
	jmalloc/echo-server
.phony: run_echoecho
