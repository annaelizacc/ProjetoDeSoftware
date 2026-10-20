"""
Caso de uso: remover uma avaliação.

CAMADA: Services (regra de negócio do caso de uso "Remover Avaliação").

Método principal:
    execute(id_avaliacao): remove a avaliação ou lança ValueError.
"""

from backend.models.avaliacao import Avaliacao


class RemoverAvaliacaoService:
    """Caso de uso responsável pela remoção de uma avaliação."""

    def execute(self, id_avaliacao):
        removido = Avaliacao.remover(id_avaliacao)
        if not removido:
            raise ValueError("Avaliação não encontrada.")
