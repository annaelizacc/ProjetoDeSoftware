"""
Caso de uso: atualizar um evento existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Evento").

Este Service recebe os dados enviados pelo Controller, localiza o evento
correspondente e utiliza os métodos da Model para realizar a atualização.
A separação deste Service existe porque "Atualizar Evento" é um caso de
uso independente dentro da aplicação.

Método principal:
    execute(id_evento, dados): retorna o Evento atualizado.
"""

from datetime import date

from backend.models.evento import Evento


class AtualizarEventoService:
    """Caso de uso responsável pela atualização de um evento existente."""

    def execute(self, id_evento, dados):
        dados = dict(dados)
        if dados.get("data_inicio"):
            dados["data_inicio"] = date.fromisoformat(str(dados["data_inicio"]))
        if dados.get("data_fim"):
            dados["data_fim"] = date.fromisoformat(str(dados["data_fim"]))

        evento = Evento.atualizar(id_evento, **dados)
        if not evento:
            raise ValueError("Evento não encontrado.")
        return evento
