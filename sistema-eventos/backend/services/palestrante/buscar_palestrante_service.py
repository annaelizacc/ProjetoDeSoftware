"""
Caso de uso: buscar um palestrante pelo ID (F05, RF14).

CAMADA: Services (regra de negócio do caso de uso "Buscar Palestrante").

Método principal:
    execute(id_palestrante): retorna o Palestrante ou lança ValueError.
"""

from backend.models.palestrante import Palestrante


class BuscarPalestranteService:
    """Caso de uso responsável por localizar um palestrante."""

    def execute(self, id_palestrante):
        palestrante = Palestrante.buscar_por_id(id_palestrante)
        if not palestrante:
            raise ValueError("Palestrante não encontrado.")
        return palestrante
