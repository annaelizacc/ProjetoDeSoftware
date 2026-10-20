"""
Model: Palestrante.

CAMADA: Models (entidade de domínio + persistência).

Representa quem apresenta as palestras (F19/D01, usada na F05). O
palestrante não é um usuário do app: tem só os dados mostrados na tela de
informações do palestrante. Cada Palestra aponta para o seu palestrante
pelo campo `id_palestrante`.

Herda `db.Model` (tabela `palestrante`) e `CRUDMixin` (CRUD padrão).
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Palestrante(db.Model, CRUDMixin):
    """Pessoa que apresenta uma ou mais palestras."""

    __tablename__ = "palestrante"

    id_palestrante = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    foto = db.Column(db.String(255))
    descricao = db.Column(db.Text)
    rede_social = db.Column(db.String(255))

    def to_dict(self):
        """Serializa o palestrante para JSON."""
        return {
            "id_palestrante": self.id_palestrante,
            "nome": self.nome,
            "foto": self.foto,
            "descricao": self.descricao,
            "rede_social": self.rede_social,
        }
