# AI Scaffolding Instructions: Hybrid Go Application (Wails + Fiber)

> **Purpose:** This document provides complete instructions for an AI agent to initialize a hybrid application project that runs both as a standalone desktop app (Wails) and a client-server web app (Fiber) using a single codebase. This is a generic starter template, not a specific application.

## Technology Stack

- **Backend:** Go 1.23+ with Fiber v3 (web framework)
- **Desktop Runtime:** Wails v3 (native desktop with WebView)
- **Frontend:** HTMX (HTML-over-the-wire) + Alpine.js (lightweight reactivity)
- **Styling:** Tailwind CSS (utility-first, production purged)
- **Database:** SQLite (modernc.org/sqlite - pure Go, no CGO) - optional, can be replaced
- **Hot Reload:** Air (live reload for Go development)
- **Architecture:** Clean/Hexagonal (recommended, but flexible)

## Minimal Project Structure

```
project-name/
├── .air.toml                 # Air hot-reload configuration
├── .gitignore               # Git ignore file
├── go.mod                   # Go module definition
├── Makefile                 # Build automation
├── README.md                # Project documentation
├── cmd/
│   ├── server/
│   │   └── main.go         # Web server entry point (Fiber)
│   └── desktop/
│       └── main.go         # Desktop app entry point (Wails)
├── internal/
│   ├── config/
│   │   └── config.go       # Configuration (mode detection, port, etc.)
│   ├── handlers/
│   │   └── home.go         # Example HTTP handler (shared)
│   ├── middleware/
│   │   └── auth.go         # Auth middleware (optional for web mode)
│   └── templates/
│       ├── renderer.go     # Template rendering engine
│       ├── layouts/
│       │   └── base.html   # Base HTML layout
│       ├── pages/
│       │   ├── index.html  # Home page example
│       │   └── login.html  # Login page (web mode only)
│       └── static/
│           └── styles.css  # Generated Tailwind CSS
├── frontend/               # Frontend build tooling
│   ├── package.json
│   ├── tailwind.config.js
│   └── src/
│       └── input.css       # Tailwind source
└── pkg/                    # Optional: Shared packages (if needed)
```

**Note:** Add your business logic (domain, services, repositories) as needed. This is the minimal hybrid setup.

## Step-by-Step Scaffolding Instructions

### 1. Initialize Project

```bash
# Create project directory
mkdir project-name
cd project-name

# Initialize Go module
go mod init github.com/username/project-name

# Install core dependencies
go get github.com/gofiber/fiber/v3
go get github.com/wailsapp/wails/v3
go get modernc.org/sqlite
go get golang.org/x/crypto/bcrypt

# Create directory structure
mkdir -p cmd/{server,desktop}
mkdir -p internal/{domain,application,config}
mkdir -p internal/adapters/{handlers,middleware,persistence}
mkdir -p internal/templates/{layouts,pages,partials,static}
mkdir -p frontend/src
mkdir -p bin
mkdir -p docs
```

### 2. Create Configuration Files

# Optional: Add if using sessions
go get github.com/gofiber/fiber/v3/middleware/session

# Optional: Add if using database
# go get modernc.org/sqlite
# go get golang.org/x/crypto/bcrypt

# Create minimal directory structure
mkdir -p cmd/{server,desktop}
mkdir -p internal/{config,handlers,middleware}
mkdir -p internal/templates/{layouts,pages,static}
mkdir -p frontend/src
mkdir -p bin
# Database
*.db
*.db-shm
*.db-wal

# Frontend
node_modules/
frontend/dist/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Build artifacts
build-errors.log
```

#### `.air.toml`
```toml
# Air configuration for hot-reload development
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/server"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata", "bin", "frontend/node_modules"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html", "css"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_error = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = true

[screen]
  clear_on_rebuild = false
  keep_scroll = true
```

#### `Makefile`
```makefile
.PHONY: deps build-css watch-css dev-server dev-desktop \
       build-server build-desktop clean help

# Project settings
MODULE := github.com/username/project-name
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
```

#### `frontend/package.json`
```json
{
  "name": "project-name-frontend",
  "version": "1.0.0",
  "description": "Frontend build tooling for hybrid app",
  "scripts": {
    "build:css": "tailwindcss -i ./src/input.css -o ./dist/styles.css --minify",
    "watch:css": "tailwindcss -i ./src/input.css -o ../internal/templates/static/styles.css --watch"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.0"
  }
}
```

#### `frontend/tailwind.config.js`
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "../internal/templates/**/*.html",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

#### `frontend/src/input.css`
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom styles */
@layer components {
  .btn-primary {
    @apply bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded transition-colors;
  }
  
  .btn-secondary {
    @apply bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded transition-colors;
  }
  
  .btn-danger {
    @apply bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-4 rounded transition-colors;
  }
}
```

### 3. Create Configuration

#### `internal/config/config.go`
```go
package config

import "os"

type Config struct {
	Port         string
	IsDesktopApp bool
	// Add other config fields as needed
}

func Load(isDesktopApp bool) *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	return &Config{
		Port:         port,
		IsDesktopApp: isDesktopApp,
	}
}
```

### 4. Create Example Handler

#### `internal/handlers/home.go`
```go
package handlers

import "github.com/gofiber/fiber/v3"

type HomeHandler struct{}

func NewHomeHandler() *HomeHandler {
	return &HomeHandler{}
}

func (h *HomeHandler) Index(c fiber.Ctx) error {
	return c.Render("pages/index", fiber.Map{
		"Title":        "Home",
		"IsDesktopApp": c.Locals("isDesktopApp"),
	}, "layouts/base")
}
```

### 5. Create Middleware (Optional - for web auth)

#### `internal/middleware/auth.go`
```go
package middleware

import "github.com/gofiber/fiber/v3"

// ModeAware middleware sets locals based on app mode
func ModeAware(isDesktopApp bool) fiber.Handler {
	return func(c fiber.Ctx) error {
		c.Locals("isDesktopApp", isDesktopApp)
		
		// Desktop mode: no auth needed, use default user
		if isDesktopApp {
			c.Locals("userID", int64(1))
			return c.Next()
		}

		// Web mode: implement session-based auth here if needed
		// For now, just pass through
		return c.Next()
	}
}
```

### 6. Create Template Renderer

#### `internal/templates/renderer.go`
```go
package templates

import (
	"embed"
	"html/template"
	"io"

	"github.com/gofiber/fiber/v3"
)

//go:embed layouts/* pages/* partials/* static/*
var TemplateFS embed.FS

type Engine struct {
	templates *template.Template
}

func New() *Engine {
	templates := template.Must(template.ParseFS(TemplateFS, "layouts/*.html", "pages/*.html", "partials/*.html"))
	return &Engine{templates: templates}
}

func (e *Engine) Load() error {
	return nil
}

func (e *Engine) Render(out io.Writer, name string, binding interface{}, layout ...string) error {
	if len(layout) > 0 {
		return e.templates.ExecuteTemplate(out, layout[0], binding)
	}
	return e.templates.ExecuteTemplate(out, name, binding)
}
```

### 7. Create HTML Templates

#### `internal/templates/layouts/base.html`
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Title}}</title>
    <link rel="stylesheet" href="/static/styles.css">
    <script src="https://unpkg.com/htmx.org@2.0.0"></script>
    <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
</head>
<body class="bg-gray-100 min-h-screen">
    {{template "content" .}}
</body>
</html>
```

#### `internal/templates/pages/index.html`
```html
{{define "content"}}
<div class="container mx-auto px-4 py-8 max-w-4xl">
    <div class="bg-white rounded-lg shadow-md p-8">
        <h1 class="text-3xl font-bold text-gray-800 mb-4">
            Welcome to Your Hybrid App
        </h1>
        
        <p class="text-gray-600 mb-4">
            {{if .IsDesktopApp}}
                Running in <span class="font-bold text-blue-600">Desktop Mode</span>
            {{else}}
                Running in <span class="font-bold text-green-600">Web Server Mode</span>
            {{end}}
        </p>
        
        <div class="bg-gray-50 p-4 rounded">
            <h2 class="font-semibold mb-2">Next Steps:</h2>
            <ul class="list-disc list-inside space-y-1 text-gray-700">
                <li>Add your routes in cmd/server/main.go and cmd/desktop/main.go</li>
                <li>Create handlers in internal/handlers/</li>
                <li>Add more pages in internal/templates/pages/</li>
                <li>Use HTMX for dynamic interactions</li>
                <li>Style with Tailwind CSS classes</li>
            </ul>
        </div>
    </div>
</div>
{{end}}
```

#### `internal/templates/pages/login.html` (optional - for web auth)
```html
{{define "content"}}
<div class="min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-md w-96">
        <h1 class="text-2xl font-bold mb-6 text-center">Login</h1>
        
        {{if .Error}}
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {{.Error}}
        </div>
        {{end}}
        
        <form method="POST" action="/login">
            <div class="mb-4">
                <label class="block text-gray-700 text-sm font-bold mb-2">Username</label>
                <input type="text" name="username" required
                    class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            
            <div class="mb-6">
                <label class="block text-gray-700 text-sm font-bold mb-2">Password</label>
                <input type="password" name="password" required
                    class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            
            <button type="submit" class="btn-primary w-full">Login</button>
        </form>
    </div>
</div>
{{end}}
```

### 8. Create Entry Points

#### `cmd/server/main.go` (Web Server Mode)
```go
package main

import (
	"log"

	"github.com/gofiber/fiber/v3"
	"github.com/username/project-name/internal/config"
	"github.com/username/project-name/internal/handlers"
	"github.com/username/project-name/internal/middleware"
	"github.com/username/project-name/internal/templates"
)

func main() {
	// Load configuration
	cfg := config.Load(false) // false = web server mode

	// Initialize handlers
	homeHandler := handlers.NewHomeHandler()

	// Initialize Fiber app
	app := fiber.New(fiber.Config{
		Views: templates.New(),
	})

	// Middleware
	app.Use(middleware.ModeAware(cfg.IsDesktopApp))

	// Static files
	app.Static("/static", "./internal/templates/static")

	// Routes
	app.Get("/", homeHandler.Index)
	
	// Add your application routes here
	// app.Get("/api/items", itemHandler.GetAll)
	// app.Post("/api/items", itemHandler.Create)

	log.Printf("🚀 Web server starting on http://localhost:%s\n", cfg.Port)
	log.Fatal(app.Listen(":" + cfg.Port))
}
```

#### `cmd/desktop/main.go` (Desktop App Mode)
```go
package main

import (
	"log"

	"github.com/gofiber/fiber/v3"
	"github.com/wailsapp/wails/v3/pkg/application"
	"github.com/username/project-name/internal/config"
	"github.com/username/project-name/internal/handlers"
	"github.com/username/project-name/internal/middleware"
	"github.com/username/project-name/internal/templates"
)

func main() {
	// Load configuration
	cfg := config.Load(true) // true = desktop mode

	// Initialize handlers
	homeHandler := handlers.NewHomeHandler()

	// Initialize Fiber app (embedded server)
	app := fiber.New(fiber.Config{
		Views: templates.New(),
	})

	// Middleware
	app.Use(middleware.ModeAware(cfg.IsDesktopApp))

	// Static files
	app.Static("/static", "./internal/templates/static")

	// Routes (same as web server)
	app.Get("/", homeHandler.Index)
	
	// Add your application routes here
	// app.Get("/api/items", itemHandler.GetAll)
	// app.Post("/api/items", itemHandler.Create)

	// Start Fiber server in background
	go func() {
		if err := app.Listen(":" + cfg.Port); err != nil {
			log.Fatal(err)
		}
	}()

	// Create Wails application
	wailsApp := application.New(application.Options{
		Name:        "My Hybrid App",
		Description: "A hybrid desktop and web application",
		URL:         "http://localhost:" + cfg.Port,
		Width:       1200,
		Height:      800,
	})

	// Run the app
	if err := wailsApp.Run(); err != nil {
		log.Fatal(err)
	}
}
```

### 9. Create README

#### `README.md`
```markdown
# Hybrid App Starter

A minimal starter template for building hybrid applications that run both as a standalone desktop app (Wails) and a client-server web app (Fiber) using a single codebase.

## Features

- ✅ Single codebase for both deployment modes
- ✅ Fiber v3 web framework
- ✅ Wails v3 desktop runtime
- ✅ HTMX for dynamic interactions
- ✅ Alpine.js for lightweight reactivity
- ✅ Tailwind CSS styling
- ✅ Air hot-reload for development
- ✅ Mode-aware routing (desktop vs web)

## Prerequisites

- Go 1.23+
- Node.js 18+

**Linux (for desktop builds):**
```bash
sudo apt install -y libgtk-3-dev libwebkit2gtk-4.1-dev build-essential
```

## Quick Start

```bash
# Install dependencies
make deps

# Build CSS
make build-css

# Run web server (with hot-reload)
make dev-server

# OR run desktop app
make dev-desktop
```

## Development

For CSS hot-reload:
```bash
# Terminal 1: CSS watcher
make watch-css

# Terminal 2: Server
make dev-server
```

## Project Structure

```
├── cmd/
│   ├── server/      # Web server entry point
│   └── desktop/     # Desktop app entry point
├── internal/
│   ├── config/      # Configuration
│   ├── handlers/    # HTTP handlers (shared)
│   ├── middleware/  # Middleware
│   └── templates/   # HTML templates + static files
├── frontend/        # Tailwind CSS build
└── Makefile         # Build commands
```

## Building for Production

```bash
# Build web server binary
make build-server

# Build desktop app
make build-desktop
```

## Next Steps

1. Add your business logic
2. Create new handlers in `internal/handlers/`
3. Add templates in `internal/templates/pages/`
4. Use HTMX for dynamic content
5. Style with Tailwind CSS

## Key Concepts

- **Mode Detection**: App detects if running as desktop or web server
- **Shared Handlers**: Same HTTP handlers work for both modes
- **Template Embedding**: Templates embedded in binary for portability
- **HTMX**: Server-rendered HTML for interactive UIs without heavy JavaScript

## License

MIT
```

## Running the Project

After creating all files above:

```bash
# Install all dependencies
make deps

# Build CSS once
make build-css

# Run web server with hot-reload
make dev-server

# OR run desktop app
make dev-desktop
```

## Key Concepts for AI Agents

### 1. **Hybrid Architecture**
- Two entry points: `cmd/server/` (web) and `cmd/desktop/` (desktop)
- Same handlers, templates, and business logic shared between both
- Config detects mode: `IsDesktopApp` flag determines behavior

### 2. **Mode-Aware Routing**
- Desktop: No authentication, single default user, embedded server
- Web: Optional session-based auth, multi-user support
- Use `c.Locals("isDesktopApp")` to conditionally render UI elements

### 3. **Template System**
- Templates embedded via `//go:embed` for portability
- Base layout + content pattern: `layouts/base.html` wraps `pages/*.html`
- HTMX targets partials for dynamic updates without full page reload

### 4. **Frontend Stack**
- HTMX: Server-rendered HTML, no JSON APIs needed
- Alpine.js: Minimal client-side state (form inputs, modals)
- Tailwind CSS: Utility classes, purged in production build

### 5. **Development Workflow**
- Air watches Go files, auto-rebuilds and restarts server
- Tailwind watch mode (`make watch-css`) rebuilds CSS on template changes
- Desktop mode requires manual restart (Wails doesn't support hot-reload)

### 6. **Important Notes**
- Replace `github.com/username/project-name` with actual module name
- Templates embedded = changes require restart (unless using Air)
- Static files served from `internal/templates/static/`
- Desktop builds require platform-specific dependencies (GTK on Linux)
- Air only works for web server mode, not desktop mode

### 7. **Extending the Starter**
- Add routes in both `cmd/server/main.go` and `cmd/desktop/main.go`
- Create handlers in `internal/handlers/`
- Add pages in `internal/templates/pages/`
- Use HTMX attributes for dynamic content: `hx-get`, `hx-post`, etc.
- Add business logic as needed (services, repositories, etc.)

### 8. **Common Patterns**

**Adding a new page:**
1. Create `internal/templates/pages/mypage.html`
2. Add route in both main.go files: `app.Get("/mypage", handler.MyPage)`
3. Handler renders: `c.Render("pages/mypage", data, "layouts/base")`

**Adding HTMX interaction:**
1. Create partial in `internal/templates/partials/mypartial.html`
2. Add endpoint: `app.Post("/api/action", handler.Action)`
3. Handler returns partial: `c.Render("partials/mypartial", data)`
4. Use HTMX: `<button hx-post="/api/action" hx-target="#result">Click</button>`

**Conditional rendering for modes:**
```html
{{if .IsDesktopApp}}
    <p>Desktop-only content</p>
{{else}}
    <a href="/login">Web-only login</a>
{{end}}
```

This starter provides the minimal infrastructure. Build your application logic on top of it.
