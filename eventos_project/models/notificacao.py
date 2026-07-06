from datetime import datetime

from database.db import db


class Notificacao(db.Model):
    """
    Notificação enviada a um Usuario (ex: gerada a partir de um Comunicado).
    Relacionamentos:
      - N:1 com Usuario
    """

    __tablename__ = "notificacao"

    id = db.Column(db.Integer, primary_key=True)
    mensagem = db.Column(db.String(255), nullable=False)
    data_envio = db.Column(db.DateTime, default=datetime.utcnow)

    usuario_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    usuario = db.relationship("Usuario", back_populates="notificacoes")

    def __init__(self, mensagem, usuario_id):
        self.mensagem = mensagem
        self.usuario_id = usuario_id

    def to_dict(self):
        return {
            "id": self.id,
            "mensagem": self.mensagem,
            "data_envio": self.data_envio.isoformat() if self.data_envio else None,
            "usuario_id": self.usuario_id,
        }

    def __repr__(self):
        return f"<Notificacao {self.id} - usuario {self.usuario_id}>"
