import os
from fastapi import FastAPI

app = FastAPI(title="DevOps Portfolio API", version="1.0.1")


@app.get("/")
def read_root():
    return {
        "message": "Hello from Docker + GitHub Actions CI/CD!",
        "environment": os.getenv("APP_ENV", "development"),
        "version": "1.0.1",
    }


@app.get("/health")
def health_check():
    return {"status": "ok"}
