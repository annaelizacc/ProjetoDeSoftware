"""
Model: Organizador.

CAMADA: Models (entidade de domínio + persistência).

Representa o papel de "organizador" que um Usuario pode ter (nível de
acesso administrativo). Herda `db.Model` (tabela `organizador`) e
`CRUDMixin` (CRUD padrão).

Desde a F08, cada Evento aponta para um Organizador responsável
(`evento.id_organizador`). O `nivel_acesso` diz o alcance:

- `administrador`: vê e gerencia todos os eventos (e, na F22, vai criar
  outros organizadores);
- `organizador`: vê e gerencia só os eventos ligados a ele.

A conferência de quem pode mexer em qual evento fica em
`controllers/autenticacao.py` (`verificar_dono_do_evento`).
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin

NIVEL_ADMINISTRADOR = "administrador"
NIVEL_ORGANIZADOR = "organizador"


class Organizador(db.Model, CRUDMixin):
    """Papel de organizador vinculado a um usuário."""

    __tablename__ = "organizador"

    id_organizador = db.Column(db.Integer, primary_key=True)
    id_usuario = db.Column(
        db.Integer, db.ForeignKey("usuario.id_usuario"), nullable=False, unique=True
    )
    nivel_acesso = db.Column(db.String(50), nullable=False)

    @classmethod
    def buscar_por_usuario(cls, id_usuario):
        """Devolve o Organizador do usuário, ou None se ele não tiver um."""
        return cls.query.filter_by(id_usuario=id_usuario).first()

    @property
    def eh_administrador(self):
        return self.nivel_acesso == NIVEL_ADMINISTRADOR

    def pode_gerenciar(self, evento):
        """Diz se este organizador é o responsável pelo evento ou um administrador."""
        return self.eh_administrador or evento.id_organizador == self.id_organizador

    @classmethod
    def usuario_pode_gerenciar(cls, usuario, evento):
        """Regra única de "quem gerencia o evento", usada por toda a API.

        Um usuário sem registro em `organizador` nunca pode, mesmo com
        `tipo_usuario = 'organizador'`.
        """
        organizador = cls.buscar_por_usuario(usuario.id_usuario)
        return organizador is not None and organizador.pode_gerenciar(evento)

    def to_dict(self):
        """Serializa o organizador para JSON."""
        return {
            "id_organizador": self.id_organizador,
            "id_usuario": self.id_usuario,
            "nivel_acesso": self.nivel_acesso,
        }
