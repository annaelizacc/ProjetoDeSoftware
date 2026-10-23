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


class CriarLocalService:
    """Caso de uso responsável pelo cadastro de um local."""

    def execute(self, dados):
        if not dados.get("id_evento"):
            raise ValueError("id_evento é obrigatório.")
        if not str(dados.get("nome_local") or "").strip():
            raise ValueError("Digite o nome do local.")

        return Localizacao.criar(
            nome_local=str(dados["nome_local"]).strip(),
            descricao=dados.get("descricao"),
            id_evento=dados["id_evento"],
        )
