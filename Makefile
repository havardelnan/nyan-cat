# Makefile for nyan-cat Docker image

# Default values
IMAGE ?= nyan-cat:latest

# Extract components from IMAGE for build args
IMAGE_NAME = $(shell echo "$(IMAGE)" | rev | cut -d: -f2- | rev)
TAG = $(shell echo "$(IMAGE)" | rev | cut -d: -f1 | rev)

.PHONY: help build push clean test run

# Default target
help:
	@echo "Nyan Cat Docker Image Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make build [IMAGE=registry/name:tag]"
	@echo "  make push [IMAGE=registry/name:tag]"
	@echo "  make run [IMAGE=registry/name:tag] [PORT=8080]"
	@echo "  make test [IMAGE=registry/name:tag]"
	@echo "  make clean [IMAGE=registry/name:tag]"
	@echo ""
	@echo "Examples:"
	@echo "  make build IMAGE=ncr.sky.nhn.no/nhn/nyancat:0.0.9"
	@echo "  make push IMAGE=docker.io/myuser/nyan-cat:latest"
	@echo "  make run IMAGE=my-nyan:v1.0.0 PORT=3000"
	@echo ""
	@echo "Current settings:"
	@echo "  IMAGE: $(IMAGE)"
	@echo "  IMAGE_NAME: $(IMAGE_NAME)"
	@echo "  TAG: $(TAG)"

# Build the Docker image
build:
	@echo "Building Docker image: $(IMAGE) for linux/amd64"
	docker build \
		--platform linux/amd64 \
		--build-arg IMAGE_NAME=$(IMAGE_NAME) \
		--build-arg IMAGE_TAG=$(TAG) \
		-t $(IMAGE) \
		.
	@echo "✅ Build complete: $(IMAGE)"

# Push the Docker image
push: build
	@echo "Pushing Docker image: $(IMAGE)"
	docker push $(IMAGE)
	@echo "✅ Push complete: $(IMAGE)"

# Run the container locally
PORT ?= 8080
run: build
	@echo "Running container: $(IMAGE) on port $(PORT)"
	docker run --rm -it \
		--platform linux/amd64 \
		-p $(PORT):8080 \
		-e HOSTNAME="$(shell hostname)" \
		-e IMAGE="$(IMAGE_NAME)" \
		-e TAG="$(TAG)" \
		$(IMAGE)

# Test the container (build and run a quick test)
test: build
	@echo "Testing container: $(IMAGE)"
	@echo "Starting container in background..."
	$(eval CONTAINER_ID := $(shell docker run -d --platform linux/amd64 -p 8081:8080 -e HOSTNAME=test -e IMAGE=$(IMAGE_NAME) -e TAG=$(TAG) $(IMAGE)))
	@echo "Container started with ID: $(CONTAINER_ID)"
	@echo "Waiting for container to be ready..."
	@sleep 3
	@echo "Testing HTTP response..."
	@if curl -f -s http://localhost:8081 > /dev/null; then \
		echo "✅ Test passed: Container is responding"; \
	else \
		echo "❌ Test failed: Container is not responding"; \
		docker logs $(CONTAINER_ID); \
		exit 1; \
	fi
	@echo "Stopping test container..."
	@docker stop $(CONTAINER_ID) > /dev/null
	@echo "✅ Test complete"

# Clean up Docker images
clean:
	@echo "Cleaning up Docker image: $(IMAGE)"
	-docker rmi $(IMAGE)
	@echo "Cleaning up dangling images..."
	-docker image prune -f
	@echo "✅ Cleanup complete"

# Build and push in one command
deploy: push
	@echo "✅ Deploy complete: $(IMAGE)"

# Development workflow - build, test, and run
dev: test
	@echo "✅ Development build tested successfully"
	@echo "Run 'make run' to start the container locally"

# Show Docker image info
info:
	@echo "Docker image information:"
	@echo "========================"
	@if docker image inspect $(IMAGE) > /dev/null 2>&1; then \
		docker image inspect $(IMAGE) --format 'Image: {{.RepoTags}}'; \
		docker image inspect $(IMAGE) --format 'Created: {{.Created}}'; \
		docker image inspect $(IMAGE) --format 'Size: {{.Size}} bytes'; \
		docker image inspect $(IMAGE) --format 'Architecture: {{.Architecture}}'; \
	else \
		echo "Image $(IMAGE) not found locally"; \
	fi
