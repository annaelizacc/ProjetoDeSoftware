"""
Caso de uso: remover um usuário.

CAMADA: Services (regra de negócio do caso de uso "Remover Usuário").

Desde a F08, quem é responsável por algum evento não pode ser removido:
o banco recusaria (`ON DELETE RESTRICT` em `evento.id_organizador`), e
o evento ficaria sem responsável. O Service confere antes, para
responder com uma mensagem clara (400) em vez de um erro do banco (500).

Método principal:
    execute(id_usuario): remove o usuário ou lança ValueError se não
    existir ou se ainda for responsável por eventos.
"""

from backend.models.evento import Evento
from backend.models.organizador import Organizador
from backend.models.usuario import Usuario


class RemoverUsuarioService:
    """Caso de uso responsável pela remoção de um usuário."""

    def execute(self, id_usuario):
        organizador = Organizador.buscar_por_usuario(id_usuario)
        if organizador and Evento.query.filter_by(
            id_organizador=organizador.id_organizador
        ).first():
            raise ValueError(
                "Esta pessoa é responsável por eventos. Remova os eventos dela antes."
            )

        removido = Usuario.remover(id_usuario)
        if not removido:
            raise ValueError("Usuário não encontrado.")
