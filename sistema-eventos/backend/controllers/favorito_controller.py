"""
Controller: Favorito.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Acesso (P01): exige login. A lista só pode ser vista pela própria pessoa,
e adicionar ou remover vale sempre para a pessoa logada (o `id_usuario`
vem do token; um `id_usuario` enviado no corpo é ignorado).
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio, verificar_acesso_ao_usuario
from backend.controllers.utils import tratar_erros
from backend.services.favorito.listar_favoritos_service import ListarFavoritosService
from backend.services.favorito.adicionar_favorito_service import AdicionarFavoritoService
from backend.services.favorito.remover_favorito_service import RemoverFavoritoService


class FavoritoController:
    """Controller responsável pelos endpoints de favoritos."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar(id_usuario):
        verificar_acesso_ao_usuario(id_usuario)
        return jsonify(ListarFavoritosService().execute(id_usuario))

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def adicionar():
        dados = request.get_json() or {}
        favorito = AdicionarFavoritoService().execute(
            g.usuario.id_usuario, dados.get("id_palestra")
        )
        return jsonify(favorito.to_dict()), 201

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def remover():
        dados = request.get_json() or {}
        RemoverFavoritoService().execute(g.usuario.id_usuario, dados.get("id_palestra"))
        return jsonify({"mensagem": "Favorito removido."})


favorito_bp = Blueprint("favoritos", __name__, url_prefix="/api/favoritos")
favorito_bp.add_url_rule(
    "/usuario/<int:id_usuario>", view_func=FavoritoController.listar, methods=["GET"]
)
favorito_bp.add_url_rule("", view_func=FavoritoController.adicionar, methods=["POST"])
favorito_bp.add_url_rule("", view_func=FavoritoController.remover, methods=["DELETE"])
