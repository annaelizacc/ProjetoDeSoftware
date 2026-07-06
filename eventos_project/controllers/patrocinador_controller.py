from flask import Blueprint, request, jsonify

from services.patrocinador_service import PatrocinadorService
from controllers.utils import handle_errors

patrocinador_bp = Blueprint("patrocinador", __name__)


@patrocinador_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    patrocinadores = PatrocinadorService.listar_todos()
    return jsonify([p.to_dict() for p in patrocinadores]), 200


@patrocinador_bp.route("/<int:patrocinador_id>", methods=["GET"])
@handle_errors
def buscar_por_id(patrocinador_id):
    patrocinador = PatrocinadorService.buscar_por_id(patrocinador_id)
    return jsonify(patrocinador.to_dict()), 200


@patrocinador_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    patrocinador = PatrocinadorService.criar(dados)
    return jsonify(patrocinador.to_dict()), 201


@patrocinador_bp.route("/<int:patrocinador_id>", methods=["PUT"])
@handle_errors
def atualizar(patrocinador_id):
    dados = request.get_json() or {}
    patrocinador = PatrocinadorService.atualizar(patrocinador_id, dados)
    return jsonify(patrocinador.to_dict()), 200


@patrocinador_bp.route("/<int:patrocinador_id>", methods=["DELETE"])
@handle_errors
def deletar(patrocinador_id):
    PatrocinadorService.deletar(patrocinador_id)
    return jsonify({"mensagem": "Patrocinador removido com sucesso."}), 200
