"""
Controller: Participação (inscrições).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Acesso (P01): exige login. A inscrição é sempre da pessoa logada (o
`id_usuario` vem do token); um `id_usuario` enviado no corpo é ignorado.

Choque de horário (F16): quando a pessoa já tem inscrição em outra
palestra no mesmo horário, a resposta é 409 (conflito) com
`choque_horario: true` e a palestra que bate no horário. O app mostra o
aviso e, se a pessoa confirmar, envia de novo com `confirmar_choque: true`.
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio
from backend.controllers.utils import tratar_erros
from backend.services.participacao.criar_inscricao_service import (
    ChoqueDeHorario,
    CriarInscricaoService,
)
from backend.services.participacao.cancelar_inscricao_service import CancelarInscricaoService


class ParticipacaoController:
    """Controller responsável pelos endpoints de inscrição/cancelamento."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def criar():
        dados = request.get_json() or {}
        try:
            inscricao = CriarInscricaoService().execute(
                g.usuario.id_usuario,
                dados.get("id_palestra"),
                # Só `true` confirma: qualquer outro valor conta como não.
                confirmar_choque=dados.get("confirmar_choque") is True,
            )
        except ChoqueDeHorario as aviso:
            return jsonify({
                "erro": str(aviso),
                "choque_horario": True,
                "palestra_conflitante": aviso.palestra_conflitante.to_dict(),
            }), 409
        return jsonify(inscricao.to_dict()), 201

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def cancelar():
        dados = request.get_json() or {}
        CancelarInscricaoService().execute(g.usuario.id_usuario, dados.get("id_palestra"))
        return jsonify({"mensagem": "Inscrição cancelada e vaga devolvida."})


participacao_bp = Blueprint("participacoes", __name__, url_prefix="/api/inscricoes")
participacao_bp.add_url_rule("", view_func=ParticipacaoController.criar, methods=["POST"])
participacao_bp.add_url_rule("", view_func=ParticipacaoController.cancelar, methods=["DELETE"])
