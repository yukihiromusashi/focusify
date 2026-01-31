# Focusify - Hybrid App Starter

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
