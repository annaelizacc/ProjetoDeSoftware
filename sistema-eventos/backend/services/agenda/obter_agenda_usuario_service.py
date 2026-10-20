"""
Caso de uso: obter a agenda pessoal de um usuário.

CAMADA: Services (regra de negócio do caso de uso "Agenda do Usuário").

A agenda é a lista de palestras em que o usuário está inscrito. Como essa
consulta envolve um JOIN entre `participacao`, `palestra` e `evento`, ela
é resolvida pelo `AgendaRepository` (SQL explícito), e não por uma
consulta simples de Model.

Método principal:
    execute(id_usuario): retorna a lista de palestras (dicts) da agenda.
"""

from backend.repositories.palestra_repository import AgendaRepository
from backend.repositories.sql_helpers import linha_para_dict


class ObterAgendaUsuarioService:
    """Caso de uso responsável por montar a agenda pessoal do usuário."""

    def execute(self, id_usuario):
        linhas = AgendaRepository.listar_por_usuario(id_usuario)
        return [linha_para_dict(linha) for linha in linhas]
