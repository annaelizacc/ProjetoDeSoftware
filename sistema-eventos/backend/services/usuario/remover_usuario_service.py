"""
Caso de uso: remover um usuário.

CAMADA: Services (regra de negócio do caso de uso "Remover Usuário").

Método principal:
    execute(id_usuario): remove o usuário ou lança ValueError se não existir.
"""

from backend.models.usuario import Usuario


class RemoverUsuarioService:
    """Caso de uso responsável pela remoção de um usuário."""

    def execute(self, id_usuario):
        removido = Usuario.remover(id_usuario)
        if not removido:
            raise ValueError("Usuário não encontrado.")
