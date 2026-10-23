"""
Caso de uso: listar os locais de um evento (F04, F14).

CAMADA: Services (regra de negócio do caso de uso "Listar Locais").

Regras (as mesmas da lista de patrocinadores, F10):
- o `id_evento` é obrigatório: cada evento tem os próprios locais;
- o evento precisa existir, para um id errado não parecer um evento sem
  locais;
- a lista vem em ordem alfabética pelo nome do local.

Método principal:
    execute(id_evento): retorna a lista de locais (dicts).
"""

from backend.models.evento import Evento
from backend.models.localizacao import Localizacao


class ListarLocaisService:
    """Caso de uso responsável por listar os locais de um evento."""

    def execute(self, id_evento):
        if not id_evento:
            raise ValueError("id_evento é obrigatório.")
        if not Evento.buscar_por_id(id_evento):
            raise ValueError("Evento não encontrado.")

        locais = (
            Localizacao.query.filter_by(id_evento=id_evento)
            .order_by(Localizacao.nome_local)
            .all()
        )
        return [local.to_dict() for local in locais]
