from flask import Blueprint, request, jsonify

from services.avaliacao_service import AvaliacaoService
from controllers.utils import handle_errors

avaliacao_bp = Blueprint("avaliacao", __name__)


@avaliacao_bp.route("/palestra/<int:palestra_id>", methods=["GET"])
@handle_errors
def listar_por_palestra(palestra_id):
    avaliacoes = AvaliacaoService.listar_por_palestra(palestra_id)
    return jsonify([a.to_dict() for a in avaliacoes]), 200


@avaliacao_bp.route("/palestra/<int:palestra_id>/media", methods=["GET"])
@handle_errors
def media_por_palestra(palestra_id):
    media = AvaliacaoService.media_por_palestra(palestra_id)
    return jsonify({"media_estrelas": media}), 200


@avaliacao_bp.route("/", methods=["POST"])
@handle_errors
def avaliar():
    dados = request.get_json() or {}
    avaliacao = AvaliacaoService.avaliar(
        dados.get("usuario_id"), dados.get("palestra_id"), dados.get("estrelas")
    )
    return jsonify(avaliacao.to_dict()), 201
