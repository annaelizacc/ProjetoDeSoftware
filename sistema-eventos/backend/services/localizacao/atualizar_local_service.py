"""
Caso de uso: alterar um local do evento (F04, F14).

CAMADA: Services (regra de negócio do caso de uso "Atualizar Local").

Só os campos de `CAMPOS_EDITAVEIS` são aceitos. O `id_evento` nunca muda
por aqui: ninguém "move" um local para o evento de outra pessoa.

Método principal:
    execute(id_localizacao, dados): retorna o local atualizado.
"""

from backend.models.localizacao import Localizacao
from backend.services.validacoes_cadastro import (
    TAMANHO_DESCRICAO,
    TAMANHO_NOME,
    texto_obrigatorio,
    texto_opcional,
)

CAMPOS_EDITAVEIS = ("nome_local", "descricao")


class AtualizarLocalService:
    """Caso de uso responsável pela alteração de um local."""

    def execute(self, id_localizacao, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nome_local" in alteracoes:
            alteracoes["nome_local"] = texto_obrigatorio(
                alteracoes["nome_local"], "Digite o nome do local.", TAMANHO_NOME
            )
        if "descricao" in alteracoes:
            alteracoes["descricao"] = texto_opcional(
                alteracoes["descricao"], "descrição", TAMANHO_DESCRICAO
            )

        local = Localizacao.atualizar(id_localizacao, **alteracoes)
        if not local:
            raise ValueError("Local não encontrado.")
        return local
