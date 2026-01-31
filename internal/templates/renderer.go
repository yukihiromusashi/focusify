package templates

import (
	"embed"
	"html/template"
	"io"
)

//go:embed layouts/* pages/* static/*
var TemplateFS embed.FS

type Engine struct {
	templates *template.Template
}

func New() *Engine {
	templates := template.Must(template.ParseFS(TemplateFS, "layouts/*.html", "pages/*.html"))
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
