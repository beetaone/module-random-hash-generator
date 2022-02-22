# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# # grep the version from the mix file
# VERSION=$(shell ./version.sh)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build -t $(ACCOUNT_NAME)/$(MODULE_NAME):$(VERSION_TAG) . -f image/Dockerfile

# build-nc: ## Build the container without caching
# 	docker build --no-cache -t $(MODULE_NAME) .

run: ## Run container on port configured in `config.env`
	docker run -i -t --rm -p 80:80 --env-file=./config.env \
		--volume $(VOLUME_HOST):$(VOLUME_CONTAINER) \
		--name $(MODULE_NAME) \
		-e EGRESS_URL=localhost \
		$(ACCOUNT_NAME)/$(MODULE_NAME) --hash sha256 --interval=2

listen: ## Pull and start a listener
	docker run --detach \
		-e PORT=$(LISTEN_PORT) \
		-e LOG_HTTP_BODY=true \
		-e LOG_HTTP_HEADERS=true \
		-p $(LISTEN_PORT):$(LISTEN_PORT) \
		--name echo jmalloc/echo-server

up: build run ## Run container on port configured in `config.env` (Alias to run)

# check:
# 	docker pushrm2 --version
# ifeq (, $(shell which docker pushrm))
# $(error "No lzop in $(PATH), consider doing apt-get install lzop")
# endif

listentest: ## Run a listener container and receive messages from this container
	make build
	echo "Creating Network ..."
	docker network create $(NETWORK_NAME) || true
	echo "Creating Listening container ..."
	docker run --detach --network=$(NETWORK_NAME) --rm \
		-e PORT=$(LISTEN_PORT) \
		-e LOG_HTTP_BODY=true \
		-e LOG_HTTP_HEADERS=true \
		--name echo jmalloc/echo-server
	echo "Creating Module container ..."
	docker run --detach --rm --env-file=./config.env \
		--network=$(NETWORK_NAME) \
		--volume $(VOLUME_HOST):$(VOLUME_CONTAINER) \
		--name $(MODULE_NAME) \
		$(ACCOUNT_NAME)/$(MODULE_NAME):$(VERSION_TAG) --hash sha256 --interval=2
	sleep 5
	echo "Output at the listener end:"
	docker logs echo
	echo "Stopping containers ..."
	docker container stop echo $(MODULE_NAME)
	docker network rm $(NETWORK_NAME)
	echo "Test done."
	
push: ## Push to dockerhub, needs credentials!
	docker push $(ACCOUNT_NAME)/$(MODULE_NAME):$(VERSION_TAG)

pushrm: ## Push to dockerhub AND add description, needs additionally the pushrm tool!
## https://github.com/christian-korneck/docker-pushrm
	docker push $(ACCOUNT_NAME)/$(MODULE_NAME):$(VERSION_TAG)
	docker pushrm $(ACCOUNT_NAME)/$(MODULE_NAME):$(VERSION_TAG) --short $(DESCRIPTION)

clean:
	docker container stop echo $(MODULE_NAME)
	docker container rm echo $(MODULE_NAME)

# docker run --rm -t \
# 	-v $(pwd):/myvol \
# 	-e DOCKER_USER='my-user' -e DOCKER_PASS='my-pass' \
# 	chko/docker-pushrm:1 --file /myvol/README.md \
# 	--short "My short description" --debug my-user/my-repo
# stop: ## Stop and remove a running container
# 	docker stop $(MODULE_NAME); docker rm $(MODULE_NAME)

# release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
# publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

# publish-latest: tag-latest ## Publish the `latest` taged container to ECR
# 	@echo 'publish latest to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO)/$(MODULE_NAME):latest

# publish-version: tag-version ## Publish the `{version}` taged container to ECR
# 	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO)/$(MODULE_NAME):$(VERSION)

# # Docker tagging
# tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

# tag-latest: ## Generate container `{version}` tag
# 	@echo 'create tag latest'
# 	docker tag $(MODULE_NAME) $(DOCKER_REPO)/$(MODULE_NAME):latest

# tag-version: ## Generate container `latest` tag
# 	@echo 'create tag $(VERSION)'
# 	docker tag $(MODULE_NAME) $(DOCKER_REPO)/$(MODULE_NAME):$(VERSION)

# # HELPERS

# # generate script to login to aws docker repo
# CMD_REPOLOGIN := "eval $$\( aws ecr"
# ifdef AWS_CLI_PROFILE
# CMD_REPOLOGIN += " --profile $(AWS_CLI_PROFILE)"
# endif
# ifdef AWS_CLI_REGION
# CMD_REPOLOGIN += " --region $(AWS_CLI_REGION)"
# endif
# CMD_REPOLOGIN += " get-login --no-include-email \)"

# # login to AWS-ECR
# repo-login: ## Auto login to AWS-ECR unsing aws-cli
# 	@eval $(CMD_REPOLOGIN)

# version: ## Output the current version
# 	@echo $(VERSION)

build_and_push_multi_platform:
	docker buildx build --platform linux/amd64,linux/arm,linux/arm64 -t $(ACCOUNT_NAME)/$(MODULE_NAME) --push . -f image/Dockerfile
.phony: create_and_push_multi_platform
