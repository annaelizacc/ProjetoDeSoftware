"""
Caso de uso: atualizar um comentário existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Comentário").

Método principal:
    execute(id_comentario, dados): retorna o Comentario atualizado.
"""

from backend.models.comentario import Comentario


class AtualizarComentarioService:
    """Caso de uso responsável pela atualização de um comentário."""

    def execute(self, id_comentario, dados):
        comentario = Comentario.atualizar(id_comentario, **dados)
        if not comentario:
            raise ValueError("Comentário não encontrado.")
        return comentario
