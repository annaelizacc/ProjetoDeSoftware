from database.db import db
from models.usuario import Usuario


class Organizador(Usuario):
    """
    Organizador do evento. Herda todos os atributos de Usuario
    (id, nome, email, senha, modo_escuro) via Single Table Inheritance.

    Relacionamentos:
      - 1:N com Comunicado
    """

    __mapper_args__ = {
        "polymorphic_identity": "organizador",
    }

    comunicados = db.relationship(
        "Comunicado",
        back_populates="organizador",
        cascade="all, delete-orphan",
        foreign_keys="Comunicado.organizador_id",
    )

    def __repr__(self):
        return f"<Organizador {self.id} - {self.nome}>"
