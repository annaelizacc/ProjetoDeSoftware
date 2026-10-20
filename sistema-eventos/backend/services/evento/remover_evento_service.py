"""
Caso de uso: remover um evento.

CAMADA: Services (regra de negócio do caso de uso "Remover Evento").

Ao remover um evento, o `cascade="all, delete-orphan"` definido na Model
`Evento` garante que suas palestras sejam removidas junto — preservando a
integridade dos dados sem precisar de lógica extra aqui.

Método principal:
    execute(id_evento): remove o evento ou lança ValueError se não existir.
"""

from backend.models.evento import Evento


class RemoverEventoService:
    """Caso de uso responsável pela remoção de um evento."""

    def execute(self, id_evento):
        removido = Evento.remover(id_evento)
        if not removido:
            raise ValueError("Evento não encontrado.")
