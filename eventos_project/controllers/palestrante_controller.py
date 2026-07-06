from flask import Blueprint, request, jsonify

from services.palestrante_service import PalestranteService
from controllers.utils import handle_errors

palestrante_bp = Blueprint("palestrante", __name__)


@palestrante_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    palestrantes = PalestranteService.listar_todos()
    return jsonify([p.to_dict() for p in palestrantes]), 200


@palestrante_bp.route("/<int:palestrante_id>", methods=["GET"])
@handle_errors
def buscar_por_id(palestrante_id):
    palestrante = PalestranteService.buscar_por_id(palestrante_id)
    return jsonify(palestrante.to_dict()), 200


@palestrante_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    palestrante = PalestranteService.criar(dados)
    return jsonify(palestrante.to_dict()), 201


@palestrante_bp.route("/<int:palestrante_id>", methods=["PUT"])
@handle_errors
def atualizar(palestrante_id):
    dados = request.get_json() or {}
    palestrante = PalestranteService.atualizar(palestrante_id, dados)
    return jsonify(palestrante.to_dict()), 200


@palestrante_bp.route("/<int:palestrante_id>", methods=["DELETE"])
@handle_errors
def deletar(palestrante_id):
    PalestranteService.deletar(palestrante_id)
    return jsonify({"mensagem": "Palestrante removido com sucesso."}), 200
