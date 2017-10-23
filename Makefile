# Copyright 2017 Openprovider Authors. All rights reserved.
# Use of this source code is governed by a MIT-style
# license that can be found in the LICENSE file.

APP=whoisd
PROJECT=github.com/openprovider/whoisd
REGISTRY?=docker.io/openprovider

# Use the 0.0.0 tag for testing, it shouldn't clobber any release builds
RELEASE?=0.5.0
GOOS?=linux
GOARCH?=amd64

WHOISD_LOCAL_HOST?=0.0.0.0
WHOISD_LOCAL_PORT?=43
WHOISD_LOG_LEVEL?=0

# Namespace: dev, prod, release, cte, username ...
NAMESPACE?=dev

# Infrastructure: dev, stable, test ...
INFRASTRUCTURE?=dev
VALUES?=values-${INFRASTRUCTURE}

CONTAINER_IMAGE?=${REGISTRY}/${APP}
CONTAINER_NAME?=${APP}-${NAMESPACE}

REPO_INFO=$(shell git config --get remote.origin.url)
RELEASE_DATE=$(shell date +%FT%T%Z:00)

ifndef COMMIT
	COMMIT := git-$(shell git rev-parse --short HEAD)
endif

BUILDTAGS=

all: build

vendor: clean bootstrap
	dep ensure

compile: vendor test
	@echo "+ $@"
	@CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build -a -installsuffix cgo \
		-ldflags "-s -w -X ${PROJECT}/pkg/version.RELEASE=${RELEASE} -X ${PROJECT}/pkg/version.DATE=${RELEASE_DATE} -X ${PROJECT}/pkg/version.COMMIT=${COMMIT} -X ${PROJECT}/pkg/version.REPO=${REPO_INFO}" \
		-o bin/${GOOS}-${GOARCH}/${APP} ${PROJECT}/cmd

build: compile
	docker build --pull -t $(CONTAINER_IMAGE):$(RELEASE) .

push: build
	@echo "+ $@"
	@docker push $(CONTAINER_IMAGE):$(RELEASE)

run: build
	@echo "+ $@"
	@docker run --name ${CONTAINER_NAME} -p ${WHOISD_LOCAL_PORT}:${WHOISD_LOCAL_PORT} \
		-e "WHOISD_LOCAL_HOST=${WHOISD_LOCAL_HOST}" \
		-e "WHOISD_LOCAL_PORT=${WHOISD_LOCAL_PORT}" \
		-e "WHOISD_LOG_LEVEL=${WHOISD_LOG_LEVEL}" \
		-d $(CONTAINER_IMAGE):$(RELEASE)
	@sleep 1
	@docker logs ${CONTAINER_NAME}

HAS_RUNNED := $(shell docker ps | grep ${CONTAINER_NAME})
HAS_EXITED := $(shell docker ps -a | grep ${CONTAINER_NAME})

logs:
	@echo "+ $@"
	@docker logs ${CONTAINER_NAME}

stop:
ifdef HAS_RUNNED
	@echo "+ $@"
	@docker stop ${CONTAINER_NAME}
endif

start: stop
	@echo "+ $@"
	@docker start ${CONTAINER_NAME}

rm:
ifdef HAS_EXITED
	@echo "+ $@"
	@docker rm ${CONTAINER_NAME}
endif

deploy: push
	helm upgrade ${CONTAINER_NAME} -f charts/${VALUES}.yaml charts --kube-context ${INFRASTRUCTURE} --namespace ${NAMESPACE} --version=${RELEASE} -i --wait

GO_LIST_FILES=$(shell go list ${PROJECT}/... | grep -v vendor)

fmt:
	@echo "+ $@"
	@go list -f '{{if len .TestGoFiles}}"gofmt -s -l {{.Dir}}"{{end}}' ${GO_LIST_FILES} | xargs -L 1 sh -c

lint: bootstrap
	@echo "+ $@"
	@go list -f '{{if len .TestGoFiles}}"golint -min_confidence=0.85 {{.Dir}}/..."{{end}}' ${GO_LIST_FILES} | xargs -L 1 sh -c

vet:
	@echo "+ $@"
	@go vet ${GO_LIST_FILES}

test: vendor fmt lint vet
	@echo "+ $@"
	@go test -v -race -cover -tags "$(BUILDTAGS) cgo" ${GO_LIST_FILES}

check: compile
	@echo "+ $@"
	@bin/${GOOS}-${GOARCH}/${APP} -t -config=test/testconfig.conf -mapping=test/testmapping.json

cover:
	@echo "+ $@"
	@> coverage.txt
	@go list -f '{{if len .TestGoFiles}}"go test -coverprofile={{.Dir}}/.coverprofile {{.ImportPath}} && cat {{.Dir}}/.coverprofile  >> coverage.txt"{{end}}' ${GO_LIST_FILES} | xargs -L 1 sh -c

clean: stop rm
	@rm -f bin/${GOOS}-${GOARCH}/${APP}

HAS_DEP := $(shell command -v dep;)
HAS_LINT := $(shell command -v golint;)

bootstrap:
ifndef HAS_DEP
	go get -u github.com/golang/dep/cmd/dep
endif
ifndef HAS_LINT
	go get -u github.com/golang/lint/golint
endif

.PHONY: all vendor compile build push run logs stop start rm
.PHONY: deploy fmt lint vet test check cover cleen bootstrap
