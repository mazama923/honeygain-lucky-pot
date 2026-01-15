IMAGE_NAME ?= benlexa/honeygain-lucky-pot
IMAGE_TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: all build push inspect clean login setup-builder

all: login setup-builder build push inspect

# Login Docker Hub (prompt password)
login:
	@echo "🔐 Login Docker Hub..."
	@docker login

# Setup builder multi-arch (1x)
setup-builder:
	@echo "🚀 Setup multi-arch builder..."
	@docker buildx create --use --name multiarch-builder || true
	@docker buildx inspect --bootstrap

# Build local (sans push)
build:
	@echo "🏗️ Build local $(IMAGE_NAME):$(IMAGE_TAG)..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Build + Push multi-arch
push: login setup-builder
	@echo "📤 Buildx + Push multi-arch $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		--push .

# Inspect image (multi-arch)
inspect:
	@echo "🔍 Inspect $(IMAGE_NAME):$(IMAGE_TAG)..."
	@docker buildx imagetools inspect $(IMAGE_NAME):$(IMAGE_TAG)

# Test local
test:
	@echo "🧪 Test local (set HONEYGAIN_EMAIL/PASSWORD)..."
	docker run --rm \
		-e HONEYGAIN_EMAIL=$$HONEYGAIN_EMAIL \
		-e HONEYGAIN_PASSWORD=$$HONEYGAIN_PASSWORD \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Clean
clean:
	@echo "🧹 Clean..."
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
	docker buildx rm multiarch-builder || true

# Help
help:
	@echo "Usage:"
	@echo "  make push          # Build + push multi-arch (full workflow)"
	@echo "  make build         # Build local only"
	@echo "  make test          # Test (export HONEYGAIN_EMAIL=...)"
	@echo "  make inspect       # Check Docker Hub"
	@echo "  make clean         # Remove images"
	@echo "Vars: IMAGE_NAME=benlexa/honeygain:v1.0 IMAGE_TAG=v1.0"

