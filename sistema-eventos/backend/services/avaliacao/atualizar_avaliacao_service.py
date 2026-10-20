"""
Caso de uso: atualizar uma avaliação existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Avaliação").

Só `nota_estrelas` e `comentario` podem ser alterados: quem avaliou e qual
palestra foi avaliada não mudam. Os outros campos recebidos são ignorados.
A nota passa pela mesma validação da criação (inteiro de 1 a 5).

Método principal:
    execute(id_avaliacao, dados): retorna a Avaliacao atualizada.
"""

from backend.models.avaliacao import Avaliacao
from backend.services.avaliacao.criar_avaliacao_service import validar_estrelas

CAMPOS_EDITAVEIS = ("nota_estrelas", "comentario")


class AtualizarAvaliacaoService:
    """Caso de uso responsável pela atualização de uma avaliação."""

    def execute(self, id_avaliacao, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nota_estrelas" in alteracoes:
            alteracoes["nota_estrelas"] = validar_estrelas(alteracoes["nota_estrelas"])

        avaliacao = Avaliacao.atualizar(id_avaliacao, **alteracoes)
        if not avaliacao:
            raise ValueError("Avaliação não encontrada.")
        return avaliacao
