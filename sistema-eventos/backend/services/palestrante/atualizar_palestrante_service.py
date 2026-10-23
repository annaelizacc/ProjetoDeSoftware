"""
Caso de uso: alterar um palestrante (F05, F14).

CAMADA: Services (regra de negócio do caso de uso "Atualizar Palestrante").

Só os campos de `CAMPOS_EDITAVEIS` são aceitos; o `id_evento` nunca muda
por aqui. Uma foto nova passa pela mesma conferência do cadastro.

Método principal:
    execute(id_palestrante, dados): retorna o palestrante atualizado.
"""

from backend.models.palestrante import Palestrante
from backend.services.upload.salvar_imagem_service import validar_nome_imagem

CAMPOS_EDITAVEIS = ("nome", "foto", "descricao", "rede_social")


class AtualizarPalestranteService:
    """Caso de uso responsável pela alteração de um palestrante."""

    def execute(self, id_palestrante, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nome" in alteracoes:
            if not str(alteracoes["nome"] or "").strip():
                raise ValueError("Digite o nome do palestrante.")
            alteracoes["nome"] = str(alteracoes["nome"]).strip()
        if "foto" in alteracoes:
            alteracoes["foto"] = validar_nome_imagem(alteracoes["foto"])

        palestrante = Palestrante.atualizar(id_palestrante, **alteracoes)
        if not palestrante:
            raise ValueError("Palestrante não encontrado.")
        return palestrante
