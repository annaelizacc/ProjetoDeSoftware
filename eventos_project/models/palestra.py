from database.db import db
from models.associations import palestra_palestrante


class Palestra(db.Model):
    """
    Palestra dentro de um Evento.
    Relacionamentos:
      - N:1 com Evento
      - N:N com Palestrante
      - 1:N com Inscricao, Favorito, Feedback, Avaliacao
    """

    __tablename__ = "palestra"

    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(150), nullable=False)
    tema = db.Column(db.String(150))
    descricao = db.Column(db.Text)
    horario = db.Column(db.DateTime, nullable=False)
    vagas_disponiveis = db.Column(db.Integer, nullable=False, default=0)

    evento_id = db.Column(db.Integer, db.ForeignKey("evento.id"), nullable=False)
    evento = db.relationship("Evento", back_populates="palestras")

    palestrantes = db.relationship(
        "Palestrante", secondary=palestra_palestrante, back_populates="palestras"
    )

    inscricoes = db.relationship("Inscricao", back_populates="palestra", cascade="all, delete-orphan")
    favoritos = db.relationship("Favorito", back_populates="palestra", cascade="all, delete-orphan")
    feedbacks = db.relationship("Feedback", back_populates="palestra", cascade="all, delete-orphan")
    avaliacoes = db.relationship("Avaliacao", back_populates="palestra", cascade="all, delete-orphan")

    def __init__(self, titulo, horario, evento_id, tema=None, descricao=None, vagas_disponiveis=0):
        self.titulo = titulo
        self.horario = horario
        self.evento_id = evento_id
        self.tema = tema
        self.descricao = descricao
        self.vagas_disponiveis = vagas_disponiveis

    def to_dict(self):
        return {
            "id": self.id,
            "titulo": self.titulo,
            "tema": self.tema,
            "descricao": self.descricao,
            "horario": self.horario.isoformat() if self.horario else None,
            "vagas_disponiveis": self.vagas_disponiveis,
            "evento_id": self.evento_id,
            "palestrantes": [p.nome for p in self.palestrantes],
        }

    def __repr__(self):
        return f"<Palestra {self.id} - {self.titulo}>"
