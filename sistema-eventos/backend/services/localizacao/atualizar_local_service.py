"""
Caso de uso: alterar um local do evento (F04, F14).

CAMADA: Services (regra de negócio do caso de uso "Atualizar Local").

Só os campos de `CAMPOS_EDITAVEIS` são aceitos. O `id_evento` nunca muda
por aqui: ninguém "move" um local para o evento de outra pessoa.

Método principal:
    execute(id_localizacao, dados): retorna o local atualizado.
"""

from backend.models.localizacao import Localizacao

CAMPOS_EDITAVEIS = ("nome_local", "descricao")


class AtualizarLocalService:
    """Caso de uso responsável pela alteração de um local."""

    def execute(self, id_localizacao, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nome_local" in alteracoes:
            if not str(alteracoes["nome_local"] or "").strip():
                raise ValueError("Digite o nome do local.")
            alteracoes["nome_local"] = str(alteracoes["nome_local"]).strip()

        local = Localizacao.atualizar(id_localizacao, **alteracoes)
        if not local:
            raise ValueError("Local não encontrado.")
        return local
