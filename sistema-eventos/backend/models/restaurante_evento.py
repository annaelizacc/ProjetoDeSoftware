"""
Model: RestauranteEvento.

CAMADA: Models (entidade associativa de persistência).

Tabela de junção N:N entre Restaurante e Evento (chave primária composta).
Herda `db.Model` (tabela `restaurante_evento`) e `CRUDMixin`.

Como a chave primária é composta (`id_restaurante` + `id_evento`), os
métodos genéricos `buscar_por_id`/`atualizar`/`remover` do CRUDMixin (que
assumem uma única chave primária) não se aplicam diretamente a esta
Model; ela é manipulada pelo `criar` genérico e por consultas específicas
quando necessário.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class RestauranteEvento(db.Model, CRUDMixin):
    """Associação N:N entre restaurante e evento."""

    __tablename__ = "restaurante_evento"

    id_restaurante = db.Column(
        db.Integer, db.ForeignKey("restaurante.id_restaurante"), primary_key=True
    )
    id_evento = db.Column(
        db.Integer, db.ForeignKey("evento.id_evento"), primary_key=True
    )

    def to_dict(self):
        """Serializa a associação para JSON."""
        return {"id_restaurante": self.id_restaurante, "id_evento": self.id_evento}
