"""
Model: Palestrante.

CAMADA: Models (entidade de domínio + persistência).

Representa quem apresenta as palestras (F19/D01, usada na F05). O
palestrante não é um usuário do app: tem só os dados mostrados na tela de
informações do palestrante. Cada Palestra aponta para o seu palestrante
pelo campo `id_palestrante`.

Desde a F14, o palestrante pertence a um Evento (`id_evento`): o
organizador o cadastra uma vez no evento e o indica em algumas
palestras. Assim a regra de dono do evento também vale para ele. `foto`
guarda o nome do arquivo enviado por `POST /api/uploads`.

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
    id_evento = db.Column(db.Integer, db.ForeignKey("evento.id_evento"), nullable=False)

    def to_dict(self):
        """Serializa o palestrante para JSON."""
        return {
            "id_palestrante": self.id_palestrante,
            "nome": self.nome,
            "foto": self.foto,
            "descricao": self.descricao,
            "rede_social": self.rede_social,
            "id_evento": self.id_evento,
        }
