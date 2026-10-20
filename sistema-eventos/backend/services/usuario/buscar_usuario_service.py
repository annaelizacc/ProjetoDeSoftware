"""
Caso de uso: buscar um usuário pelo ID.

CAMADA: Services (regra de negócio do caso de uso "Buscar Usuário").

Método principal:
    execute(id_usuario): retorna o Usuario ou lança ValueError se não existir.
"""

from backend.models.usuario import Usuario


class BuscarUsuarioService:
    """Caso de uso responsável por localizar um usuário existente."""

    def execute(self, id_usuario):
        usuario = Usuario.buscar_por_id(id_usuario)
        if not usuario:
            raise ValueError("Usuário não encontrado.")
        return usuario
