"""
Controller: Palestrantes do evento (F05, F14).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Expõe o CRUD dos palestrantes. Desde a F14, cada palestrante pertence a
um evento: a lista é sempre de um evento (`?id_evento=`), com busca
opcional por nome (`?busca=`, RF13). O detalhe de um palestrante
(`GET /api/palestrantes/<id>`) atende a tela de perfil (RF14).

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
from backend.models.palestrante import Palestrante
from backend.services.palestrante.atualizar_palestrante_service import (
    AtualizarPalestranteService,
)
from backend.services.palestrante.buscar_palestrante_service import BuscarPalestranteService
from backend.services.palestrante.criar_palestrante_service import CriarPalestranteService
from backend.services.palestrante.listar_palestrantes_service import (
    ListarPalestrantesService,
)
from backend.services.palestrante.remover_palestrante_service import (
    RemoverPalestranteService,
)


class PalestranteController:
    """Controller responsável pelos endpoints de palestrantes."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar():
        return jsonify(
            ListarPalestrantesService().execute(
                request.args.get("id_evento", type=int),
                request.args.get("busca"),
            )
        )

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def buscar(id_palestrante):
        return jsonify(BuscarPalestranteService().execute(id_palestrante).to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def criar():
        dados = request.get_json() or {}
        if dados.get("id_evento"):
            verificar_dono_do_evento(dados["id_evento"])
        palestrante = CriarPalestranteService().execute(dados)
        return jsonify(palestrante.to_dict()), 201

    @staticmethod
    @tratar_erros
    @somente_organizador
    def atualizar(id_palestrante):
        verificar_dono_pelo_evento(Palestrante, id_palestrante, "Palestrante")
        dados = request.get_json() or {}
        palestrante = AtualizarPalestranteService().execute(id_palestrante, dados)
        return jsonify(palestrante.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover(id_palestrante):
        verificar_dono_pelo_evento(Palestrante, id_palestrante, "Palestrante")
        RemoverPalestranteService().execute(id_palestrante)
        return jsonify({"mensagem": "Palestrante removido."})


palestrante_bp = Blueprint("palestrantes", __name__, url_prefix="/api/palestrantes")
palestrante_bp.add_url_rule("", view_func=PalestranteController.listar, methods=["GET"])
palestrante_bp.add_url_rule("", view_func=PalestranteController.criar, methods=["POST"])
palestrante_bp.add_url_rule(
    "/<int:id_palestrante>", view_func=PalestranteController.buscar, methods=["GET"]
)
palestrante_bp.add_url_rule(
    "/<int:id_palestrante>", view_func=PalestranteController.atualizar, methods=["PUT", "PATCH"]
)
palestrante_bp.add_url_rule(
    "/<int:id_palestrante>", view_func=PalestranteController.remover, methods=["DELETE"]
)
