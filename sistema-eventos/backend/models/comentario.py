"""
Model: Comentario.

CAMADA: Models (entidade de domínio + persistência).

Representa um comentário/avaliação que um Usuario faz sobre uma Palestra
(texto livre + nota opcional). Herda `db.Model` (tabela `comentario`) e
`CRUDMixin` (CRUD padrão).
"""

from datetime import datetime

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Comentario(db.Model, CRUDMixin):
    """Comentário/avaliação de um usuário sobre uma palestra."""

    __tablename__ = "comentario"

    id_comentario = db.Column(db.Integer, primary_key=True)
    texto = db.Column(db.Text, nullable=False)
    nota = db.Column(db.Numeric(3, 1))
    data = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    id_usuario = db.Column(db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False)
    id_palestra = db.Column(db.Integer, db.ForeignKey("palestra.id_palestra"), nullable=False)

    def to_dict(self):
        """Serializa o comentário para JSON."""
        return {
            "id_comentario": self.id_comentario,
            "texto": self.texto,
            "nota": float(self.nota) if self.nota is not None else None,
            "data": self.data.isoformat() if self.data else None,
            "id_usuario": self.id_usuario,
            "id_palestra": self.id_palestra,
        }
