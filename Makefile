VERSION ?= v0.1.0
IMAGE ?= guestbook:$(VERSION)

.DEFAULT_TARGET = help

## help: Display list of commands
.PHONY: help
help: Makefile
	@sed -n 's|^##||p' $< | column -t -s ':' | sed -e 's|^| |'

## build: Build a container
.PHONY: build
build:
	docker build . -t ${IMAGE}

## load: Load a container image in kind
.PHONY: load
load:
	kind load docker-image "${IMAGE}" --name padok-training

## run: Run the consumer
.PHONY: run
run:
	docker-compose up --build
