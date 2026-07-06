from flask import Blueprint, request, jsonify

from services.favorito_service import FavoritoService
from controllers.utils import handle_errors

favorito_bp = Blueprint("favorito", __name__)


@favorito_bp.route("/usuario/<int:usuario_id>", methods=["GET"])
@handle_errors
def listar_por_usuario(usuario_id):
    favoritos = FavoritoService.listar_por_usuario(usuario_id)
    return jsonify([f.to_dict() for f in favoritos]), 200


@favorito_bp.route("/", methods=["POST"])
@handle_errors
def adicionar():
    dados = request.get_json() or {}
    favorito = FavoritoService.adicionar(dados.get("usuario_id"), dados.get("palestra_id"))
    return jsonify(favorito.to_dict()), 201


@favorito_bp.route("/", methods=["DELETE"])
@handle_errors
def remover():
    dados = request.get_json() or {}
    FavoritoService.remover(dados.get("usuario_id"), dados.get("palestra_id"))
    return jsonify({"mensagem": "Favorito removido com sucesso."}), 200
