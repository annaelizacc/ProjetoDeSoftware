"""
Caso de uso: remover uma avaliação.

CAMADA: Services (regra de negócio do caso de uso "Remover Avaliação").

Quem pode remover (P01): o autor da avaliação ou um organizador, que
pode moderar comentários ofensivos. Outra pessoa recebe PermissionError
(que o Controller devolve como 403).

Método principal:
    execute(id_avaliacao, usuario): remove a avaliação ou lança
        ValueError (não encontrada) / PermissionError (sem permissão).
"""

from backend.models.avaliacao import Avaliacao
from backend.models.usuario import TIPO_ORGANIZADOR


class RemoverAvaliacaoService:
    """Caso de uso responsável pela remoção de uma avaliação."""

    def execute(self, id_avaliacao, usuario):
        avaliacao = Avaliacao.buscar_por_id(id_avaliacao)
        if not avaliacao:
            raise ValueError("Avaliação não encontrada.")
        e_autor = avaliacao.id_usuario == usuario.id_usuario
        if not e_autor and usuario.tipo_usuario != TIPO_ORGANIZADOR:
            raise PermissionError("Só quem fez a avaliação ou um organizador pode removê-la.")
        Avaliacao.remover(id_avaliacao)
