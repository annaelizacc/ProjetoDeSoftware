"""
Caso de uso: atualizar um evento existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Evento").

Este Service recebe os dados enviados pelo Controller, localiza o evento
correspondente e utiliza os métodos da Model para realizar a atualização.
A separação deste Service existe porque "Atualizar Evento" é um caso de
uso independente dentro da aplicação.

Só os campos de `CAMPOS_EDITAVEIS` são aceitos (lista do que é
permitido, como na atualização de usuário). Assim, `id_organizador` e
`id_evento` nunca mudam por aqui: o responsável pelo evento não pode
ser trocado nem por ele mesmo (F08).

Método principal:
    execute(id_evento, dados): retorna o Evento atualizado.
"""

from datetime import date

from backend.models.evento import Evento

CAMPOS_EDITAVEIS = ("nome", "descricao", "data_inicio", "data_fim", "local")


class AtualizarEventoService:
    """Caso de uso responsável pela atualização de um evento existente."""

    def execute(self, id_evento, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if alteracoes.get("data_inicio"):
            alteracoes["data_inicio"] = date.fromisoformat(str(alteracoes["data_inicio"]))
        if alteracoes.get("data_fim"):
            alteracoes["data_fim"] = date.fromisoformat(str(alteracoes["data_fim"]))

        evento = Evento.atualizar(id_evento, **alteracoes)
        if not evento:
            raise ValueError("Evento não encontrado.")
        return evento
