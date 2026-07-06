from database.db import db


class Patrocinador(db.Model):
    """
    Patrocinador de um Evento.
    Relacionamentos:
      - N:1 com Evento
    """

    __tablename__ = "patrocinador"

    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    logo = db.Column(db.String(255))
    descricao = db.Column(db.String(500))

    evento_id = db.Column(db.Integer, db.ForeignKey("evento.id"), nullable=False)
    evento = db.relationship("Evento", back_populates="patrocinadores")

    def __init__(self, nome, evento_id, logo=None, descricao=None):
        self.nome = nome
        self.evento_id = evento_id
        self.logo = logo
        self.descricao = descricao

    def to_dict(self):
        return {
            "id": self.id,
            "nome": self.nome,
            "logo": self.logo,
            "descricao": self.descricao,
            "evento_id": self.evento_id,
        }

    def __repr__(self):
        return f"<Patrocinador {self.id} - {self.nome}>"
