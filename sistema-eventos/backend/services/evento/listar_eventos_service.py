"""
Caso de uso: listar todos os eventos.

CAMADA: Services (regra de negócio do caso de uso "Listar Eventos").

Método principal:
    execute(): retorna a lista de eventos já serializada (dicts).
"""

from backend.models.evento import Evento


class ListarEventosService:
    """Caso de uso responsável por listar os eventos cadastrados."""

    def execute(self):
        eventos = Evento.query.order_by(Evento.data_inicio).all()
        return [evento.to_dict() for evento in eventos]
