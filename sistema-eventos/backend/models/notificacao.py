"""
Model: Notificacao.

CAMADA: Models (entidade de domínio + persistência).

Representa uma notificação/lembrete enviado a um Usuario sobre uma
Palestra. A tabela oficial `notificacao` já possuía `tipo_notificacao`,
por isso os lembretes de palestra são armazenados aqui mesmo (com
`tipo_notificacao = "lembrete"`), sem precisar de uma tabela adicional.

Herda `db.Model` (tabela `notificacao`) e `CRUDMixin` (CRUD padrão).
"""

from datetime import datetime

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Notificacao(db.Model, CRUDMixin):
    """Notificação ou lembrete associado a uma palestra."""

    __tablename__ = "notificacao"

    id_notificacao = db.Column(db.Integer, primary_key=True)
    mensagem = db.Column(db.Text, nullable=False)
    data_envio = db.Column(db.DateTime, default=datetime.utcnow)
    tipo_notificacao = db.Column(db.String(50))
    id_usuario = db.Column(
        db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False
    )
    id_palestra = db.Column(
        db.Integer, db.ForeignKey("palestra.id_palestra"), nullable=False
    )

    def to_dict(self):
        """Serializa a notificação/lembrete para JSON."""
        return {
            "id_notificacao": self.id_notificacao,
            "mensagem": self.mensagem,
            "data_envio": self.data_envio.isoformat() if self.data_envio else None,
            "tipo_notificacao": self.tipo_notificacao,
            "id_usuario": self.id_usuario,
            "id_palestra": self.id_palestra,
        }
