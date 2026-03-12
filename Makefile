IMAGE_NAME = iopaint-rocm
TAG = 1.6.0
PLATFORM = linux/amd64
OUT_DIR = out
EXPORT_FILE = $(OUT_DIR)/iopaint-rocm-$(TAG).tar.gz

.PHONY: all build export clean help prepare

all: prepare build export

prepare:
	@mkdir -p $(OUT_DIR)

build:
	@echo "Building IOPaint ROCm image for $(PLATFORM)..."
	docker buildx build --platform $(PLATFORM) \
		--build-arg PLATFORM=$(PLATFORM) \
		-t $(IMAGE_NAME):$(TAG) \
		-t $(IMAGE_NAME):latest \
		-f docker/ROCmDockerfile \
		./IOPaint --load

export:
	@echo "Exporting image to $(EXPORT_FILE)..."
	docker save $(IMAGE_NAME):$(TAG) | gzip > $(EXPORT_FILE)
	@echo "Export complete: $(EXPORT_FILE)"
	@echo "To load on the target machine: 'docker load < $(EXPORT_FILE)'"

clean:
	@echo "Cleaning up..."
	rm -rf $(OUT_DIR)

help:
	@echo "Available targets:"
	@echo "  make build   - Build the Docker image for $(PLATFORM)"
	@echo "  make export  - Save the built image to $(OUT_DIR)/"
	@echo "  make all     - Build and export"
	@echo "  make clean   - Remove the $(OUT_DIR) directory"
