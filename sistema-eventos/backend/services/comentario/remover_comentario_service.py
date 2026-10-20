"""
Caso de uso: remover um comentário.

CAMADA: Services (regra de negócio do caso de uso "Remover Comentário").

Método principal:
    execute(id_comentario): remove o comentário ou lança ValueError.
"""

from backend.models.comentario import Comentario


class RemoverComentarioService:
    """Caso de uso responsável pela remoção de um comentário."""

    def execute(self, id_comentario):
        removido = Comentario.remover(id_comentario)
        if not removido:
            raise ValueError("Comentário não encontrado.")
