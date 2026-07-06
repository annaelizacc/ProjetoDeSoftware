from database.db import db


class Evento(db.Model):
    """
    Representa o evento principal (ex: uma conferência).
    Relacionamentos:
      - 1:1 com PlantaBaixa
      - 1:N com Palestra
      - 1:N com Patrocinador
    """

    __tablename__ = "evento"

    id = db.Column(db.Integer, primary_key=True)
    local = db.Column(db.String(150), nullable=False)
    data = db.Column(db.Date, nullable=False)
    nome = db.Column(db.String(150), nullable=False)

    # 1:1 - a FK fica em PlantaBaixa (evento_id), aqui só a relação reversa
    planta_baixa = db.relationship(
        "PlantaBaixa", back_populates="evento", uselist=False, cascade="all, delete-orphan"
    )

    # 1:N
    palestras = db.relationship("Palestra", back_populates="evento", cascade="all, delete-orphan")
    patrocinadores = db.relationship(
        "Patrocinador", back_populates="evento", cascade="all, delete-orphan"
    )

    def __init__(self, local, data, nome):
        self.local = local
        self.data = data
        self.nome = nome

    def to_dict(self):
        return {
            "id": self.id,
            "local": self.local,
            "data": self.data.isoformat() if self.data else None,
            "nome": self.nome,
        }

    def __repr__(self):
        return f"<Evento {self.id} - {self.nome}>"
