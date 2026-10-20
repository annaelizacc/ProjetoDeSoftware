"""
Model: Evento.

CAMADA: Models (entidade de domínio + persistência).

Representa um evento cadastrado no sistema (ex.: uma conferência), que
reúne uma ou mais Palestras. É a entidade "raiz" a partir da qual a
programação, a agenda do usuário e os locais do evento são derivados.

Esta Model herda de `db.Model` (mapeamento SQLAlchemy da tabela `evento`)
e de `CRUDMixin`, que fornece os métodos `criar`, `buscar_por_id`,
`listar`, `atualizar` e `remover` sem duplicar código em cada Model
(ver `backend/models/crud_mixin.py`).

Relacionamento: um Evento possui várias Palestras (`palestras`), com
`cascade="all, delete-orphan"` — ou seja, se um evento for removido, suas
palestras também são removidas, preservando a integridade dos dados.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Evento(db.Model, CRUDMixin):
    """Evento que reúne uma ou mais palestras."""

    __tablename__ = "evento"

    id_evento = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    descricao = db.Column(db.Text)
    data_inicio = db.Column(db.Date, nullable=False)
    data_fim = db.Column(db.Date, nullable=False)
    local = db.Column(db.String(200))

    palestras = db.relationship(
        "Palestra", back_populates="evento", cascade="all, delete-orphan"
    )

    def to_dict(self):
        """Serializa o evento para um dicionário pronto para virar JSON."""
        return {
            "id_evento": self.id_evento,
            "nome": self.nome,
            "descricao": self.descricao,
            "data_inicio": self.data_inicio.isoformat() if self.data_inicio else None,
            "data_fim": self.data_fim.isoformat() if self.data_fim else None,
            "local": self.local,
        }
