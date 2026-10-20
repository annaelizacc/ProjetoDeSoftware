"""
Caso de uso: buscar um evento pelo ID.

CAMADA: Services (regra de negócio do caso de uso "Buscar Evento").

Método principal:
    execute(id_evento): retorna a Model Evento ou lança ValueError.
"""

from backend.models.evento import Evento


class BuscarEventoService:
    """Caso de uso responsável por localizar um evento existente."""

    def execute(self, id_evento):
        evento = Evento.buscar_por_id(id_evento)
        if not evento:
            raise ValueError("Evento não encontrado.")
        return evento
