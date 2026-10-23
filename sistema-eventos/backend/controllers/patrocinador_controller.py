"""
Controller: Patrocinador.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Lista os patrocinadores de um evento, usados pela tela "Patrocinadores"
do Flutter (F10, RF19). Desde a F14, o organizador também cadastra,
edita e remove os patrocinadores (com o logo enviado por
`POST /api/uploads`).

Acesso (P01 e F08): consultar exige login, como as outras rotas de
consulta; criar, atualizar e remover são só para o organizador dono do
evento (ou um administrador).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.autenticacao import (
    login_obrigatorio,
    somente_organizador,
    verificar_dono_do_evento,
    verificar_dono_pelo_evento,
)
from backend.controllers.utils import tratar_erros
from backend.models.patrocinador import Patrocinador
from backend.services.patrocinador.atualizar_patrocinador_service import (
    AtualizarPatrocinadorService,
)
from backend.services.patrocinador.criar_patrocinador_service import CriarPatrocinadorService
from backend.services.patrocinador.listar_patrocinadores_service import (
    ListarPatrocinadoresService,
)
from backend.services.patrocinador.remover_patrocinador_service import (
    RemoverPatrocinadorService,
)


class PatrocinadorController:
    """Controller responsável pelos endpoints de patrocinadores."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar():
        # `type=int`: um valor que não é número vira None, e o Service
        # responde "id_evento é obrigatório.".
        id_evento = request.args.get("id_evento", type=int)
        return jsonify(ListarPatrocinadoresService().execute(id_evento))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def criar():
        dados = request.get_json() or {}
        # Sem `id_evento`, o Service responde que o campo é obrigatório.
        if dados.get("id_evento"):
            verificar_dono_do_evento(dados["id_evento"])
        patrocinador = CriarPatrocinadorService().execute(dados)
        return jsonify(patrocinador.to_dict()), 201

    @staticmethod
    @tratar_erros
    @somente_organizador
    def atualizar(id_patrocinador):
        verificar_dono_pelo_evento(Patrocinador, id_patrocinador, "Patrocinador")
        dados = request.get_json() or {}
        patrocinador = AtualizarPatrocinadorService().execute(id_patrocinador, dados)
        return jsonify(patrocinador.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover(id_patrocinador):
        verificar_dono_pelo_evento(Patrocinador, id_patrocinador, "Patrocinador")
        RemoverPatrocinadorService().execute(id_patrocinador)
        return jsonify({"mensagem": "Patrocinador removido."})


patrocinador_bp = Blueprint("patrocinadores", __name__, url_prefix="/api/patrocinadores")
patrocinador_bp.add_url_rule("", view_func=PatrocinadorController.listar, methods=["GET"])
patrocinador_bp.add_url_rule("", view_func=PatrocinadorController.criar, methods=["POST"])
patrocinador_bp.add_url_rule(
    "/<int:id_patrocinador>", view_func=PatrocinadorController.atualizar, methods=["PUT", "PATCH"]
)
patrocinador_bp.add_url_rule(
    "/<int:id_patrocinador>", view_func=PatrocinadorController.remover, methods=["DELETE"]
)
