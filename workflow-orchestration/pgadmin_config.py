# pgAdmin configuration to disable CSRF for development

# Disable CSRF protection completely
WTF_CSRF_ENABLED = False
WTF_CSRF_CHECK_DEFAULT = False

# Session configuration
SESSION_COOKIE_NAME = 'PGADMIN4_SESSION'
SESSION_COOKIE_DOMAIN = None
SESSION_COOKIE_PATH = '/'
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
COOKIE_DEFAULT_SECURE = False
COOKIE_DEFAULT_SAMESITE = 'Lax'
ENHANCED_COOKIE_PROTECTION = False

# Trust proxy headers
PROXY_X_FOR_COUNT = 1
PROXY_X_PROTO_COUNT = 1
PROXY_X_HOST_COUNT = 1
PROXY_X_PORT_COUNT = 1

# Allow localhost and localhost variations
ALLOWED_HOSTS = ['127.0.0.1', 'localhost', 'localhost:8085', '127.0.0.1:8085']

# Disable email verification
CHECK_EMAIL_DELIVERABILITY = False

# Session timeout in minutes
SESSION_EXPIRATION_TIME = 30

# Console log level (debug)
CONSOLE_LOG_LEVEL = 10

