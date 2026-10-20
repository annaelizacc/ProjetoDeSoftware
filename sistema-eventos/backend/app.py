from flask import Flask, jsonify
from flask_cors import CORS

from backend.config import Config
from backend.extensions import db
from backend.routes import registrar_rotas
from backend import models  # noqa: F401 - registra os Models no SQLAlchemy


def criar_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app, supports_credentials=True)
    db.init_app(app)
    registrar_rotas(app)

    @app.get("/")
    def inicio():
        return jsonify({"status": "API do Sistema de Eventos no ar"})

    @app.get("/api/health")
    def health():
        return jsonify({"status": "ok"})

    return app


app = criar_app()

if __name__ == "__main__":
    # Execute database/sistema_eventos_atualizado.sql antes de iniciar a API.
    # O SQL mantém também as tabelas que não são usadas diretamente pelo app.
    app.run(host="0.0.0.0", port=5000, debug=True)