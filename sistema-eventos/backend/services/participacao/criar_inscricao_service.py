"""
Caso de uso: inscrever um usuário em uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Inscrever-se").

Regras preservadas da versão anterior do projeto:
- o usuário precisa existir;
- a palestra precisa existir e ter vaga disponível;
- o mesmo usuário não pode se inscrever duas vezes na mesma palestra;
- a linha da palestra é bloqueada (`with_for_update`) durante a operação,
  para que duas inscrições simultâneas não consumam a mesma última vaga.

Regra da F16 (S01), choque de horário: se a pessoa já tem inscrição em
outra palestra no mesmo horário, a inscrição NÃO é bloqueada, mas o
Service avisa (levantando `ChoqueDeHorario`) e só inscreve quando o app
manda `confirmar_choque = True`, depois que a pessoa confirmou no aviso.
Duas palestras "batem" quando uma começa antes de a outra terminar e
termina depois de a outra começar.

Este caso de uso mexe em DUAS entidades ao mesmo tempo (cria a
Participacao e decrementa `vagas_disponiveis` da Palestra), por isso a
regra fica no Service, e não em nenhuma das duas Models isoladamente.

Método principal:
    execute(id_usuario, id_palestra, confirmar_choque=False): cria e
    retorna a Participacao.
"""

from backend.extensions import db
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.usuario import Usuario


class ChoqueDeHorario(Exception):
    """A pessoa já tem inscrição em uma palestra no mesmo horário (F16).

    Não é um erro de verdade: o Controller transforma em uma resposta 409
    com os dados da palestra que bate no horário, e o app pergunta se a
    pessoa quer se inscrever mesmo assim.
    """

    def __init__(self, palestra_conflitante):
        super().__init__(
            "Você já tem inscrição em uma palestra nesse horário. "
            "Deseja mesmo se inscrever nesta?"
        )
        self.palestra_conflitante = palestra_conflitante


class CriarInscricaoService:
    """Caso de uso responsável por inscrever um usuário em uma palestra."""

    def execute(self, id_usuario, id_palestra, confirmar_choque=False):
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

        if not confirmar_choque:
            conflitante = self._palestra_no_mesmo_horario(id_usuario, palestra)
            if conflitante:
                # Libera o bloqueio da linha da palestra antes de avisar.
                db.session.rollback()
                raise ChoqueDeHorario(conflitante)

        inscricao = Participacao(id_usuario=id_usuario, id_palestra=id_palestra)
        palestra.vagas_disponiveis -= 1
        db.session.add(inscricao)
        db.session.commit()
        return inscricao

    @staticmethod
    def _palestra_no_mesmo_horario(id_usuario, palestra):
        """Devolve uma palestra em que a pessoa já está inscrita e que bate
        no horário com `palestra`, ou None. Palestra sem horário não
        entra na conta."""
        if not palestra.horario_inicio or not palestra.horario_fim:
            return None
        return (
            Palestra.query.join(
                Participacao, Participacao.id_palestra == Palestra.id_palestra
            )
            .filter(
                Participacao.id_usuario == id_usuario,
                Palestra.id_palestra != palestra.id_palestra,
                Palestra.horario_inicio < palestra.horario_fim,
                Palestra.horario_fim > palestra.horario_inicio,
            )
            .first()
        )
