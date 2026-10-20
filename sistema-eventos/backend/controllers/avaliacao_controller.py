"""
Controller: Avaliação.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Substitui o antigo `comentario_controller` (F19/D01): comentário passou a
ser um campo opcional da avaliação, junto com as estrelas. Criar, listar
por palestra, atualizar e remover avaliações. A tela "Avaliar" do Flutter
usa estas rotas (F06 e F07).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.avaliacao.criar_avaliacao_service import CriarAvaliacaoService
from backend.services.avaliacao.listar_avaliacoes_service import ListarAvaliacoesService
from backend.services.avaliacao.atualizar_avaliacao_service import AtualizarAvaliacaoService
from backend.services.avaliacao.remover_avaliacao_service import RemoverAvaliacaoService


class AvaliacaoController:
    """Controller responsável pelos endpoints de avaliações."""

    @staticmethod
    @tratar_erros
    def listar_por_palestra(id_palestra):
        return jsonify(ListarAvaliacoesService().execute(id_palestra))

    @staticmethod
    @tratar_erros
    def criar():
        avaliacao = CriarAvaliacaoService().execute(request.get_json() or {})
        return jsonify(avaliacao.to_dict()), 201

    @staticmethod
    @tratar_erros
    def atualizar(id_avaliacao):
        avaliacao = AtualizarAvaliacaoService().execute(
            id_avaliacao, request.get_json() or {}
        )
        return jsonify(avaliacao.to_dict())

    @staticmethod
    @tratar_erros
    def remover(id_avaliacao):
        RemoverAvaliacaoService().execute(id_avaliacao)
        return jsonify({"mensagem": "Avaliação removida."})


avaliacao_bp = Blueprint("avaliacoes", __name__, url_prefix="/api/avaliacoes")
avaliacao_bp.add_url_rule(
    "/palestra/<int:id_palestra>",
    view_func=AvaliacaoController.listar_por_palestra,
    methods=["GET"],
)
avaliacao_bp.add_url_rule("", view_func=AvaliacaoController.criar, methods=["POST"])
avaliacao_bp.add_url_rule(
    "/<int:id_avaliacao>", view_func=AvaliacaoController.atualizar, methods=["PUT", "PATCH"]
)
avaliacao_bp.add_url_rule(
    "/<int:id_avaliacao>", view_func=AvaliacaoController.remover, methods=["DELETE"]
)
