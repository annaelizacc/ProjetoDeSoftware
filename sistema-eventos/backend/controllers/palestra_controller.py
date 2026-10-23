"""
Controller: Palestra.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Expõe o CRUD completo de palestras (listar com filtros, detalhes, criar,
atualizar e remover).

Acesso (P01): consultar exige login; criar, atualizar e remover são só
para organizadores. Os detalhes mostram se a pessoa logada está inscrita
e se favoritou, usando o usuário do token (o `?id_usuario=` da URL é
ignorado).

Desde a F08, criar, atualizar e remover conferem também se o evento da
palestra é do organizador logado (ou se ele é administrador). Ao
atualizar, se o `id_evento` mudar, o evento de destino também precisa
ser dele: ninguém "move" uma palestra para o evento de outra pessoa.
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import (
    login_obrigatorio,
    somente_organizador,
    verificar_dono_da_palestra,
    verificar_dono_do_evento,
)
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
    @login_obrigatorio
    def listar():
        return jsonify(
            ListarPalestrasService().execute(
                request.args.get("id_evento", type=int),
                request.args.get("tema"),
            )
        )

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def detalhes(id_palestra):
        return jsonify(
            BuscarPalestraService().execute(
                id_palestra, g.usuario.id_usuario
            )
        )

    @staticmethod
    @tratar_erros
    @somente_organizador
    def criar():
        dados = request.get_json() or {}
        # Sem `id_evento`, o Service responde que o campo é obrigatório.
        if dados.get("id_evento"):
            verificar_dono_do_evento(dados["id_evento"])
        palestra = CriarPalestraService().execute(dados)
        return jsonify(palestra.to_dict()), 201

    @staticmethod
    @tratar_erros
    @somente_organizador
    def atualizar(id_palestra):
        verificar_dono_da_palestra(id_palestra)
        dados = request.get_json() or {}
        # `in`, e não `dados.get(...)`: um id "vazio" (0, null) também
        # passa pela conferência, que responde "Evento não encontrado."
        if "id_evento" in dados:
            verificar_dono_do_evento(dados["id_evento"])
        palestra = AtualizarPalestraService().execute(id_palestra, dados)
        return jsonify(palestra.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover(id_palestra):
        verificar_dono_da_palestra(id_palestra)
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
