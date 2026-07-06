from datetime import date

from database.db import db


class Feedback(db.Model):
    """
    Comentário de um Usuario sobre uma Palestra.
    Relacionamentos:
      - N:1 com Usuario
      - N:1 com Palestra

    (Mantido como entidade separada de Avaliacao, conforme decisão
    tomada na Etapa 1: Feedback = comentário textual, Avaliacao = nota.)
    """

    __tablename__ = "feedback"

    id = db.Column(db.Integer, primary_key=True)
    comentario = db.Column(db.Text, nullable=False)
    data = db.Column(db.Date, default=date.today)

    usuario_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    palestra_id = db.Column(db.Integer, db.ForeignKey("palestra.id"), nullable=False)

    usuario = db.relationship("Usuario", back_populates="feedbacks")
    palestra = db.relationship("Palestra", back_populates="feedbacks")

    def __init__(self, comentario, usuario_id, palestra_id):
        self.comentario = comentario
        self.usuario_id = usuario_id
        self.palestra_id = palestra_id

    def to_dict(self):
        return {
            "id": self.id,
            "comentario": self.comentario,
            "data": self.data.isoformat() if self.data else None,
            "usuario_id": self.usuario_id,
            "palestra_id": self.palestra_id,
        }

    def __repr__(self):
        return f"<Feedback {self.id} - usuario {self.usuario_id} / palestra {self.palestra_id}>"
