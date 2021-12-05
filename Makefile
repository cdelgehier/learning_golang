# Use Docker buildkit for faster builds
DOCKER_BUILDKIT ?= 1
export DOCKER_BUILDKIT

# Options for docker build
DOCKER_BUILD_OPTS ?=
# DOCKER_BUILD_OPTS ?= --no-cache
export DOCKER_BUILD_OPTS

# VERSION=$(shell git describe --abbrev=0 --tags)
# BUILD=$(shell git rev-parse --short HEAD)


ifdef DOCKER_HOST
	DOCKER_HOST_IP  ?= $(shell echo $(DOCKER_HOST) | sed 's/tcp:\/\///' | sed 's/:[0-9.]*//')
else
	DOCKER_HOST_IP  ?= 127.0.0.1
endif

# APP Ports
API_SERVER_PORT ?= 8080
SWAGGER_UI_PORT ?= 9090

# App vars
APP_NAME ?= myapp

.PHONY: build run clean swag help

## build     : Build the docker image of $(APP_NAME)
build: swag
# builder stage
	@docker build --target builder --tag builder $(DOCKER_BUILD_OPTS) . && echo "== Stage: BUILDER done"
# api server
	@docker build --target api-server --tag $(APP_NAME):api-server $(DOCKER_BUILD_OPTS) . && echo "== Stage: API Server done"
# swagger-ui
	@docker build --target swagger-ui --tag $(APP_NAME):swagger-ui $(DOCKER_BUILD_OPTS) . && echo "== Stage: SWAGGER UI done"

## run       : Run the docker image on DOCKER_HOST_IP:8080
run: clean
	@docker run --detach --name $(APP_NAME)_api-server --publish ${API_SERVER_PORT}:8080 $(APP_NAME):api-server
	@docker run --detach --name $(APP_NAME)_swagger-ui --publish ${SWAGGER_UI_PORT}:8080 $(APP_NAME):swagger-ui

## clean     : Clean all containers
clean:
	@docker stop $(APP_NAME)_api-server; docker rm $(APP_NAME)_api-server
	@docker stop $(APP_NAME)_swagger-ui; docker rm $(APP_NAME)_swagger-ui

## swag      : generate swagger json
swag:
# TODO: generate docs when there are several files
	@swag init -g ./api-server.go

## help      : Display this help
help : Makefile
	@sed -n 's/^##//p' $<