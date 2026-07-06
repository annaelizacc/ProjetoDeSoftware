from database.db import db


class Rota(db.Model):
    """
    Rota de acesso dentro da planta baixa (ex: entrada -> auditório).
    Relacionamentos:
      - N:1 com PlantaBaixa
    """

    __tablename__ = "rota"

    id = db.Column(db.Integer, primary_key=True)
    origem = db.Column(db.String(150), nullable=False)
    destino = db.Column(db.String(150), nullable=False)

    planta_baixa_id = db.Column(db.Integer, db.ForeignKey("planta_baixa.id"), nullable=False)
    planta_baixa = db.relationship("PlantaBaixa", back_populates="rotas")

    def __init__(self, origem, destino, planta_baixa_id):
        self.origem = origem
        self.destino = destino
        self.planta_baixa_id = planta_baixa_id

    def to_dict(self):
        return {
            "id": self.id,
            "origem": self.origem,
            "destino": self.destino,
            "planta_baixa_id": self.planta_baixa_id,
        }

    def __repr__(self):
        return f"<Rota {self.id} - {self.origem} -> {self.destino}>"
