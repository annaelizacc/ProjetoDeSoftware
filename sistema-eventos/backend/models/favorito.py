"""
Model: Favorito.

CAMADA: Models (entidade de domínio + persistência).

Representa uma Palestra que um Usuario marcou para consultar depois.
Herda `db.Model` (tabela `favorito`) e `CRUDMixin` (CRUD padrão).

A restrição `UniqueConstraint` garante, no próprio banco, que o mesmo
usuário não favorite a mesma palestra duas vezes. A verificação "amigável"
dessa regra (retornar um erro de negócio claro em vez de um erro de banco)
é feita no `AdicionarFavoritoService`, usando o `FavoritoRepository`.
"""

from datetime import datetime

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Favorito(db.Model, CRUDMixin):
    """Palestra marcada pelo usuário para consultar depois."""

    __tablename__ = "favorito"

    id_favorito = db.Column(db.Integer, primary_key=True)
    id_usuario = db.Column(
        db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False
    )
    id_palestra = db.Column(
        db.Integer, db.ForeignKey("palestra.id_palestra"), nullable=False
    )
    data_favoritacao = db.Column(db.DateTime, default=datetime.utcnow)
    usuario = db.relationship("Usuario")
    palestra = db.relationship("Palestra")

    __table_args__ = (
        db.UniqueConstraint(
            "id_usuario", "id_palestra", name="uk_favorito_usuario_palestra"
        ),
    )

    def to_dict(self):
        """Serializa o favorito para JSON."""
        return {
            "id_favorito": self.id_favorito,
            "id_usuario": self.id_usuario,
            "id_palestra": self.id_palestra,
            "data_favoritacao": (
                self.data_favoritacao.isoformat()
                if self.data_favoritacao
                else None
            ),
        }
