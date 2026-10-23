"""
Caso de uso: cadastrar um local do evento (F04, F14).

CAMADA: Services (regra de negócio do caso de uso "Criar Local").

O local é uma sala, auditório ou estande do evento. A `descricao` guarda
o passo a passo de como chegar a partir da entrada (a "rota" da F04). A
conferência do dono do evento é feita antes, no Controller.

Método principal:
    execute(dados): cria e retorna o novo local.
"""

from backend.models.localizacao import Localizacao
from backend.services.validacoes_cadastro import (
    TAMANHO_DESCRICAO,
    TAMANHO_NOME,
    texto_obrigatorio,
    texto_opcional,
)


class CriarLocalService:
    """Caso de uso responsável pelo cadastro de um local."""

    def execute(self, dados):
        if not dados.get("id_evento"):
            raise ValueError("id_evento é obrigatório.")

        return Localizacao.criar(
            nome_local=texto_obrigatorio(dados.get("nome_local"), "Digite o nome do local.", TAMANHO_NOME),
            descricao=texto_opcional(dados.get("descricao"), "descrição", TAMANHO_DESCRICAO),
            id_evento=dados["id_evento"],
        )
