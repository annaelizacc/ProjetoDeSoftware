"""
Controller: Comentário.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Também NOVO nesta refatoração, seguindo o mesmo raciocínio do
`usuario_controller`: a Model já existia, mas não havia endpoints. Criar,
listar por palestra, atualizar e remover comentários é uma extensão que
não interfere em nenhuma rota usada pelo Flutter atualmente.
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.comentario.criar_comentario_service import CriarComentarioService
from backend.services.comentario.listar_comentarios_service import ListarComentariosService
from backend.services.comentario.atualizar_comentario_service import AtualizarComentarioService
from backend.services.comentario.remover_comentario_service import RemoverComentarioService


class ComentarioController:
    """Controller responsável pelos endpoints de comentários."""

    @staticmethod
    @tratar_erros
    def listar_por_palestra(id_palestra):
        return jsonify(ListarComentariosService().execute(id_palestra))

    @staticmethod
    @tratar_erros
    def criar():
        comentario = CriarComentarioService().execute(request.get_json() or {})
        return jsonify(comentario.to_dict()), 201

    @staticmethod
    @tratar_erros
    def atualizar(id_comentario):
        comentario = AtualizarComentarioService().execute(
            id_comentario, request.get_json() or {}
        )
        return jsonify(comentario.to_dict())

    @staticmethod
    @tratar_erros
    def remover(id_comentario):
        RemoverComentarioService().execute(id_comentario)
        return jsonify({"mensagem": "Comentário removido."})


comentario_bp = Blueprint("comentarios", __name__, url_prefix="/api/comentarios")
comentario_bp.add_url_rule(
    "/palestra/<int:id_palestra>",
    view_func=ComentarioController.listar_por_palestra,
    methods=["GET"],
)
comentario_bp.add_url_rule("", view_func=ComentarioController.criar, methods=["POST"])
comentario_bp.add_url_rule(
    "/<int:id_comentario>", view_func=ComentarioController.atualizar, methods=["PUT", "PATCH"]
)
comentario_bp.add_url_rule(
    "/<int:id_comentario>", view_func=ComentarioController.remover, methods=["DELETE"]
)
