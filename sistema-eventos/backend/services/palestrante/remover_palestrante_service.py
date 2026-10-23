"""
Caso de uso: remover um palestrante (F05, F14).

CAMADA: Services (regra de negócio do caso de uso "Remover Palestrante").

As palestras dele continuam existindo, só ficam sem palestrante
(`ON DELETE SET NULL` no banco).

Método principal:
    execute(id_palestrante): remove o palestrante ou lança ValueError.
"""

from backend.models.palestrante import Palestrante


class RemoverPalestranteService:
    """Caso de uso responsável pela remoção de um palestrante."""

    def execute(self, id_palestrante):
        if not Palestrante.remover(id_palestrante):
            raise ValueError("Palestrante não encontrado.")
