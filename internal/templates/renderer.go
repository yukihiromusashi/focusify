package templates

import (
	"embed"
	"html/template"
	"io"
)

//go:embed layouts/* pages/* partials/* static/*
var TemplateFS embed.FS

type Engine struct {
	templates *template.Template
}

func New() *Engine {
	// Parse all templates including layouts, pages, and partials
	templates := template.Must(template.ParseFS(TemplateFS, "layouts/*.html", "pages/*.html", "partials/*.html"))
	return &Engine{templates: templates}
}

func (e *Engine) Load() error {
	return nil
}

func (e *Engine) Render(out io.Writer, name string, binding interface{}, layout ...string) error {
	if len(layout) > 0 {
		// Execute the layout template which will include the content template
		return e.templates.ExecuteTemplate(out, layout[0], binding)
	}
	return e.templates.ExecuteTemplate(out, name, binding)
}
