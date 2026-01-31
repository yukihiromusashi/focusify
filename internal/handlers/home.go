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
