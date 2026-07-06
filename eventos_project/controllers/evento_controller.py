from flask import Blueprint, request, jsonify

from services.evento_service import EventoService
from controllers.utils import handle_errors

evento_bp = Blueprint("evento", __name__)


@evento_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    eventos = EventoService.listar_todos()
    return jsonify([e.to_dict() for e in eventos]), 200


@evento_bp.route("/<int:evento_id>", methods=["GET"])
@handle_errors
def buscar_por_id(evento_id):
    evento = EventoService.buscar_por_id(evento_id)
    return jsonify(evento.to_dict()), 200


@evento_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    evento = EventoService.criar(dados)
    return jsonify(evento.to_dict()), 201


@evento_bp.route("/<int:evento_id>", methods=["PUT"])
@handle_errors
def atualizar(evento_id):
    dados = request.get_json() or {}
    evento = EventoService.atualizar(evento_id, dados)
    return jsonify(evento.to_dict()), 200


@evento_bp.route("/<int:evento_id>", methods=["DELETE"])
@handle_errors
def deletar(evento_id):
    EventoService.deletar(evento_id)
    return jsonify({"mensagem": "Evento removido com sucesso."}), 200


@evento_bp.route("/<int:evento_id>/programacao", methods=["GET"])
@handle_errors
def listar_programacao(evento_id):
    palestras = EventoService.listar_programacao(evento_id)
    return jsonify([p.to_dict() for p in palestras]), 200


@evento_bp.route("/<int:evento_id>/patrocinadores", methods=["GET"])
@handle_errors
def listar_patrocinadores(evento_id):
    patrocinadores = EventoService.listar_patrocinadores(evento_id)
    return jsonify([p.to_dict() for p in patrocinadores]), 200
