"""
Model: Usuario.

CAMADA: Models (entidade de domínio + persistência).

Representa uma pessoa que usa o aplicativo (participante ou organizador).
Herda `db.Model` (tabela `usuario`) e `CRUDMixin` (CRUD padrão).

Preparo para a F18 (Entrar com Google), ainda não implementada: `senha`
aceita vazio, porque quem entra pelo Google não tem senha no sistema, e
`google_id` guarda o identificador da conta Google. O `to_dict` não expõe
nenhum dos dois.

IMPORTANTE: esta Model NÃO faz hash de senha sozinha. A geração do hash
(quando um usuário novo é cadastrado) e a verificação de senha (no login)
são regras de negócio de segurança e ficam nos Services
(`CriarUsuarioService` e `AutenticarUsuarioService`), para manter a Model
simples e focada em persistência.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin

# Valores possíveis de `tipo_usuario`. Ficam aqui, junto da coluna, para
# que decorators e Services comparem com a mesma constante (P01).
TIPO_PARTICIPANTE = "participante"
TIPO_ORGANIZADOR = "organizador"


class Usuario(db.Model, CRUDMixin):
    """Usuário que pode participar das palestras."""

    __tablename__ = "usuario"

    id_usuario = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), nullable=False, unique=True)
    senha = db.Column(db.String(255))
    tipo_usuario = db.Column(db.String(50), nullable=False)
    google_id = db.Column(db.String(255), unique=True)

    def to_dict(self):
        """Serializa o usuário sem expor o campo `senha`."""
        return {
            "id_usuario": self.id_usuario,
            "nome": self.nome,
            "email": self.email,
            "tipo_usuario": self.tipo_usuario,
        }
