from flask import Blueprint, request, jsonify

from services.feedback_service import FeedbackService
from controllers.utils import handle_errors

feedback_bp = Blueprint("feedback", __name__)


@feedback_bp.route("/palestra/<int:palestra_id>", methods=["GET"])
@handle_errors
def listar_por_palestra(palestra_id):
    feedbacks = FeedbackService.listar_por_palestra(palestra_id)
    return jsonify([f.to_dict() for f in feedbacks]), 200


@feedback_bp.route("/", methods=["POST"])
@handle_errors
def registrar():
    dados = request.get_json() or {}
    feedback = FeedbackService.registrar_comentario(
        dados.get("usuario_id"), dados.get("palestra_id"), dados.get("comentario")
    )
    return jsonify(feedback.to_dict()), 201


@feedback_bp.route("/<int:feedback_id>", methods=["DELETE"])
@handle_errors
def deletar(feedback_id):
    FeedbackService.deletar(feedback_id)
    return jsonify({"mensagem": "Feedback removido com sucesso."}), 200
