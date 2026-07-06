from flask import Blueprint, request, jsonify

from services.palestra_service import PalestraService
from controllers.utils import handle_errors

palestra_bp = Blueprint("palestra", __name__)


@palestra_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    nome = request.args.get("nome")
    if nome:
        palestras = PalestraService.pesquisar_por_nome(nome)
    else:
        palestras = PalestraService.listar_todas()
    return jsonify([p.to_dict() for p in palestras]), 200


@palestra_bp.route("/<int:palestra_id>", methods=["GET"])
@handle_errors
def buscar_por_id(palestra_id):
    palestra = PalestraService.buscar_por_id(palestra_id)
    return jsonify(palestra.to_dict()), 200


@palestra_bp.route("/", methods=["POST"])
@handle_errors
def criar():
    dados = request.get_json() or {}
    palestra = PalestraService.criar(dados)
    return jsonify(palestra.to_dict()), 201


@palestra_bp.route("/<int:palestra_id>", methods=["PUT"])
@handle_errors
def atualizar(palestra_id):
    dados = request.get_json() or {}
    palestra = PalestraService.atualizar(palestra_id, dados)
    return jsonify(palestra.to_dict()), 200


@palestra_bp.route("/<int:palestra_id>", methods=["DELETE"])
@handle_errors
def deletar(palestra_id):
    PalestraService.deletar(palestra_id)
    return jsonify({"mensagem": "Palestra removida com sucesso."}), 200


@palestra_bp.route("/<int:palestra_id>/detalhes", methods=["GET"])
@handle_errors
def exibir_detalhes(palestra_id):
    detalhes = PalestraService.exibir_detalhes(palestra_id)
    return jsonify(detalhes), 200


@palestra_bp.route("/<int:palestra_id>/vagas", methods=["GET"])
@handle_errors
def verificar_vagas(palestra_id):
    vagas = PalestraService.verificar_vagas(palestra_id)
    return jsonify({"vagas_disponiveis": vagas}), 200
