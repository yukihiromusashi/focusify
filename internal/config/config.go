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
