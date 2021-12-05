# Learning golang

The purpose of this application is to become familiar with the Go language.

The app is called "myapp" and it will surely be an e-commerce application with an API server, a frontend and a mongodb backend

A second objective will be to also provide the k8s deployments in a separated repository (best practice)

Documentation generation and test execution is mandatory

## Requirements

* Golang
* $GOPATH in the $PATH
* Docker-cli

## Build

Some docker images `myapp` are built by the following command:
```shell
make build
```

## Run

The docker image built can be run:
```shell
make run
```

## Help

In order to find the possible targets of the Makefile
```shell
make help
```