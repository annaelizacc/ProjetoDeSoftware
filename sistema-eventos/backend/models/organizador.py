"""
Model: Organizador.

CAMADA: Models (entidade de domínio + persistência).

Representa o papel de "organizador" que um Usuario pode ter dentro de um
evento (nível de acesso administrativo). Herda `db.Model` (tabela
`organizador`) e `CRUDMixin` (CRUD padrão).

Esta entidade ainda não possui endpoints próprios na API (nenhuma tela do
Flutter consome dados de organizador hoje), mas já está pronta para uso
futuro com o mesmo padrão de CRUD das demais Models.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Organizador(db.Model, CRUDMixin):
    """Papel de organizador vinculado a um usuário."""

    __tablename__ = "organizador"

    id_organizador = db.Column(db.Integer, primary_key=True)
    id_usuario = db.Column(
        db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False, unique=True
    )
    nivel_acesso = db.Column(db.String(50), nullable=False)

    def to_dict(self):
        """Serializa o organizador para JSON."""
        return {
            "id_organizador": self.id_organizador,
            "id_usuario": self.id_usuario,
            "nivel_acesso": self.nivel_acesso,
        }
