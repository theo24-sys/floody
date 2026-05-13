#!/bin/bash

# Run migrations
uv run python manage.py migrate --noinput

# Collect static files
uv run python manage.py collectstatic --noinput

# Start the ASGI server (handles both HTTP and WebSockets)
uv run uvicorn floodmap_backend.asgi:application --host 0.0.0.0 --port 8000
