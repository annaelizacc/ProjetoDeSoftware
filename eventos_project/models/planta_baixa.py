from database.db import db


class PlantaBaixa(db.Model):
    """
    Planta baixa de um Evento (relação 1:1).
    Relacionamentos:
      - 1:1 com Evento (dono da FK)
      - 1:N com Rota
    """

    __tablename__ = "planta_baixa"

    id = db.Column(db.Integer, primary_key=True)
    mapa = db.Column(db.String(255), nullable=False)  # caminho/URL da imagem do mapa

    evento_id = db.Column(db.Integer, db.ForeignKey("evento.id"), nullable=False, unique=True)
    evento = db.relationship("Evento", back_populates="planta_baixa")

    rotas = db.relationship("Rota", back_populates="planta_baixa", cascade="all, delete-orphan")

    def __init__(self, mapa, evento_id):
        self.mapa = mapa
        self.evento_id = evento_id

    def to_dict(self):
        return {
            "id": self.id,
            "mapa": self.mapa,
            "evento_id": self.evento_id,
        }

    def __repr__(self):
        return f"<PlantaBaixa {self.id} - evento {self.evento_id}>"
