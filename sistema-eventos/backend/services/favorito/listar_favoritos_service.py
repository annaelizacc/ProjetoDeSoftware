"""
Caso de uso: listar os favoritos de um usuário.

CAMADA: Services (regra de negócio do caso de uso "Listar Favoritos").

Método principal:
    execute(id_usuario): retorna a lista de favoritos (dicts), já com os
    dados da palestra favoritada.
"""

from backend.models.usuario import Usuario
from backend.repositories.favorito_repository import FavoritoRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarFavoritosService:
    """Caso de uso responsável por listar os favoritos de um usuário."""

    def execute(self, id_usuario):
        if not Usuario.buscar_por_id(id_usuario):
            raise ValueError("Usuário não encontrado.")
        linhas = FavoritoRepository.listar_por_usuario(id_usuario)
        return [linha_para_dict(linha) for linha in linhas]
