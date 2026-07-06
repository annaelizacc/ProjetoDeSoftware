from database.db import db
from models.feedback import Feedback
from models.palestra import Palestra
from models.usuario import Usuario


class FeedbackService:
    """Regras de negócio dos Feedbacks (comentários textuais)."""

    @staticmethod
    def listar_por_palestra(palestra_id):
        return Feedback.query.filter_by(palestra_id=palestra_id).all()

    @staticmethod
    def buscar_por_id(feedback_id):
        feedback = Feedback.query.get(feedback_id)
        if not feedback:
            raise ValueError("Feedback não encontrado.")
        return feedback

    @staticmethod
    def registrar_comentario(usuario_id, palestra_id, comentario):
        if not comentario or not comentario.strip():
            raise ValueError("O comentário não pode ser vazio.")
        if not Usuario.query.get(usuario_id):
            raise ValueError("Usuário informado não existe.")
        if not Palestra.query.get(palestra_id):
            raise ValueError("Palestra informada não existe.")

        feedback = Feedback(comentario=comentario.strip(), usuario_id=usuario_id, palestra_id=palestra_id)
        db.session.add(feedback)
        db.session.commit()
        return feedback

    @staticmethod
    def deletar(feedback_id):
        feedback = FeedbackService.buscar_por_id(feedback_id)
        db.session.delete(feedback)
        db.session.commit()
