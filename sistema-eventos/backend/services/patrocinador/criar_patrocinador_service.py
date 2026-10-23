"""
Caso de uso: cadastrar um patrocinador do evento (F10, F14).

CAMADA: Services (regra de negócio do caso de uso "Criar Patrocinador").

O `logo` chega como o nome devolvido por `POST /api/uploads` e é
conferido por `validar_nome_imagem`. A conferência do dono do evento é
feita antes, no Controller.

Método principal:
    execute(dados): cria e retorna o novo patrocinador.
"""

from backend.models.patrocinador import Patrocinador
from backend.services.upload.salvar_imagem_service import validar_nome_imagem
from backend.services.validacoes_cadastro import (
    TAMANHO_DESCRICAO,
    TAMANHO_LINK,
    TAMANHO_NOME,
    texto_obrigatorio,
    texto_opcional,
)


class CriarPatrocinadorService:
    """Caso de uso responsável pelo cadastro de um patrocinador."""

    def execute(self, dados):
        if not dados.get("id_evento"):
            raise ValueError("id_evento é obrigatório.")

        return Patrocinador.criar(
            nome_empresa=texto_obrigatorio(
                dados.get("nome_empresa"), "Digite o nome da empresa.", TAMANHO_NOME
            ),
            logo=validar_nome_imagem(dados.get("logo")),
            site=texto_opcional(dados.get("site"), "site", TAMANHO_LINK),
            descricao=texto_opcional(dados.get("descricao"), "descrição", TAMANHO_DESCRICAO),
            id_evento=dados["id_evento"],
        )
