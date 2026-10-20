"""
Caso de uso: atualizar dados de um usuário.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Usuário").

Se uma nova senha for enviada, ela é convertida em hash antes de chegar
à Model — a Model nunca deve receber senha em texto puro para gravação.

Método principal:
    execute(id_usuario, dados): retorna o Usuario atualizado.
"""

from werkzeug.security import generate_password_hash

from backend.models.usuario import Usuario


class AtualizarUsuarioService:
    """Caso de uso responsável pela atualização de um usuário existente."""

    def execute(self, id_usuario, dados):
        dados = dict(dados)
        if dados.get("senha"):
            dados["senha"] = generate_password_hash(dados["senha"])
        if dados.get("email"):
            dados["email"] = dados["email"].strip().lower()

        usuario = Usuario.atualizar(id_usuario, **dados)
        if not usuario:
            raise ValueError("Usuário não encontrado.")
        return usuario
