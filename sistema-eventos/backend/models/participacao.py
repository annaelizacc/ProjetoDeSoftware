"""
Model: Participacao.

CAMADA: Models (entidade de domínio + persistência).

Representa a inscrição de um Usuario em uma Palestra (entidade
associativa N:N). Herda `db.Model` (tabela `participacao`) e `CRUDMixin`
(CRUD padrão).

A restrição `UniqueConstraint` impede, no banco, que o mesmo usuário se
inscreva duas vezes na mesma palestra. O controle de vagas (decrementar
`vagas_disponiveis` da Palestra ao inscrever e devolver a vaga ao
cancelar) é uma regra que envolve DUAS entidades ao mesmo tempo, por isso
continua no Service (`CriarInscricaoService`/`CancelarInscricaoService`),
e não nesta Model.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Participacao(db.Model, CRUDMixin):
    """Inscrição do usuário em uma palestra."""

    __tablename__ = "participacao"

    id_participacao = db.Column(db.Integer, primary_key=True)
    id_usuario = db.Column(
        db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False
    )
    id_palestra = db.Column(
        db.Integer, db.ForeignKey("palestra.id_palestra"), nullable=False
    )

    __table_args__ = (
        db.UniqueConstraint("id_usuario", "id_palestra", name="uk_participacao"),
    )

    def to_dict(self):
        """Serializa a inscrição para JSON."""
        return {
            "id_participacao": self.id_participacao,
            "id_usuario": self.id_usuario,
            "id_palestra": self.id_palestra,
        }
