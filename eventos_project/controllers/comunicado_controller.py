from flask import Blueprint, request, jsonify

from services.comunicado_service import ComunicadoService
from controllers.utils import handle_errors

comunicado_bp = Blueprint("comunicado", __name__)


@comunicado_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    comunicados = ComunicadoService.listar_todos()
    return jsonify([c.to_dict() for c in comunicados]), 200


@comunicado_bp.route("/<int:comunicado_id>", methods=["GET"])
@handle_errors
def buscar_por_id(comunicado_id):
    comunicado = ComunicadoService.buscar_por_id(comunicado_id)
    return jsonify(comunicado.to_dict()), 200


@comunicado_bp.route("/<int:comunicado_id>", methods=["DELETE"])
@handle_errors
def deletar(comunicado_id):
    ComunicadoService.deletar(comunicado_id)
    return jsonify({"mensagem": "Comunicado removido com sucesso."}), 200
