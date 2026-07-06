from database.db import db
from models.associations import palestra_palestrante


class Palestrante(db.Model):
    """
    Palestrante que ministra palestras.
    Relacionamentos:
      - N:N com Palestra (via tabela palestra_palestrante)
    """

    __tablename__ = "palestrante"

    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    biografia = db.Column(db.Text)
    empresa = db.Column(db.String(150))
    foto = db.Column(db.String(255))

    palestras = db.relationship(
        "Palestra", secondary=palestra_palestrante, back_populates="palestrantes"
    )

    def __init__(self, nome, biografia=None, empresa=None, foto=None):
        self.nome = nome
        self.biografia = biografia
        self.empresa = empresa
        self.foto = foto

    def to_dict(self):
        return {
            "id": self.id,
            "nome": self.nome,
            "biografia": self.biografia,
            "empresa": self.empresa,
            "foto": self.foto,
        }

    def __repr__(self):
        return f"<Palestrante {self.id} - {self.nome}>"
