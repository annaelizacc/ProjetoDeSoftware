"""
Controller: Participação (inscrições).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.participacao.criar_inscricao_service import CriarInscricaoService
from backend.services.participacao.cancelar_inscricao_service import CancelarInscricaoService


class ParticipacaoController:
    """Controller responsável pelos endpoints de inscrição/cancelamento."""

    @staticmethod
    @tratar_erros
    def criar():
        dados = request.get_json() or {}
        inscricao = CriarInscricaoService().execute(
            dados.get("id_usuario"), dados.get("id_palestra")
        )
        return jsonify(inscricao.to_dict()), 201

    @staticmethod
    @tratar_erros
    def cancelar():
        dados = request.get_json() or {}
        CancelarInscricaoService().execute(dados.get("id_usuario"), dados.get("id_palestra"))
        return jsonify({"mensagem": "Inscrição cancelada e vaga devolvida."})


participacao_bp = Blueprint("participacoes", __name__, url_prefix="/api/inscricoes")
participacao_bp.add_url_rule("", view_func=ParticipacaoController.criar, methods=["POST"])
participacao_bp.add_url_rule("", view_func=ParticipacaoController.cancelar, methods=["DELETE"])
