from datetime import datetime

from database.db import db


class Comunicado(db.Model):
    """
    Comunicado enviado por um Organizador.
    Relacionamentos:
      - N:1 com Organizador (usuario.id)
    """

    __tablename__ = "comunicado"

    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(150), nullable=False)
    mensagem = db.Column(db.Text, nullable=False)
    data_envio = db.Column(db.DateTime, default=datetime.utcnow)

    organizador_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    organizador = db.relationship(
        "Organizador", back_populates="comunicados", foreign_keys=[organizador_id]
    )

    def __init__(self, titulo, mensagem, organizador_id):
        self.titulo = titulo
        self.mensagem = mensagem
        self.organizador_id = organizador_id

    def to_dict(self):
        return {
            "id": self.id,
            "titulo": self.titulo,
            "mensagem": self.mensagem,
            "data_envio": self.data_envio.isoformat() if self.data_envio else None,
            "organizador_id": self.organizador_id,
        }

    def __repr__(self):
        return f"<Comunicado {self.id} - {self.titulo}>"
