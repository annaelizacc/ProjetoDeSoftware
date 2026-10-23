"""
Caso de uso: remover um local do evento (F04, F14).

CAMADA: Services (regra de negócio do caso de uso "Remover Local").

As palestras que usavam o local continuam existindo, só ficam sem local
(`ON DELETE SET NULL` no banco).

Método principal:
    execute(id_localizacao): remove o local ou lança ValueError.
"""

from backend.models.localizacao import Localizacao


class RemoverLocalService:
    """Caso de uso responsável pela remoção de um local."""

    def execute(self, id_localizacao):
        if not Localizacao.remover(id_localizacao):
            raise ValueError("Local não encontrado.")
