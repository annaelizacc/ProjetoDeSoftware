"""
Model: Localizacao.

CAMADA: Models (entidade de domínio + persistência).

Representa um local de interesse dentro de um Evento (ex.: auditório,
sala, estande). Herda `db.Model` (tabela `localizacao`) e `CRUDMixin`.

Desde a F19, cada Palestra aponta para o local onde acontece
(`palestra.id_localizacao`). A `descricao` guarda o passo a passo de como
chegar ao local a partir da entrada do evento (a "rota" da F04),
cadastrado pelo organizador (F14, rotas em `/api/locais`).
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Localizacao(db.Model, CRUDMixin):
    """Local de interesse dentro de um evento."""

    __tablename__ = "localizacao"

    id_localizacao = db.Column(db.Integer, primary_key=True)
    nome_local = db.Column(db.String(150), nullable=False)
    descricao = db.Column(db.Text)
    id_evento = db.Column(db.Integer, db.ForeignKey("evento.id_evento"), nullable=False)

    def to_dict(self):
        """Serializa a localização para JSON."""
        return {
            "id_localizacao": self.id_localizacao,
            "nome_local": self.nome_local,
            "descricao": self.descricao,
            "id_evento": self.id_evento,
        }
