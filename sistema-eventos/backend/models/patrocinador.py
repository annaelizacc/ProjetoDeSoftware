"""
Model: Patrocinador.

CAMADA: Models (entidade de domínio + persistência).

Representa uma empresa que patrocina um Evento (F19/D01, usada na F10).
Herda `db.Model` (tabela `patrocinador`) e `CRUDMixin` (CRUD padrão).

Ainda sem endpoints próprios na API: a rota e a tela vêm na F10.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Patrocinador(db.Model, CRUDMixin):
    """Empresa patrocinadora de um evento."""

    __tablename__ = "patrocinador"

    id_patrocinador = db.Column(db.Integer, primary_key=True)
    nome_empresa = db.Column(db.String(150), nullable=False)
    logo = db.Column(db.String(255))
    site = db.Column(db.String(255))
    descricao = db.Column(db.Text)
    id_evento = db.Column(db.Integer, db.ForeignKey("evento.id_evento"), nullable=False)

    def to_dict(self):
        """Serializa o patrocinador para JSON."""
        return {
            "id_patrocinador": self.id_patrocinador,
            "nome_empresa": self.nome_empresa,
            "logo": self.logo,
            "site": self.site,
            "descricao": self.descricao,
            "id_evento": self.id_evento,
        }
