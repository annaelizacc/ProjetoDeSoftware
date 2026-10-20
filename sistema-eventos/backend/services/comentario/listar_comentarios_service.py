"""
Caso de uso: listar os comentários de uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Listar Comentários").

Método principal:
    execute(id_palestra): retorna a lista de comentários (dicts), já com
    o nome de quem comentou.
"""

from backend.repositories.comentario_repository import ComentarioRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarComentariosService:
    """Caso de uso responsável por listar os comentários de uma palestra."""

    def execute(self, id_palestra):
        linhas = ComentarioRepository.listar_por_palestra(id_palestra)
        return [linha_para_dict(linha) for linha in linhas]
