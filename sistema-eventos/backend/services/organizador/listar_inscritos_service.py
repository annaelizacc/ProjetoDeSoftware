"""
Caso de uso: listar os inscritos de uma palestra (F08, RF17).

CAMADA: Services (regra de negócio do caso de uso "Ver inscritos").

Usado pela tela "Inscrições" da área do organizador. Confere se a
palestra existe antes de consultar, para que uma palestra inexistente
responda com erro em vez de uma lista vazia (que pareceria "ninguém se
inscreveu").

Método principal:
    execute(id_palestra): retorna a lista de inscritos (dicts com
    `id_usuario`, `nome` e `email`).
"""

from backend.models.palestra import Palestra
from backend.repositories.organizador_repository import OrganizadorRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarInscritosService:
    """Caso de uso responsável por listar os inscritos de uma palestra."""

    def execute(self, id_palestra):
        if not Palestra.buscar_por_id(id_palestra):
            raise ValueError("Palestra não encontrada.")

        linhas = OrganizadorRepository.listar_inscritos(id_palestra)
        return [linha_para_dict(linha) for linha in linhas]
