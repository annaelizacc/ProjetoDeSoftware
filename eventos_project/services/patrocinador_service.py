from database.db import db
from models.patrocinador import Patrocinador
from models.evento import Evento


class PatrocinadorService:
    """Regras de negócio relacionadas ao Patrocinador."""

    @staticmethod
    def listar_todos():
        return Patrocinador.query.all()

    @staticmethod
    def buscar_por_id(patrocinador_id):
        patrocinador = Patrocinador.query.get(patrocinador_id)
        if not patrocinador:
            raise ValueError("Patrocinador não encontrado.")
        return patrocinador

    @staticmethod
    def criar(dados):
        if not dados.get("nome") or not dados.get("evento_id"):
            raise ValueError("Campos 'nome' e 'evento_id' são obrigatórios.")

        if not Evento.query.get(dados["evento_id"]):
            raise ValueError("Evento informado não existe.")

        patrocinador = Patrocinador(
            nome=dados["nome"],
            evento_id=dados["evento_id"],
            logo=dados.get("logo"),
            descricao=dados.get("descricao"),
        )
        db.session.add(patrocinador)
        db.session.commit()
        return patrocinador

    @staticmethod
    def atualizar(patrocinador_id, dados):
        patrocinador = PatrocinadorService.buscar_por_id(patrocinador_id)
        patrocinador.nome = dados.get("nome", patrocinador.nome)
        patrocinador.logo = dados.get("logo", patrocinador.logo)
        patrocinador.descricao = dados.get("descricao", patrocinador.descricao)
        db.session.commit()
        return patrocinador

    @staticmethod
    def deletar(patrocinador_id):
        patrocinador = PatrocinadorService.buscar_por_id(patrocinador_id)
        db.session.delete(patrocinador)
        db.session.commit()

    @staticmethod
    def exibir_informacoes(patrocinador_id):
        patrocinador = PatrocinadorService.buscar_por_id(patrocinador_id)
        return patrocinador.to_dict()
