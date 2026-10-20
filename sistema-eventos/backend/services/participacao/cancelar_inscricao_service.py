"""
Caso de uso: cancelar a inscrição de um usuário em uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Cancelar Inscrição").

Ao cancelar, a vaga é devolvida à palestra (respeitando o limite de
`vagas_total`, para nunca ultrapassar a capacidade original).

Método principal:
    execute(id_usuario, id_palestra): remove a Participacao e devolve a vaga.
"""

from backend.extensions import db
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao


class CancelarInscricaoService:
    """Caso de uso responsável por cancelar uma inscrição existente."""

    def execute(self, id_usuario, id_palestra):
        inscricao = Participacao.query.filter_by(
            id_usuario=id_usuario, id_palestra=id_palestra
        ).first()
        if not inscricao:
            raise ValueError("Inscrição não encontrada.")

        palestra = Palestra.query.with_for_update().get(id_palestra)
        if palestra:
            palestra.vagas_disponiveis = min(
                palestra.vagas_total, palestra.vagas_disponiveis + 1
            )

        db.session.delete(inscricao)
        db.session.commit()
