from flask import Blueprint, request, jsonify

from services.rota_service import RotaService
from controllers.utils import handle_errors

rota_bp = Blueprint("rota", __name__)


@rota_bp.route("/planta/<int:planta_baixa_id>", methods=["GET"])
@handle_errors
def listar_por_planta(planta_baixa_id):
    rotas = RotaService.listar_por_planta(planta_baixa_id)
    return jsonify([r.to_dict() for r in rotas]), 200


@rota_bp.route("/<int:rota_id>", methods=["GET"])
@handle_errors
def buscar_por_id(rota_id):
    rota = RotaService.buscar_por_id(rota_id)
    return jsonify(rota.to_dict()), 200


@rota_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    rota = RotaService.criar(dados)
    return jsonify(rota.to_dict()), 201


@rota_bp.route("/<int:rota_id>", methods=["PUT"])
@handle_errors
def atualizar(rota_id):
    dados = request.get_json() or {}
    rota = RotaService.atualizar(rota_id, dados)
    return jsonify(rota.to_dict()), 200


@rota_bp.route("/<int:rota_id>", methods=["DELETE"])
@handle_errors
def deletar(rota_id):
    RotaService.deletar(rota_id)
    return jsonify({"mensagem": "Rota removida com sucesso."}), 200


@rota_bp.route("/<int:rota_id>/calcular", methods=["GET"])
@handle_errors
def calcular_rota(rota_id):
    resultado = RotaService.calcular_rota(rota_id)
    return jsonify({"resultado": resultado}), 200
