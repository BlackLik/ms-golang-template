DOCKER_FILE ?= docker-compose.dev.yaml
DOCKER = docker-compose -f $(DOCKER_FILE)

.PHONY: docs docker lint

install-formater:
	go install golang.org/x/tools/cmd/goimports@latest
	go install mvdan.cc/gofumpt@v0.7.0
	go install github.com/daixiang0/gci@latest

install-lint:
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.60.3

install-swag:
	go install github.com/swaggo/swag/cmd/swag@v1.16.3

install-migrate:
	go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@v4.17.1

install-air:
	go install github.com/air-verse/air@v1.52.3

intall-tools: install-formater install-lint install-swag install-air install-migrate
	@echo "Succes install tools!"

format:
	gofmt -s -w .
	gofumpt -w .
	goimports -w .
	gci write --skip-generated -s standard -s default .
	swag fmt

lint: format
	golangci-lint run

docs: format
	swag init -g ./cmd/app/main.go

build:
	go build -o main ./cmd/app/main.go

run: build
	./main

docker:
	${DOCKER} up -d --force-recreate --build

test:
	$(DOCKER) exec app go test ./...

bench:
	$(DOCKER) exec app go test -bench=. ./... -benchmem

hl:
	vegeta attack -targets="./vegeta/target.txt" -duration=30s -rate=100/s -output="./healthcheck.gob"
	vegeta report "./healthcheck.gob"
