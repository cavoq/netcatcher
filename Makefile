PROJECT=netcatcher
VERSION=0.1.5
ENVIROMENT=.env
REGISTRY=ghcr.io

include $(ENVIROMENT)
export $(shell sed 's/=.*//' $(ENVIROMENT))

help: ## Get help for Makefile
	@echo "\n#### $(PROJECT) v$(VERSION) ####\n"
	@echo "Available targets:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "\n"

docker-build: ## Build docker image
	@docker build -t $(REGISTRY)/$(GITHUB_USER)/$(PROJECT):$(VERSION) .

docker-push: ## Push docker image
	@docker login ghcr.io -u $(GITHUB_USER) -p $(GITHUB_ACCESS_TOKEN)
	@docker push $(REGISTRY)/$(GITHUB_USER)/$(PROJECT):$(VERSION)

docker-run: ## Run docker container
	@docker-compose up $(PROJECT)

docker-bash: ## Shell into docker container
	@docker-compose run $(PROJECT) /bin/bash

docker-remove: ## Remove docker container
	@docker container rm $(REGISTRY)/$(GITHUB_USER)/$(PROJECT):$(VERSION)

.PHONY: help docker-build docker-bash docker-remove docker-run docker-push