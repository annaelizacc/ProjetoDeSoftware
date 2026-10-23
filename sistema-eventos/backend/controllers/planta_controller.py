"""
Controller: Planta baixa do evento (F03, F14).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Como cada evento tem no máximo uma planta, ela é acessada pelo próprio
evento: `/api/eventos/<id_evento>/planta`.

Acesso (P01 e F08): consultar exige login; salvar é só para o
organizador dono do evento (ou um administrador).
"""

from flask import Blueprint, jsonify, request

from backend.controllers.autenticacao import (
    login_obrigatorio,
    somente_organizador,
    verificar_dono_do_evento,
)
from backend.controllers.utils import tratar_erros
from backend.services.planta.buscar_planta_service import BuscarPlantaService
from backend.services.planta.salvar_planta_service import SalvarPlantaService


class PlantaController:
    """Controller responsável pelos endpoints da planta baixa."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def buscar(id_evento):
        return jsonify(BuscarPlantaService().execute(id_evento))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def salvar(id_evento):
        verificar_dono_do_evento(id_evento)
        planta = SalvarPlantaService().execute(id_evento, request.get_json() or {})
        return jsonify(planta.to_dict())


planta_bp = Blueprint("plantas", __name__, url_prefix="/api/eventos")
planta_bp.add_url_rule(
    "/<int:id_evento>/planta", view_func=PlantaController.buscar, methods=["GET"]
)
planta_bp.add_url_rule(
    "/<int:id_evento>/planta", view_func=PlantaController.salvar, methods=["PUT"]
)
