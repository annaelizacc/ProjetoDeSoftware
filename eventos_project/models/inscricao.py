from datetime import date

from database.db import db


class Inscricao(db.Model):
    """
    Inscrição de um Usuario em uma Palestra.
    Relacionamentos:
      - N:1 com Usuario
      - N:1 com Palestra
    """

    __tablename__ = "inscricao"

    id = db.Column(db.Integer, primary_key=True)
    status = db.Column(db.String(20), nullable=False, default="pendente")
    data_inscricao = db.Column(db.Date, default=date.today)

    usuario_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    palestra_id = db.Column(db.Integer, db.ForeignKey("palestra.id"), nullable=False)

    usuario = db.relationship("Usuario", back_populates="inscricoes")
    palestra = db.relationship("Palestra", back_populates="inscricoes")

    __table_args__ = (
        db.UniqueConstraint("usuario_id", "palestra_id", name="uq_inscricao_usuario_palestra"),
    )

    def __init__(self, usuario_id, palestra_id, status="pendente"):
        self.usuario_id = usuario_id
        self.palestra_id = palestra_id
        self.status = status

    def to_dict(self):
        return {
            "id": self.id,
            "status": self.status,
            "data_inscricao": self.data_inscricao.isoformat() if self.data_inscricao else None,
            "usuario_id": self.usuario_id,
            "palestra_id": self.palestra_id,
        }

    def __repr__(self):
        return f"<Inscricao {self.id} - usuario {self.usuario_id} / palestra {self.palestra_id}>"
