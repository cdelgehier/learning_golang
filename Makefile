# Use Docker buildkit for faster builds
DOCKER_BUILDKIT    ?= 1
export DOCKER_BUILDKIT

# Options for docker build
DOCKER_BUILD_OPTS  ?=
# DOCKER_BUILD_OPTS ?= --no-cache

# Determine current user to avoid file owner issues
CURRENT_USER_ID    ?= $(shell id -u)
CONTAINER_USERHOME ?= /workdir

DOCKER_RUN_TOOLBOX_OPTS ?= --rm \
	--env-file=$(CURDIR)/tools/docker-env \
	--env=USER_UID=$(CURRENT_USER_ID) \
	--env=USER_HOME=$(CONTAINER_USERHOME) \
	--workdir=$(CURDIR) \
	--volume=$(CURDIR):$(CURDIR)

export DOCKER_BUILD_OPTS DOCKER_RUN_TOOLBOX_OPTS

# Docker Host
ifdef DOCKER_HOST
	DOCKER_HOST_IP ?= $(shell echo $(DOCKER_HOST) | sed 's/tcp:\/\///' | sed 's/:[0-9.]*//')
else
	DOCKER_HOST_IP ?= 127.0.0.1
endif

# Docker images name
DOCKER_OWNER          ?= cdelgehier
DOCKER_IMAGE_BUILDER   = $(DOCKER_OWNER)/$(APP_NAME):builder
DOCKER_IMAGE_APISERVER = $(DOCKER_OWNER)/$(APP_NAME):api-server
DOCKER_IMAGE_SWAGGER   = $(DOCKER_OWNER)/$(APP_NAME):swagger-ui
DOCKER_IMAGE_TOOLBOX   = $(DOCKER_OWNER)/$(APP_NAME):toolbox

# VERSION variables
VERSION    = $(shell git describe --abbrev=0 --tags)
BUILD      = $(shell git rev-parse --short HEAD)
BUILD_TIME = $(shell date +%FT%T%z)
TAG_NAME  ?=

# Setup the -ldflags option for go build here
LDFLAGS="-w -s \
	-X 'main.Version=${VERSION}' \
	-X 'main.Build=${BUILD}' \
	-X 'main.BuildTime=${BUILD_TIME}'"

# APP RUN Ports
API_SERVER_PORT ?= 8080
SWAGGER_UI_PORT ?= 9090

# Global App vars
APP_NAME  ?= myapp
export APP_NAME

.PHONY: build run clean swag help

## build     : Build the docker image of $(APP_NAME)
build:
# builder stage
	@docker build --target builder \
		--tag $(DOCKER_IMAGE_BUILDER) \
		$(DOCKER_BUILD_OPTS) \
		--build-arg LDFLAGS=${LDFLAGS} . && echo "== Stage: BUILDER done"
# api server
	@docker build --target api-server \
		--tag $(DOCKER_IMAGE_APISERVER) \
		$(DOCKER_BUILD_OPTS) \
		--build-arg LDFLAGS=${LDFLAGS} . && echo "== Stage: API Server done"
# swagger-ui
	@docker build --target swagger-ui \
		--tag $(DOCKER_IMAGE_SWAGGER) \
		$(DOCKER_BUILD_OPTS) . && echo "== Stage: SWAGGER UI done"

## run       : Run the docker image on DOCKER_HOST_IP:8080
run:
	@docker run --detach --name $(APP_NAME)_api-server --publish ${API_SERVER_PORT}:8080 $(DOCKER_IMAGE_APISERVER)
	@docker run --detach --name $(APP_NAME)_swagger-ui --publish ${SWAGGER_UI_PORT}:8080 $(DOCKER_IMAGE_SWAGGER)

## clean     : Clean all containers
clean:
	@docker stop $(APP_NAME)_api-server; docker rm $(APP_NAME)_api-server
	@docker stop $(APP_NAME)_swagger-ui; docker rm $(APP_NAME)_swagger-ui

## swag      : generate swagger json
swag:
# TODO: generate docs when there are several files
	@docker run --rm --volume "$(PWD):/go/src/app" --name $(APP_NAME)_swag $(DOCKER_IMAGE_BUILDER) swag init -g ./api-server.go

## test      : Run tests
test: build
	@docker run --rm --name $(APP_NAME)_builder $(DOCKER_IMAGE_BUILDER)


build-toolbox:
	@docker build $(DOCKER_BUILD_OPTS) --file=$(CURDIR)/tools/Dockerfile --tag=$(DOCKER_IMAGE_TOOLBOX) $(CURDIR)
shell-toolbox:
	@docker run --tty --interactive $(DOCKER_RUN_TOOLBOX_OPTS) $(DOCKER_IMAGE_TOOLBOX) bash
## release   : Build release on tag prepare_vX.Y.Z
release: build-toolbox
	@docker run $(DOCKER_RUN_TOOLBOX_OPTS) $(DOCKER_IMAGE_TOOLBOX) $(CURDIR)/tools/release.sh $(TAG_NAME)

## release   : Build release on tag prepare_vX.Y.Z
release: build
	@echo PLOP PLOP PLOP

## help      : Display this help
help : Makefile
	@sed -n 's/^##//p' $<