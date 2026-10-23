"""
Controller: Locais do evento (F04, F14).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Expõe o CRUD dos locais (salas, auditórios, estandes) de um evento, com
o passo a passo de como chegar a cada um (campo `descricao`).

Acesso (P01 e F08): consultar exige login; criar, atualizar e remover
são só para o organizador dono do evento (ou um administrador).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.autenticacao import (
    login_obrigatorio,
    somente_organizador,
    verificar_dono_do_evento,
    verificar_dono_pelo_evento,
)
from backend.controllers.utils import tratar_erros
from backend.models.localizacao import Localizacao
from backend.services.localizacao.atualizar_local_service import AtualizarLocalService
from backend.services.localizacao.criar_local_service import CriarLocalService
from backend.services.localizacao.listar_locais_service import ListarLocaisService
from backend.services.localizacao.remover_local_service import RemoverLocalService


class LocalizacaoController:
    """Controller responsável pelos endpoints de locais."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar():
        id_evento = request.args.get("id_evento", type=int)
        return jsonify(ListarLocaisService().execute(id_evento))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def criar():
        dados = request.get_json() or {}
        # Sem `id_evento`, o Service responde que o campo é obrigatório.
        if dados.get("id_evento"):
            verificar_dono_do_evento(dados["id_evento"])
        local = CriarLocalService().execute(dados)
        return jsonify(local.to_dict()), 201

    @staticmethod
    @tratar_erros
    @somente_organizador
    def atualizar(id_localizacao):
        verificar_dono_pelo_evento(Localizacao, id_localizacao, "Local")
        local = AtualizarLocalService().execute(id_localizacao, request.get_json() or {})
        return jsonify(local.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover(id_localizacao):
        verificar_dono_pelo_evento(Localizacao, id_localizacao, "Local")
        RemoverLocalService().execute(id_localizacao)
        return jsonify({"mensagem": "Local removido."})


localizacao_bp = Blueprint("locais", __name__, url_prefix="/api/locais")
localizacao_bp.add_url_rule("", view_func=LocalizacaoController.listar, methods=["GET"])
localizacao_bp.add_url_rule("", view_func=LocalizacaoController.criar, methods=["POST"])
localizacao_bp.add_url_rule(
    "/<int:id_localizacao>", view_func=LocalizacaoController.atualizar, methods=["PUT", "PATCH"]
)
localizacao_bp.add_url_rule(
    "/<int:id_localizacao>", view_func=LocalizacaoController.remover, methods=["DELETE"]
)
