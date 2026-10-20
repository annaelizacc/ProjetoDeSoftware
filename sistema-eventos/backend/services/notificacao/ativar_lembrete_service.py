"""
Caso de uso: ativar um lembrete para uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Ativar Lembrete").

O lembrete é gravado na própria tabela `notificacao`
(`tipo_notificacao = "lembrete"`), reaproveitando a tabela oficial do
banco em vez de criar uma tabela nova só para isso.

Método principal:
    execute(id_usuario, id_palestra): cria e retorna a Notificacao/lembrete.
"""

from backend.models.notificacao import Notificacao
from backend.models.palestra import Palestra
from backend.models.usuario import Usuario
from backend.repositories.notificacao_repository import NotificacaoRepository


class AtivarLembreteService:
    """Caso de uso responsável por ativar o lembrete de uma palestra."""

    def execute(self, id_usuario, id_palestra):
        if not Usuario.buscar_por_id(id_usuario):
            raise ValueError("Usuário não encontrado.")

        palestra = Palestra.buscar_por_id(id_palestra)
        if not palestra:
            raise ValueError("Palestra não encontrada.")

        if NotificacaoRepository.buscar_lembrete(id_usuario, id_palestra):
            raise ValueError("O lembrete já está ativo.")

        horario = (
            palestra.horario_inicio.strftime("%d/%m às %H:%M")
            if palestra.horario_inicio
            else "no horário programado"
        )
        mensagem = f"Lembrete ativado: {palestra.titulo} começa em {horario}."

        return Notificacao.criar(
            mensagem=mensagem,
            tipo_notificacao="lembrete",
            id_usuario=id_usuario,
            id_palestra=id_palestra,
        )
