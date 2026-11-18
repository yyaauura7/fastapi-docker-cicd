# FastAPI Production Docker & GitHub Actions CI/CD

Production-ready containerized Python FastAPI service with automated testing and zero-manual-intervention deployment (CI/CD) via GitHub Actions behind an Nginx Reverse Proxy with HTTPS.

## Overview / О проекте
Этот проект демонстрирует полный цикл упаковки и автоматической доставки веб-приложения в продакшен (**CI/CD**). При каждом `git push` в ветку `main` пайплайн GitHub Actions автоматически собирает Docker-образ, проверяет работоспособность сервиса через эндпоинт `/health` и обновляет контейнер на облачном VPS (Ubuntu 24.04) без ручного вмешательства.

## Architecture / Архитектура
```text
[ CI/CD Delivery Pipeline ]
Developer (git push main) ──▶ GitHub ──▶ GitHub Actions Runner
                                               ├── 1. CI: docker build + /health check
                                               └── 2. CD: SSH deploy ──▶ VPS (docker compose up -d --build)

[ Client Traffic Flow ]
Browser (HTTPS :443) ──▶ UFW Firewall ──▶ Nginx Reverse Proxy (SSL) ──▶ 127.0.0.1:8000 (FastAPI Container)
```

## Security & Best Practices / Безопасность и стандарты
* **Multi-stage Docker Build:** Сборка зависимостей вынесена в отдельный этап `builder`, в финальный образ `python:3.12-slim` попадают только установленные пакеты и код приложения.
* **Non-root Container (`1000:1000`):** Процесс внутри контейнера запущен от непривилегированного пользователя `appuser` (`UID/GID 1000:1000`), исключая работу от имени `root`.
* **Network Isolation (`127.0.0.1`):** Порт контейнера привязан строго к локальному интерфейсу `127.0.0.1:8000` — прямой доступ извне закрыт, весь внешний трафик проходит только через Nginx с TLS-терминацией.
* **Secrets Management:** Переменные окружения изолированы в `.env` (исключён через `.gitignore`, в репозитории хранится только шаблон `.env.example`), а доступ для деплоя вынесен в зашифрованные **GitHub Secrets** с отдельным SSH-ключом.

## Project Structure / Структура проекта
```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml      # Пайплайн автоматической проверки (CI) и деплоя на VPS по SSH (CD)
├── app/
│   └── main.py             # Веб-приложение FastAPI с эндпоинтами / и /health
├── .dockerignore           # Исключение лишних файлов из контекста сборки Docker
├── .env.example            # Безопасный шаблон переменных окружения
├── .gitignore              # Защита секретов (.env) и системных файлов от попадания в Git
├── Dockerfile              # Двухэтапная сборка лёгкого production-образа от юзера 1000:1000
├── docker-compose.yml      # Конфигурация запуска контейнера на 127.0.0.1:8000 с healthcheck
├── requirements.txt        # Зафиксированные версии зависимостей Python
└── README.md               # Документация проекта
```

## Quick Start / Локальный запуск
1. Скопируйте шаблон переменных окружения:
   ```bash
   cp .env.example .env
   ```
2. Соберите образ и запустите контейнер в фоновом режиме:
   ```bash
   docker compose up -d --build
   ```
3. Проверьте состояние контейнера и ответ API:
   ```bash
   docker ps && curl http://127.0.0.1:8000/health
   ```
