"""Healthcare API package."""

from .app import APP_VERSION, DEPLOYMENT_COLOR, ENVIRONMENT, SERVICE_NAME, app, patients_db

__all__ = [
	"app",
	"patients_db",
	"APP_VERSION",
	"DEPLOYMENT_COLOR",
	"ENVIRONMENT",
	"SERVICE_NAME",
]
