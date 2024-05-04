PROJECT=netcatcher
VERSION=0.1.3


help: ## Get help for Makefile
	@echo "\n#### $(PROJECT) v$(VERSION) ####\n"
	@echo "Available targets:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "\n"

docker-build: ## Build docker image
	docker build -t $(PROJECT):$(VERSION) .

docker-run: ## Run docker container
	docker-compose up

docker-test: ## Run tests in docker container
	docker run --network=host --rm $(PROJECT):$(VERSION) make test

docker-bash: ## Shell into docker container
	docker run --network=host --rm -it $(PROJECT):$(VERSION) bash

docker-remove: ## Remove docker container
	@docker container rm $(PROJECT):$(VERSION)

.PHONY: help docker-build docker-bash docker-remove docker-test docker-run