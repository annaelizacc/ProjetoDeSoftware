"""
Caso de uso: remover uma palestra dos favoritos.

CAMADA: Services (regra de negócio do caso de uso "Remover Favorito").

Método principal:
    execute(id_usuario, id_palestra): remove o Favorito correspondente.
"""

from backend.repositories.favorito_repository import FavoritoRepository


class RemoverFavoritoService:
    """Caso de uso responsável por remover um favorito existente."""

    def execute(self, id_usuario, id_palestra):
        linha = FavoritoRepository.buscar(id_usuario, id_palestra)
        if not linha:
            raise ValueError("Favorito não encontrado.")

        # A consulta acima usa SQL explícito (retorna uma RowMapping), mas
        # a remoção em si é uma operação simples por chave primária, então
        # delegamos à Model, que sabe como remover pelo próprio ID.
        from backend.models.favorito import Favorito

        Favorito.remover(linha["id_favorito"])
