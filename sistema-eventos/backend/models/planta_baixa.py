"""
Model: PlantaBaixa.

CAMADA: Models (entidade de domínio + persistência).

Representa o mapa/planta baixa de um Evento (imagem + descrição). Herda
`db.Model` (tabela `planta_baixa`) e `CRUDMixin`.

`imagem_mapa` guarda o nome do arquivo enviado por `POST /api/uploads`.
Cada evento tem no máximo uma planta, acessada por
`/api/eventos/<id_evento>/planta` (F14).
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class PlantaBaixa(db.Model, CRUDMixin):
    """Planta baixa/mapa de um evento."""

    __tablename__ = "planta_baixa"

    id_planta = db.Column(db.Integer, primary_key=True)
    imagem_mapa = db.Column(db.String(255))
    descricao = db.Column(db.Text)
    id_evento = db.Column(db.Integer, db.ForeignKey("evento.id_evento"), nullable=False)

    def to_dict(self):
        """Serializa a planta baixa para JSON."""
        return {
            "id_planta": self.id_planta,
            "imagem_mapa": self.imagem_mapa,
            "descricao": self.descricao,
            "id_evento": self.id_evento,
        }
