# --- Этап 1: Сборщик (Builder) ---
FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Этап 2: Финальный лёгкий образ (Runtime) ---
FROM python:3.12-slim

RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -s /bin/sh -m appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --chown=1000:1000 app/ ./app/

USER 1000:1000

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
