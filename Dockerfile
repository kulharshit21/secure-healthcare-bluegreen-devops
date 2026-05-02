# Multi-stage build for production-ready Flask Healthcare API

# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Copy requirements and install dependencies
COPY app/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Set metadata
LABEL maintainer="DevOps Team"
LABEL description="Secure Healthcare API for Blue-Green Deployment Demo"
LABEL version="1.0"

# Set working directory
WORKDIR /app

# Create explicit non-root UID/GID for predictable runtime identity
RUN groupadd -r healthcare -g 1000 && useradd -r -u 1000 -g healthcare healthcare

# Install runtime dependencies in final image to ensure import paths are valid
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=healthcare:healthcare app/app.py .
COPY --chown=healthcare:healthcare app/__init__.py .

# Set environment variables for Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app

# Make filesystem read-only where possible (optional, can be disabled if app needs writes)
RUN mkdir -p /app/tmp && chown healthcare:healthcare /app/tmp

# Switch to non-root user/group
USER healthcare:healthcare

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "app:app"]
