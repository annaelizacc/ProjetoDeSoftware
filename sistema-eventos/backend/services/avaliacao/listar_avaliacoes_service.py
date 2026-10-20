"""
Caso de uso: listar as avaliações de uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Listar Avaliações").

Método principal:
    execute(id_palestra): retorna a lista de avaliações (dicts), já com
    o nome de quem avaliou.
"""

from backend.repositories.avaliacao_repository import AvaliacaoRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarAvaliacoesService:
    """Caso de uso responsável por listar as avaliações de uma palestra."""

    def execute(self, id_palestra):
        linhas = AvaliacaoRepository.listar_por_palestra(id_palestra)
        return [linha_para_dict(linha) for linha in linhas]
