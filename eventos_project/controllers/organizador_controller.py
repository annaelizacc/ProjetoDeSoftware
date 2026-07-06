from flask import Blueprint, request, jsonify

from services.organizador_service import OrganizadorService
from controllers.utils import handle_errors

organizador_bp = Blueprint("organizador", __name__)


@organizador_bp.route("/cadastro", methods=["POST"])
@handle_errors
def cadastrar():
    dados = request.get_json() or {}
    organizador = OrganizadorService.cadastrar(
        dados.get("nome"), dados.get("email"), dados.get("senha")
    )
    return jsonify(organizador.to_dict()), 201


@organizador_bp.route("/<int:organizador_id>/inscricoes", methods=["GET"])
@handle_errors
def gerenciar_inscricoes(organizador_id):
    # organizador_id validado no service; filtros opcionais via query string
    OrganizadorService.buscar_por_id(organizador_id)
    palestra_id = request.args.get("palestra_id", type=int)
    status = request.args.get("status")
    inscricoes = OrganizadorService.gerenciar_inscricoes(palestra_id=palestra_id, status=status)
    return jsonify([i.to_dict() for i in inscricoes]), 200


@organizador_bp.route("/<int:organizador_id>/comunicado", methods=["POST"])
@handle_errors
def enviar_comunicado(organizador_id):
    dados = request.get_json() or {}
    comunicado = OrganizadorService.enviar_comunicado(
        organizador_id, dados.get("titulo"), dados.get("mensagem")
    )
    return jsonify(comunicado.to_dict()), 201
