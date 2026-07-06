from flask import Flask
from flask_cors import CORS

from config import Config
from database.db import db


def create_app():
    """
    Application Factory do Flask.
    Centraliza a criação/configuração da app, do banco e das rotas.
    """
    app = Flask(__name__)
    app.config.from_object(Config)

    # Libera requisições do front-end (fetch) para a API
    CORS(app)

    # Inicializa o SQLAlchemy com a app
    db.init_app(app)

    # Importa os Models para que fiquem registrados nos metadados do SQLAlchemy
    with app.app_context():
        import models  # noqa: F401

    # --- Registro dos Controllers (Blueprints) ---
    from controllers.evento_controller import evento_bp
    from controllers.planta_baixa_controller import planta_baixa_bp
    from controllers.rota_controller import rota_bp
    from controllers.patrocinador_controller import patrocinador_bp
    from controllers.palestrante_controller import palestrante_bp
    from controllers.palestra_controller import palestra_bp
    from controllers.inscricao_controller import inscricao_bp
    from controllers.favorito_controller import favorito_bp
    from controllers.feedback_controller import feedback_bp
    from controllers.avaliacao_controller import avaliacao_bp
    from controllers.notificacao_controller import notificacao_bp
    from controllers.comunicado_controller import comunicado_bp
    from controllers.usuario_controller import usuario_bp
    from controllers.organizador_controller import organizador_bp
    from controllers.paginas_controller import paginas_bp

    app.register_blueprint(evento_bp, url_prefix="/api/eventos")
    app.register_blueprint(planta_baixa_bp, url_prefix="/api/plantas-baixa")
    app.register_blueprint(rota_bp, url_prefix="/api/rotas")
    app.register_blueprint(patrocinador_bp, url_prefix="/api/patrocinadores")
    app.register_blueprint(palestrante_bp, url_prefix="/api/palestrantes")
    app.register_blueprint(palestra_bp, url_prefix="/api/palestras")
    app.register_blueprint(inscricao_bp, url_prefix="/api/inscricoes")
    app.register_blueprint(favorito_bp, url_prefix="/api/favoritos")
    app.register_blueprint(feedback_bp, url_prefix="/api/feedbacks")
    app.register_blueprint(avaliacao_bp, url_prefix="/api/avaliacoes")
    app.register_blueprint(notificacao_bp, url_prefix="/api/notificacoes")
    app.register_blueprint(comunicado_bp, url_prefix="/api/comunicados")
    app.register_blueprint(usuario_bp, url_prefix="/api/usuarios")
    app.register_blueprint(organizador_bp, url_prefix="/api/organizadores")

    # Blueprint de páginas HTML (front-end), sem prefixo (rotas "amigáveis")
    app.register_blueprint(paginas_bp)

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=app.config["DEBUG"])
