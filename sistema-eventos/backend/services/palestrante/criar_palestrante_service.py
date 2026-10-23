"""
Caso de uso: cadastrar um palestrante do evento (F05, F14).

CAMADA: Services (regra de negócio do caso de uso "Criar Palestrante").

O organizador cadastra o palestrante uma vez no evento e depois o indica
nas palestras. A `foto` chega como o nome devolvido por
`POST /api/uploads` e é conferida por `validar_nome_imagem`. A
conferência do dono do evento é feita antes, no Controller.

Método principal:
    execute(dados): cria e retorna o novo palestrante.
"""

from backend.models.palestrante import Palestrante
from backend.services.upload.salvar_imagem_service import validar_nome_imagem
from backend.services.validacoes_cadastro import (
    TAMANHO_DESCRICAO,
    TAMANHO_LINK,
    TAMANHO_NOME,
    texto_obrigatorio,
    texto_opcional,
)


class CriarPalestranteService:
    """Caso de uso responsável pelo cadastro de um palestrante."""

    def execute(self, dados):
        if not dados.get("id_evento"):
            raise ValueError("id_evento é obrigatório.")

        return Palestrante.criar(
            nome=texto_obrigatorio(dados.get("nome"), "Digite o nome do palestrante.", TAMANHO_NOME),
            foto=validar_nome_imagem(dados.get("foto")),
            descricao=texto_opcional(dados.get("descricao"), "descrição", TAMANHO_DESCRICAO),
            rede_social=texto_opcional(dados.get("rede_social"), "rede social", TAMANHO_LINK),
            id_evento=dados["id_evento"],
        )
