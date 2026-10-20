"""
Caso de uso: listar palestras, com filtros opcionais.

CAMADA: Services (regra de negócio do caso de uso "Listar Palestras").

Os filtros (evento e termo de busca) são apenas repassados ao Repository,
que sabe montar a consulta SQL explícita correspondente.

Método principal:
    execute(id_evento=None, tema=None): retorna a lista de palestras (dicts).
"""

from backend.repositories.palestra_repository import PalestraRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarPalestrasService:
    """Caso de uso responsável por listar/filtrar palestras."""

    def execute(self, id_evento=None, tema=None):
        linhas = PalestraRepository.listar(id_evento=id_evento, tema=tema)
        return [linha_para_dict(linha) for linha in linhas]
