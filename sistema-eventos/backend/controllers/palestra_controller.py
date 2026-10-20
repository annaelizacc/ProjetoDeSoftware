"""
Controller: Palestra.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Expõe o CRUD completo de palestras (listar com filtros, detalhes, criar,
atualizar e remover).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.palestra.listar_palestras_service import ListarPalestrasService
from backend.services.palestra.buscar_palestra_service import BuscarPalestraService
from backend.services.palestra.criar_palestra_service import CriarPalestraService
from backend.services.palestra.atualizar_palestra_service import AtualizarPalestraService
from backend.services.palestra.remover_palestra_service import RemoverPalestraService


class PalestraController:
    """Controller responsável pelos endpoints de palestra."""

    @staticmethod
    @tratar_erros
    def listar():
        return jsonify(
            ListarPalestrasService().execute(
                request.args.get("id_evento", type=int),
                request.args.get("tema"),
            )
        )

    @staticmethod
    @tratar_erros
    def detalhes(id_palestra):
        return jsonify(
            BuscarPalestraService().execute(
                id_palestra, request.args.get("id_usuario", type=int)
            )
        )

    @staticmethod
    @tratar_erros
    def criar():
        palestra = CriarPalestraService().execute(request.get_json() or {})
        return jsonify(palestra.to_dict()), 201

    @staticmethod
    @tratar_erros
    def atualizar(id_palestra):
        palestra = AtualizarPalestraService().execute(id_palestra, request.get_json() or {})
        return jsonify(palestra.to_dict())

    @staticmethod
    @tratar_erros
    def remover(id_palestra):
        RemoverPalestraService().execute(id_palestra)
        return jsonify({"mensagem": "Palestra removida."})


palestra_bp = Blueprint("palestras", __name__, url_prefix="/api/palestras")
palestra_bp.add_url_rule("", view_func=PalestraController.listar, methods=["GET"])
palestra_bp.add_url_rule("", view_func=PalestraController.criar, methods=["POST"])
palestra_bp.add_url_rule(
    "/<int:id_palestra>", view_func=PalestraController.detalhes, methods=["GET"]
)
palestra_bp.add_url_rule(
    "/<int:id_palestra>", view_func=PalestraController.atualizar, methods=["PUT", "PATCH"]
)
palestra_bp.add_url_rule(
    "/<int:id_palestra>", view_func=PalestraController.remover, methods=["DELETE"]
)
