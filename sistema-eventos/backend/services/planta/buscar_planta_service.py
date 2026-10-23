"""
Caso de uso: buscar a planta baixa de um evento (F03, F14).

CAMADA: Services (regra de negócio do caso de uso "Buscar Planta").

Cada evento tem no máximo uma planta. Um evento sem planta cadastrada
responde `None` (no JSON, `null`), e não um erro: o app mostra "planta
ainda não cadastrada".

Método principal:
    execute(id_evento): retorna a planta (dict) ou None.
"""

from backend.models.evento import Evento
from backend.models.planta_baixa import PlantaBaixa


class BuscarPlantaService:
    """Caso de uso responsável por buscar a planta de um evento."""

    def execute(self, id_evento):
        if not Evento.buscar_por_id(id_evento):
            raise ValueError("Evento não encontrado.")
        planta = PlantaBaixa.query.filter_by(id_evento=id_evento).first()
        return planta.to_dict() if planta else None
