"""
Registro central de rotas (Blueprints) da aplicação Flask.

CAMADA: ponto de entrada HTTP, entre `app.py` e os Controllers.

Manter o registro dos Blueprints em um único lugar facilita enxergar,
de relance, todos os recursos que a API expõe.
"""

from backend.controllers.auth_controller import auth_bp
from backend.controllers.avaliacao_controller import avaliacao_bp
from backend.controllers.evento_controller import evento_bp
from backend.controllers.favorito_controller import favorito_bp
from backend.controllers.notificacao_controller import notificacao_bp
from backend.controllers.palestra_controller import palestra_bp
from backend.controllers.participacao_controller import participacao_bp
from backend.controllers.usuario_controller import usuario_bp


def registrar_rotas(app):
    """Ponto único para registrar os Blueprints da aplicação."""

    for blueprint in (
        auth_bp,
        usuario_bp,
        evento_bp,
        palestra_bp,
        participacao_bp,
        favorito_bp,
        notificacao_bp,
        avaliacao_bp,
    ):
        app.register_blueprint(blueprint)
