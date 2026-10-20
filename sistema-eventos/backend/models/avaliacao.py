"""
Model: Avaliacao.

CAMADA: Models (entidade de domínio + persistência).

Representa a avaliação que um Usuario faz sobre uma Palestra: estrelas de
1 a 5 e um comentário opcional. Substitui a antiga Model `Comentario`
(F19/D01): na tela "Avaliar", estrelas e comentário são enviados juntos,
então guardar os dois na mesma tabela evita ter o mesmo dado em dois
lugares.

Herda `db.Model` (tabela `avaliacao`) e `CRUDMixin` (CRUD padrão). As
regras (estrelas entre 1 e 5, uma avaliação por pessoa e palestra) são
conferidas no Service e garantidas também pelo banco (CHECK e UNIQUE).
"""

from datetime import datetime

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Avaliacao(db.Model, CRUDMixin):
    """Avaliação (estrelas + comentário opcional) de um usuário sobre uma palestra."""

    __tablename__ = "avaliacao"

    id_avaliacao = db.Column(db.Integer, primary_key=True)
    nota_estrelas = db.Column(db.SmallInteger, nullable=False)
    comentario = db.Column(db.Text)
    data = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    id_usuario = db.Column(db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False)
    id_palestra = db.Column(db.Integer, db.ForeignKey("palestra.id_palestra"), nullable=False)

    def to_dict(self):
        """Serializa a avaliação para JSON."""
        return {
            "id_avaliacao": self.id_avaliacao,
            "nota_estrelas": self.nota_estrelas,
            "comentario": self.comentario,
            "data": self.data.isoformat() if self.data else None,
            "id_usuario": self.id_usuario,
            "id_palestra": self.id_palestra,
        }
