from flask import Blueprint, request, jsonify

from services.planta_baixa_service import PlantaBaixaService
from controllers.utils import handle_errors

planta_baixa_bp = Blueprint("planta_baixa", __name__)


@planta_baixa_bp.route("/<int:planta_id>", methods=["GET"])
@handle_errors
def buscar_por_id(planta_id):
    planta = PlantaBaixaService.buscar_por_id(planta_id)
    return jsonify(planta.to_dict()), 200


@planta_baixa_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    planta = PlantaBaixaService.criar(dados)
    return jsonify(planta.to_dict()), 201


@planta_baixa_bp.route("/<int:planta_id>", methods=["PUT"])
@handle_errors
def atualizar(planta_id):
    dados = request.get_json() or {}
    planta = PlantaBaixaService.atualizar(planta_id, dados)
    return jsonify(planta.to_dict()), 200


@planta_baixa_bp.route("/<int:planta_id>", methods=["DELETE"])
@handle_errors
def deletar(planta_id):
    PlantaBaixaService.deletar(planta_id)
    return jsonify({"mensagem": "Planta baixa removida com sucesso."}), 200


@planta_baixa_bp.route("/evento/<int:evento_id>", methods=["GET"])
@handle_errors
def buscar_por_evento(evento_id):
    planta = PlantaBaixaService.buscar_por_evento(evento_id)
    return jsonify(planta.to_dict()), 200


@planta_baixa_bp.route("/evento/<int:evento_id>/mapa", methods=["GET"])
@handle_errors
def vizualizar_mapa(evento_id):
    mapa = PlantaBaixaService.vizualizar_mapa(evento_id)
    return jsonify({"mapa": mapa}), 200
