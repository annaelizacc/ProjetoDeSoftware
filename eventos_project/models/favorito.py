from datetime import date

from database.db import db


class Favorito(db.Model):
    """
    Marcação de uma Palestra como favorita por um Usuario.
    Relacionamentos:
      - N:1 com Usuario
      - N:1 com Palestra
    """

    __tablename__ = "favorito"

    id = db.Column(db.Integer, primary_key=True)
    data_favoritacao = db.Column(db.Date, default=date.today)

    usuario_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    palestra_id = db.Column(db.Integer, db.ForeignKey("palestra.id"), nullable=False)

    usuario = db.relationship("Usuario", back_populates="favoritos")
    palestra = db.relationship("Palestra", back_populates="favoritos")

    __table_args__ = (
        db.UniqueConstraint("usuario_id", "palestra_id", name="uq_favorito_usuario_palestra"),
    )

    def __init__(self, usuario_id, palestra_id):
        self.usuario_id = usuario_id
        self.palestra_id = palestra_id

    def to_dict(self):
        return {
            "id": self.id,
            "data_favoritacao": self.data_favoritacao.isoformat() if self.data_favoritacao else None,
            "usuario_id": self.usuario_id,
            "palestra_id": self.palestra_id,
        }

    def __repr__(self):
        return f"<Favorito {self.id} - usuario {self.usuario_id} / palestra {self.palestra_id}>"
