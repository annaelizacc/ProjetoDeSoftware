from database.db import db
from models.inscricao import Inscricao
from models.palestra import Palestra
from models.usuario import Usuario


class InscricaoService:
    """
    Regras de negócio das Inscrições.
    Responsável por garantir que não se inscreva além das vagas disponíveis
    e por manter o contador de vagas da Palestra consistente.
    """

    @staticmethod
    def listar_todas():
        return Inscricao.query.all()

    @staticmethod
    def listar_por_usuario(usuario_id):
        return Inscricao.query.filter_by(usuario_id=usuario_id).all()

    @staticmethod
    def listar_por_palestra(palestra_id):
        return Inscricao.query.filter_by(palestra_id=palestra_id).all()

    @staticmethod
    def buscar_por_id(inscricao_id):
        inscricao = Inscricao.query.get(inscricao_id)
        if not inscricao:
            raise ValueError("Inscrição não encontrada.")
        return inscricao

    @staticmethod
    def criar(usuario_id, palestra_id):
        if not Usuario.query.get(usuario_id):
            raise ValueError("Usuário informado não existe.")

        palestra = Palestra.query.get(palestra_id)
        if not palestra:
            raise ValueError("Palestra informada não existe.")

        if Inscricao.query.filter_by(usuario_id=usuario_id, palestra_id=palestra_id).first():
            raise ValueError("Usuário já está inscrito nesta palestra.")

        if palestra.vagas_disponiveis <= 0:
            raise ValueError("Não há vagas disponíveis para esta palestra.")

        inscricao = Inscricao(usuario_id=usuario_id, palestra_id=palestra_id, status="pendente")
        palestra.vagas_disponiveis -= 1

        db.session.add(inscricao)
        db.session.commit()
        return inscricao

    @staticmethod
    def confirmar(inscricao_id):
        inscricao = InscricaoService.buscar_por_id(inscricao_id)
        inscricao.status = "confirmada"
        db.session.commit()
        return True

    @staticmethod
    def cancelar(inscricao_id):
        inscricao = InscricaoService.buscar_por_id(inscricao_id)

        # devolve a vaga para a palestra
        palestra = Palestra.query.get(inscricao.palestra_id)
        if palestra:
            palestra.vagas_disponiveis += 1

        db.session.delete(inscricao)
        db.session.commit()
        return True
