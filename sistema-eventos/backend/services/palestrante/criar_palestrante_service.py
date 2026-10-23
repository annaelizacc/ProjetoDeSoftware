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


class CriarPalestranteService:
    """Caso de uso responsável pelo cadastro de um palestrante."""

    def execute(self, dados):
        if not dados.get("id_evento"):
            raise ValueError("id_evento é obrigatório.")
        if not str(dados.get("nome") or "").strip():
            raise ValueError("Digite o nome do palestrante.")

        return Palestrante.criar(
            nome=str(dados["nome"]).strip(),
            foto=validar_nome_imagem(dados.get("foto")),
            descricao=dados.get("descricao"),
            rede_social=dados.get("rede_social"),
            id_evento=dados["id_evento"],
        )
