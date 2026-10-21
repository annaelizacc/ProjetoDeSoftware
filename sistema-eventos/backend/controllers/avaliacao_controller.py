"""
Controller: Avaliação.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Substitui o antigo `comentario_controller` (F19/D01): comentário passou a
ser um campo opcional da avaliação, junto com as estrelas. Criar, listar
por palestra, atualizar e remover avaliações. A tela "Avaliar" do Flutter
usa estas rotas (F06 e F07).

Acesso (P01): todas as rotas exigem login. O autor de uma avaliação nova
é sempre a pessoa logada. Quem pode editar ou remover é decidido nos
Services (editar: só o autor; remover: o autor ou um organizador).
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio
from backend.controllers.utils import tratar_erros
from backend.services.avaliacao.criar_avaliacao_service import CriarAvaliacaoService
from backend.services.avaliacao.listar_avaliacoes_service import ListarAvaliacoesService
from backend.services.avaliacao.atualizar_avaliacao_service import AtualizarAvaliacaoService
from backend.services.avaliacao.remover_avaliacao_service import RemoverAvaliacaoService


class AvaliacaoController:
    """Controller responsável pelos endpoints de avaliações."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar_por_palestra(id_palestra):
        return jsonify(ListarAvaliacoesService().execute(id_palestra))

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def criar():
        dados = request.get_json() or {}
        dados["id_usuario"] = g.usuario.id_usuario
        avaliacao = CriarAvaliacaoService().execute(dados)
        return jsonify(avaliacao.to_dict()), 201

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def atualizar(id_avaliacao):
        avaliacao = AtualizarAvaliacaoService().execute(
            id_avaliacao, request.get_json() or {}, g.usuario
        )
        return jsonify(avaliacao.to_dict())

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def remover(id_avaliacao):
        RemoverAvaliacaoService().execute(id_avaliacao, g.usuario)
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
