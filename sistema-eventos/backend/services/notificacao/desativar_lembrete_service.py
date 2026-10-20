"""
Caso de uso: desativar um lembrete de palestra.

CAMADA: Services (regra de negócio do caso de uso "Desativar Lembrete").

Método principal:
    execute(id_usuario, id_palestra): remove o lembrete correspondente.
"""

from backend.models.notificacao import Notificacao
from backend.repositories.notificacao_repository import NotificacaoRepository


class DesativarLembreteService:
    """Caso de uso responsável por desativar o lembrete de uma palestra."""

    def execute(self, id_usuario, id_palestra):
        linha = NotificacaoRepository.buscar_lembrete(id_usuario, id_palestra)
        if not linha:
            raise ValueError("Lembrete não encontrado.")
        Notificacao.remover(linha["id_notificacao"])
