"""
Model: Restaurante.

CAMADA: Models (entidade de domínio + persistência).

Representa um restaurante que pode ser associado a um ou mais Eventos
(ver `RestauranteEvento`). Herda `db.Model` (tabela `restaurante`) e
`CRUDMixin` (CRUD padrão).

Assim como Organizador, ainda não possui endpoints próprios na API.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Restaurante(db.Model, CRUDMixin):
    """Restaurante nas proximidades de um evento."""

    __tablename__ = "restaurante"

    id_restaurante = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    avaliacao = db.Column(db.Numeric(2, 1))
    distancia = db.Column(db.Numeric(6, 2))
    categoria = db.Column(db.String(80))
    endereco = db.Column(db.String(200))

    def to_dict(self):
        """Serializa o restaurante para JSON."""
        return {
            "id_restaurante": self.id_restaurante,
            "nome": self.nome,
            "avaliacao": float(self.avaliacao) if self.avaliacao is not None else None,
            "distancia": float(self.distancia) if self.distancia is not None else None,
            "categoria": self.categoria,
            "endereco": self.endereco,
        }
