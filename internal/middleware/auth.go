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
