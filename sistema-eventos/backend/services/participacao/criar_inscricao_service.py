"""
Caso de uso: inscrever um usuário em uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Inscrever-se").

Regras preservadas da versão anterior do projeto:
- o usuário precisa existir;
- a palestra precisa existir e ter vaga disponível;
- o mesmo usuário não pode se inscrever duas vezes na mesma palestra;
- a linha da palestra é bloqueada (`with_for_update`) durante a operação,
  para que duas inscrições simultâneas não consumam a mesma última vaga.

Este caso de uso mexe em DUAS entidades ao mesmo tempo (cria a
Participacao e decrementa `vagas_disponiveis` da Palestra), por isso a
regra fica no Service, e não em nenhuma das duas Models isoladamente.

Método principal:
    execute(id_usuario, id_palestra): cria e retorna a Participacao.
"""

from backend.extensions import db
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.usuario import Usuario


class CriarInscricaoService:
    """Caso de uso responsável por inscrever um usuário em uma palestra."""

    def execute(self, id_usuario, id_palestra):
        if not Usuario.buscar_por_id(id_usuario):
            raise ValueError("Usuário não encontrado.")

        palestra = (
            Palestra.query.with_for_update().filter_by(id_palestra=id_palestra).first()
        )
        if not palestra:
            raise ValueError("Palestra não encontrada.")

        ja_inscrito = Participacao.query.filter_by(
            id_usuario=id_usuario, id_palestra=id_palestra
        ).first()
        if ja_inscrito:
            raise ValueError("Usuário já está inscrito nesta palestra.")

        if palestra.vagas_disponiveis <= 0:
            raise ValueError("Não há vagas disponíveis para esta palestra.")

        inscricao = Participacao(id_usuario=id_usuario, id_palestra=id_palestra)
        palestra.vagas_disponiveis -= 1
        db.session.add(inscricao)
        db.session.commit()
        return inscricao
