from database.db import db


class Avaliacao(db.Model):
    """
    Avaliação (nota em estrelas) de um Usuario sobre uma Palestra.
    Relacionamentos:
      - N:1 com Usuario
      - N:1 com Palestra
    """

    __tablename__ = "avaliacao"

    id = db.Column(db.Integer, primary_key=True)
    estrelas = db.Column(db.Integer, nullable=False)  # validação de 1 a 5 fica no Service

    usuario_id = db.Column(db.Integer, db.ForeignKey("usuario.id"), nullable=False)
    palestra_id = db.Column(db.Integer, db.ForeignKey("palestra.id"), nullable=False)

    usuario = db.relationship("Usuario", back_populates="avaliacoes")
    palestra = db.relationship("Palestra", back_populates="avaliacoes")

    __table_args__ = (
        db.UniqueConstraint("usuario_id", "palestra_id", name="uq_avaliacao_usuario_palestra"),
    )

    def __init__(self, estrelas, usuario_id, palestra_id):
        self.estrelas = estrelas
        self.usuario_id = usuario_id
        self.palestra_id = palestra_id

    def to_dict(self):
        return {
            "id": self.id,
            "estrelas": self.estrelas,
            "usuario_id": self.usuario_id,
            "palestra_id": self.palestra_id,
        }

    def __repr__(self):
        return f"<Avaliacao {self.id} - {self.estrelas} estrelas>"
