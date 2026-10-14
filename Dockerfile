# ---- Build stage ----
FROM python:3.12-slim AS builder

# Instalar dependencias de sistema necesarias para compilar paquetes Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root para seguridad
RUN useradd --no-create-home --shell /bin/bash appuser

# Directorio de trabajo
WORKDIR /app

# Copiar solo requirements primero (aprovecha cache de capas)
COPY requirements.txt .

# Instalar dependencias en directorio aislado
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ---- Runtime stage ----
FROM python:3.12-slim

# Instalar solo runtime deps (curl para healthcheck, ca-certificates para HTTPS)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar usuario desde builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias instaladas desde builder
COPY --from=builder /install /usr/local

# Copiar código de la aplicación
COPY app.py .

# Cambiar a usuario no-root
USER appuser

# Puerto que expone la aplicación
EXPOSE 8000

# Healthcheck para verificar que el servicio responde
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Comando por defecto para ejecutar la app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]