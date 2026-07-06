from flask import Blueprint, request, jsonify

from services.inscricao_service import InscricaoService
from controllers.utils import handle_errors

inscricao_bp = Blueprint("inscricao", __name__)


@inscricao_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    inscricoes = InscricaoService.listar_todas()
    return jsonify([i.to_dict() for i in inscricoes]), 200


@inscricao_bp.route("/<int:inscricao_id>", methods=["GET"])
@handle_errors
def buscar_por_id(inscricao_id):
    inscricao = InscricaoService.buscar_por_id(inscricao_id)
    return jsonify(inscricao.to_dict()), 200


@inscricao_bp.route("/usuario/<int:usuario_id>", methods=["GET"])
@handle_errors
def listar_por_usuario(usuario_id):
    inscricoes = InscricaoService.listar_por_usuario(usuario_id)
    return jsonify([i.to_dict() for i in inscricoes]), 200


@inscricao_bp.route("/palestra/<int:palestra_id>", methods=["GET"])
@handle_errors
def listar_por_palestra(palestra_id):
    inscricoes = InscricaoService.listar_por_palestra(palestra_id)
    return jsonify([i.to_dict() for i in inscricoes]), 200


@inscricao_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    inscricao = InscricaoService.criar(dados.get("usuario_id"), dados.get("palestra_id"))
    return jsonify(inscricao.to_dict()), 201


@inscricao_bp.route("/<int:inscricao_id>/confirmar", methods=["PUT"])
@handle_errors
def confirmar(inscricao_id):
    InscricaoService.confirmar(inscricao_id)
    return jsonify({"mensagem": "Inscrição confirmada com sucesso."}), 200


@inscricao_bp.route("/<int:inscricao_id>", methods=["DELETE"])
@handle_errors
def cancelar(inscricao_id):
    InscricaoService.cancelar(inscricao_id)
    return jsonify({"mensagem": "Inscrição cancelada com sucesso."}), 200
