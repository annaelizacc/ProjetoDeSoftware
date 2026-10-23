"""
Caso de uso: listar os patrocinadores de um evento (F10, RF19).

CAMADA: Services (regra de negócio do caso de uso "Listar Patrocinadores").

Regras:
- o `id_evento` é obrigatório: cada evento tem os próprios patrocinadores;
- o evento precisa existir. Assim, um id errado recebe "Evento não
  encontrado." em vez de uma lista vazia, que pareceria um evento sem
  patrocinadores;
- a lista vem em ordem alfabética pelo nome da empresa.

Método principal:
    execute(id_evento): retorna a lista de patrocinadores (dicts).
"""

from backend.models.evento import Evento
from backend.models.patrocinador import Patrocinador


class ListarPatrocinadoresService:
    """Caso de uso responsável por listar os patrocinadores de um evento."""

    def execute(self, id_evento):
        if not id_evento:
            raise ValueError("id_evento é obrigatório.")
        if not Evento.buscar_por_id(id_evento):
            raise ValueError("Evento não encontrado.")

        patrocinadores = (
            Patrocinador.query.filter_by(id_evento=id_evento)
            .order_by(Patrocinador.nome_empresa)
            .all()
        )
        return [patrocinador.to_dict() for patrocinador in patrocinadores]
