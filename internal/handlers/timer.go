package handlers

import "github.com/gofiber/fiber/v3"

type TimerHandler struct{}

func NewTimerHandler() *TimerHandler {
	return &TimerHandler{}
}

func (h *TimerHandler) Index(c fiber.Ctx) error {
	return c.Render("pages/timer", fiber.Map{
		"Title":        "Timer - Focusify",
		"IsDesktopApp": c.Locals("isDesktopApp"),
	}, "layouts/base")
}
