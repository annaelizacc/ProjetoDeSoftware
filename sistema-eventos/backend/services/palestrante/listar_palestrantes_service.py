"""
Caso de uso: listar os palestrantes de um evento (F05, F14).

CAMADA: Services (regra de negócio do caso de uso "Listar Palestrantes").

Desde a F14, cada palestrante pertence a um evento. Regras:
- o `id_evento` é obrigatório e o evento precisa existir;
- a lista vem em ordem alfabética pelo nome;
- com `busca`, devolve só os palestrantes cujo nome contém o texto
  (RF13, busca por nome), sem diferenciar maiúsculas de minúsculas.

Método principal:
    execute(id_evento, busca=None): retorna a lista de palestrantes (dicts).
"""

from backend.models.evento import Evento
from backend.models.palestrante import Palestrante


class ListarPalestrantesService:
    """Caso de uso responsável por listar os palestrantes de um evento."""

    def execute(self, id_evento, busca=None):
        if not id_evento:
            raise ValueError("id_evento é obrigatório.")
        if not Evento.buscar_por_id(id_evento):
            raise ValueError("Evento não encontrado.")

        consulta = Palestrante.query.filter_by(id_evento=id_evento)
        if busca:
            # `icontains` é o "contém", sem diferenciar maiúsculas. O texto
            # vai como parâmetro, nunca colado no SQL, e `autoescape` faz
            # `%` e `_` valerem como letras (no LIKE, eles são curingas).
            consulta = consulta.filter(
                Palestrante.nome.icontains(busca.strip(), autoescape=True)
            )
        return [p.to_dict() for p in consulta.order_by(Palestrante.nome).all()]
