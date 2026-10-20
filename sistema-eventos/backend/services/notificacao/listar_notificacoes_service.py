"""
Caso de uso: listar as notificações/lembretes de um usuário.

CAMADA: Services (regra de negócio do caso de uso "Listar Notificações").

Método principal:
    execute(id_usuario): retorna a lista de notificações (dicts).
"""

from backend.models.usuario import Usuario
from backend.repositories.notificacao_repository import NotificacaoRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarNotificacoesService:
    """Caso de uso responsável por listar as notificações de um usuário."""

    def execute(self, id_usuario):
        if not Usuario.buscar_por_id(id_usuario):
            raise ValueError("Usuário não encontrado.")
        linhas = NotificacaoRepository.listar_por_usuario(id_usuario)
        return [linha_para_dict(linha) for linha in linhas]
