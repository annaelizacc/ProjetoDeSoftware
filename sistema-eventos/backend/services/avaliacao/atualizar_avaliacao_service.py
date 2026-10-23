"""
Caso de uso: atualizar uma avaliação existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Avaliação").

Só `nota_estrelas` e `comentario` podem ser alterados: quem avaliou e qual
palestra foi avaliada não mudam. Os outros campos recebidos são ignorados.
A nota e o comentário passam pelas mesmas validações da criação (nota
inteira de 1 a 5, comentário de até 500 caracteres).

A inscrição e o horário não são conferidos de novo: só o autor edita, e
ele já passou por essas regras ao criar. Assim, quem avaliou e depois
cancelou a inscrição ainda pode corrigir ou excluir a própria avaliação.

Quem pode editar (P01): só o autor da avaliação. Nem o organizador muda
a nota de outra pessoa; outra pessoa recebe PermissionError (403).

Método principal:
    execute(id_avaliacao, dados, usuario): retorna a Avaliacao atualizada.
"""

from backend.models.avaliacao import Avaliacao
from backend.services.avaliacao.criar_avaliacao_service import (
    validar_comentario,
    validar_estrelas,
)

CAMPOS_EDITAVEIS = ("nota_estrelas", "comentario")


class AtualizarAvaliacaoService:
    """Caso de uso responsável pela atualização de uma avaliação."""

    def execute(self, id_avaliacao, dados, usuario):
        avaliacao = Avaliacao.buscar_por_id(id_avaliacao)
        if not avaliacao:
            raise ValueError("Avaliação não encontrada.")
        if avaliacao.id_usuario != usuario.id_usuario:
            raise PermissionError("Só quem fez a avaliação pode editá-la.")

        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nota_estrelas" in alteracoes:
            alteracoes["nota_estrelas"] = validar_estrelas(alteracoes["nota_estrelas"])
        if "comentario" in alteracoes:
            alteracoes["comentario"] = validar_comentario(alteracoes["comentario"])

        return Avaliacao.atualizar(id_avaliacao, **alteracoes)
