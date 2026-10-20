"""
Caso de uso: criar um novo evento.

CAMADA: Services (regra de negócio do caso de uso "Criar Evento").

Método principal:
    execute(dados): cria e retorna o novo Evento.
"""

from datetime import date

from backend.models.evento import Evento


class CriarEventoService:
    """Caso de uso responsável pelo cadastro de um novo evento."""

    def execute(self, dados):
        obrigatorios = ("nome", "data_inicio", "data_fim")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("nome, data_inicio e data_fim são obrigatórios.")

        return Evento.criar(
            nome=dados["nome"],
            descricao=dados.get("descricao"),
            data_inicio=date.fromisoformat(str(dados["data_inicio"])),
            data_fim=date.fromisoformat(str(dados["data_fim"])),
            local=dados.get("local"),
        )
