"""
Caso de uso: remover um patrocinador (F10, F14).

CAMADA: Services (regra de negócio do caso de uso "Remover Patrocinador").

Método principal:
    execute(id_patrocinador): remove o patrocinador ou lança ValueError.
"""

from backend.models.patrocinador import Patrocinador


class RemoverPatrocinadorService:
    """Caso de uso responsável pela remoção de um patrocinador."""

    def execute(self, id_patrocinador):
        if not Patrocinador.remover(id_patrocinador):
            raise ValueError("Patrocinador não encontrado.")
