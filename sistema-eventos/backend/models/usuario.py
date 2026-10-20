"""
Model: Usuario.

CAMADA: Models (entidade de domínio + persistência).

Representa uma pessoa que usa o aplicativo (participante do evento).
Herda `db.Model` (tabela `usuario`) e `CRUDMixin` (CRUD padrão).

IMPORTANTE: esta Model NÃO faz hash de senha sozinha. A geração do hash
(quando um usuário novo é cadastrado) e a verificação de senha (no login)
são regras de negócio de segurança e ficam nos Services
(`CriarUsuarioService` e `AutenticarUsuarioService`), para manter a Model
simples e focada em persistência.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Usuario(db.Model, CRUDMixin):
    """Usuário que pode participar das palestras."""

    __tablename__ = "usuario"

    id_usuario = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), nullable=False, unique=True)
    senha = db.Column(db.String(255), nullable=False)
    tipo_usuario = db.Column(db.String(50), nullable=False)

    def to_dict(self):
        """Serializa o usuário sem expor o campo `senha`."""
        return {
            "id_usuario": self.id_usuario,
            "nome": self.nome,
            "email": self.email,
            "tipo_usuario": self.tipo_usuario,
        }
