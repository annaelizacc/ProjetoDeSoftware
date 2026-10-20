"""
Caso de uso: remover uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Remover Palestra").

Método principal:
    execute(id_palestra): remove a palestra ou lança ValueError se não existir.
"""

from backend.models.palestra import Palestra


class RemoverPalestraService:
    """Caso de uso responsável pela remoção de uma palestra."""

    def execute(self, id_palestra):
        removida = Palestra.remover(id_palestra)
        if not removida:
            raise ValueError("Palestra não encontrada.")
