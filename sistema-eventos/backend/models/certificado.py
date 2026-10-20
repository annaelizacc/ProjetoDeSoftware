"""
Model: Certificado.

CAMADA: Models (entidade de domínio + persistência).

Representa o certificado de participação de um Usuario em um Evento, como
no diagrama do relatório (F19/D01). Por enquanto existem só a tabela e a
Model: a emissão do certificado é a F12.

O `codigo_validacao` é único para que qualquer pessoa consiga conferir se
um certificado é verdadeiro. Herda `db.Model` (tabela `certificado`) e
`CRUDMixin` (CRUD padrão).
"""

from datetime import datetime

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Certificado(db.Model, CRUDMixin):
    """Certificado de participação de um usuário em um evento."""

    __tablename__ = "certificado"

    id_certificado = db.Column(db.Integer, primary_key=True)
    codigo_validacao = db.Column(db.String(64), nullable=False, unique=True)
    data_emissao = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    id_usuario = db.Column(db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False)
    id_evento = db.Column(db.Integer, db.ForeignKey("evento.id_evento"), nullable=False)

    def to_dict(self):
        """Serializa o certificado para JSON."""
        return {
            "id_certificado": self.id_certificado,
            "codigo_validacao": self.codigo_validacao,
            "data_emissao": self.data_emissao.isoformat() if self.data_emissao else None,
            "id_usuario": self.id_usuario,
            "id_evento": self.id_evento,
        }
