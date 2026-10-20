"""
Controller: Favorito.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.favorito.listar_favoritos_service import ListarFavoritosService
from backend.services.favorito.adicionar_favorito_service import AdicionarFavoritoService
from backend.services.favorito.remover_favorito_service import RemoverFavoritoService


class FavoritoController:
    """Controller responsável pelos endpoints de favoritos."""

    @staticmethod
    @tratar_erros
    def listar(id_usuario):
        return jsonify(ListarFavoritosService().execute(id_usuario))

    @staticmethod
    @tratar_erros
    def adicionar():
        dados = request.get_json() or {}
        favorito = AdicionarFavoritoService().execute(
            dados.get("id_usuario"), dados.get("id_palestra")
        )
        return jsonify(favorito.to_dict()), 201

    @staticmethod
    @tratar_erros
    def remover():
        dados = request.get_json() or {}
        RemoverFavoritoService().execute(dados.get("id_usuario"), dados.get("id_palestra"))
        return jsonify({"mensagem": "Favorito removido."})


favorito_bp = Blueprint("favoritos", __name__, url_prefix="/api/favoritos")
favorito_bp.add_url_rule(
    "/usuario/<int:id_usuario>", view_func=FavoritoController.listar, methods=["GET"]
)
favorito_bp.add_url_rule("", view_func=FavoritoController.adicionar, methods=["POST"])
favorito_bp.add_url_rule("", view_func=FavoritoController.remover, methods=["DELETE"])
