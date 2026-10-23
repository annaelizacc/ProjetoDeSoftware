"""
Controller: Patrocinador.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Lista os patrocinadores de um evento, usados pela tela "Patrocinadores"
do Flutter (F10, RF19). O cadastro pelo organizador (criar, editar,
remover e enviar o logo) vem com a F14.

Acesso (P01): consultar exige login, como as outras rotas de consulta.
"""

from flask import Blueprint, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio
from backend.controllers.utils import tratar_erros
from backend.services.patrocinador.listar_patrocinadores_service import (
    ListarPatrocinadoresService,
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


patrocinador_bp = Blueprint("patrocinadores", __name__, url_prefix="/api/patrocinadores")
patrocinador_bp.add_url_rule("", view_func=PatrocinadorController.listar, methods=["GET"])
