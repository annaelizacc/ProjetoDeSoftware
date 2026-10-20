"""
Caso de uso: obter a programação completa de um evento.

CAMADA: Services (regra de negócio do caso de uso "Programação do Evento").

Retorna todas as palestras vinculadas a um evento, na ordem em que estão
cadastradas na relação `evento.palestras`.

Método principal:
    execute(id_evento): retorna a lista de palestras (dicts) do evento.
"""

from backend.models.evento import Evento


class ObterProgramacaoService:
    """Caso de uso responsável por montar a programação de um evento."""

    def execute(self, id_evento):
        evento = Evento.buscar_por_id(id_evento)
        if not evento:
            raise ValueError("Evento não encontrado.")
        return [palestra.to_dict() for palestra in evento.palestras]
