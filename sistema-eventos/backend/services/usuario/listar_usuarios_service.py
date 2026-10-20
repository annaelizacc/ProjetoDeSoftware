"""
Caso de uso: listar todos os usuários cadastrados.

CAMADA: Services (regra de negócio do caso de uso "Listar Usuários").

Método principal:
    execute(): retorna a lista de Usuarios.
"""

from backend.models.usuario import Usuario


class ListarUsuariosService:
    """Caso de uso responsável por listar os usuários cadastrados."""

    def execute(self):
        return Usuario.listar()
