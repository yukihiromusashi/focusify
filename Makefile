.PHONY: deps build-css watch-css dev-server dev-desktop \
       build-server build-desktop clean help

# Project settings
MODULE := github.com/ahmadmusair/focusify
BIN_DIR := bin
FRONTEND_DIR := frontend
TEMPLATES_DIR := internal/templates

# Build settings
VERSION := 1.0.0
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS := -s -w -X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)

.DEFAULT_GOAL := help

## help: Show this help message
help:
	@echo "╔══════════════════════════════════════════════════════════════════╗"
	@echo "║           Hybrid App - Build Targets                             ║"
	@echo "╚══════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "  deps                 Install all dependencies"
	@echo "  build-css            Build Tailwind CSS (production)"
	@echo "  watch-css            Watch and rebuild CSS on changes"
	@echo "  dev-server           Run web server with hot-reload"
	@echo "  dev-desktop          Run desktop app"
	@echo "  build-server         Build web server binary"
	@echo "  build-desktop        Build desktop app binary"
	@echo "  clean                Remove build artifacts"
	@echo ""

## deps: Install all dependencies
deps:
	@echo "📦 Installing Go dependencies..."
	go mod download
	go mod tidy
	@echo "📦 Installing npm dependencies..."
	cd $(FRONTEND_DIR) && npm install
	@echo "📦 Installing Wails CLI..."
	go install github.com/wailsapp/wails/v3/cmd/wails3@latest
	@echo "📦 Installing Air (hot-reload)..."
	go install github.com/air-verse/air@latest
	@echo "✅ Dependencies installed successfully!"

## build-css: Build Tailwind CSS for production
build-css:
	@echo "🎨 Building Tailwind CSS..."
	cd $(FRONTEND_DIR) && npm run build:css
	@echo "📋 Copying CSS to templates directory..."
	cp $(FRONTEND_DIR)/dist/styles.css $(TEMPLATES_DIR)/static/styles.css
	@echo "✅ CSS build complete!"

## watch-css: Watch and rebuild CSS on changes
watch-css:
	@echo "👀 Watching Tailwind CSS for changes..."
	@echo "Press Ctrl+C to stop"
	cd $(FRONTEND_DIR) && npm run watch:css

## dev-server: Run web server in development mode with hot-reload
dev-server: build-css
	@echo "🚀 Starting web server with hot-reload on http://localhost:3000..."
	@echo "💡 Tip: Run 'make watch-css' in another terminal for CSS hot-reload"
	@$$(go env GOPATH)/bin/air -c .air.toml

## dev-desktop: Run desktop app in development mode
dev-desktop: build-css
	@echo "🖥️  Starting desktop application..."
	go run ./cmd/desktop/main.go

## build-server: Build web server for current OS
build-server: build-css
	@echo "🔨 Building web server for current OS..."
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o $(BIN_DIR)/server ./cmd/server
	@echo "✅ Server binary: $(BIN_DIR)/server"

## build-desktop: Build desktop app for current OS
build-desktop: build-css
	@echo "🔨 Building desktop application..."
	@mkdir -p $(BIN_DIR)
	wails3 build -platform desktop -o $(BIN_DIR)/desktop
	@echo "✅ Desktop binary: $(BIN_DIR)/desktop"

## clean: Remove build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(BIN_DIR)
	rm -rf tmp
	rm -f build-errors.log
	@echo "✅ Clean complete!"

## clean-db: Remove SQLite database
clean-db:
	@echo "🧹 Removing database..."
	rm -f *.db *.db-shm *.db-wal
	@echo "✅ Database removed!"
