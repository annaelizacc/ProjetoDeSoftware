"""
Caso de uso: alterar um patrocinador (F10, F14).

CAMADA: Services (regra de negócio do caso de uso "Atualizar Patrocinador").

Só os campos de `CAMPOS_EDITAVEIS` são aceitos; o `id_evento` nunca muda
por aqui. Um logo novo passa pela mesma conferência do cadastro.

Método principal:
    execute(id_patrocinador, dados): retorna o patrocinador atualizado.
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

CAMPOS_EDITAVEIS = ("nome_empresa", "logo", "site", "descricao")


class AtualizarPatrocinadorService:
    """Caso de uso responsável pela alteração de um patrocinador."""

    def execute(self, id_patrocinador, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nome_empresa" in alteracoes:
            alteracoes["nome_empresa"] = texto_obrigatorio(
                alteracoes["nome_empresa"], "Digite o nome da empresa.", TAMANHO_NOME
            )
        if "site" in alteracoes:
            alteracoes["site"] = texto_opcional(alteracoes["site"], "site", TAMANHO_LINK)
        if "descricao" in alteracoes:
            alteracoes["descricao"] = texto_opcional(
                alteracoes["descricao"], "descrição", TAMANHO_DESCRICAO
            )
        if "logo" in alteracoes:
            alteracoes["logo"] = validar_nome_imagem(alteracoes["logo"])

        patrocinador = Patrocinador.atualizar(id_patrocinador, **alteracoes)
        if not patrocinador:
            raise ValueError("Patrocinador não encontrado.")
        return patrocinador
