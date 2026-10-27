# Etapa de instalación: imagen oficial con versión específica
FROM python:3.12.8-slim-bookworm AS builder

WORKDIR /install

# Copiar primero el manifiesto para aprovechar la caché
COPY requirements.txt .

# Instalar dependencias en un directorio separado
RUN pip install --no-cache-dir --prefix=/install/deps -r requirements.txt


# Etapa final: entorno ligero de ejecución
FROM python:3.12.8-slim-bookworm AS runtime

WORKDIR /app

# Crear un usuario sin privilegios de administrador
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copiar las dependencias instaladas desde la etapa anterior
COPY --from=builder /install/deps /usr/local

# Copiar únicamente el código de la aplicación
COPY --chown=appuser:appuser app.py .

# Ejecutar la aplicación como usuario no root
USER appuser

# Documentar el puerto utilizado por Flask
EXPOSE 8080

# Ejecutar Python en formato exec, sin shell intermedio
CMD ["python", "app.py"]
