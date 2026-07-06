from flask import Blueprint, request, jsonify

from services.notificacao_service import NotificacaoService
from controllers.utils import handle_errors

notificacao_bp = Blueprint("notificacao", __name__)


@notificacao_bp.route("/usuario/<int:usuario_id>", methods=["GET"])
@handle_errors
def listar_por_usuario(usuario_id):
    notificacoes = NotificacaoService.listar_por_usuario(usuario_id)
    return jsonify([n.to_dict() for n in notificacoes]), 200


@notificacao_bp.route("/", methods=["POST"])
@handle_errors
def enviar():
    dados = request.get_json() or {}
    notificacao = NotificacaoService.enviar(dados.get("usuario_id"), dados.get("mensagem"))
    return jsonify(notificacao.to_dict()), 201
