"""
Caso de uso: adicionar uma palestra aos favoritos.

CAMADA: Services (regra de negócio do caso de uso "Adicionar Favorito").

Preserva a regra de evitar favoritos duplicados, verificando antes pelo
Repository (que consulta com SQL explícito) e não apenas confiando na
UniqueConstraint do banco — assim a API responde com um erro de negócio
claro (400) em vez de um erro de integridade.

Método principal:
    execute(id_usuario, id_palestra): cria e retorna o Favorito.
"""

from backend.models.favorito import Favorito
from backend.models.palestra import Palestra
from backend.models.usuario import Usuario
from backend.repositories.favorito_repository import FavoritoRepository


class AdicionarFavoritoService:
    """Caso de uso responsável por favoritar uma palestra."""

    def execute(self, id_usuario, id_palestra):
        if not Usuario.buscar_por_id(id_usuario):
            raise ValueError("Usuário não encontrado.")
        if not Palestra.buscar_por_id(id_palestra):
            raise ValueError("Palestra não encontrada.")
        if FavoritoRepository.buscar(id_usuario, id_palestra):
            raise ValueError("Palestra já está nos favoritos.")

        return Favorito.criar(id_usuario=id_usuario, id_palestra=id_palestra)
