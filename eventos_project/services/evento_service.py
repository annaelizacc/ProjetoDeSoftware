from database.db import db
from models.evento import Evento
from models.palestra import Palestra
from models.patrocinador import Patrocinador


class EventoService:
    """Regras de negócio relacionadas ao Evento."""

    @staticmethod
    def listar_todos():
        return Evento.query.all()

    @staticmethod
    def buscar_por_id(evento_id):
        evento = Evento.query.get(evento_id)
        if not evento:
            raise ValueError("Evento não encontrado.")
        return evento

    @staticmethod
    def criar(dados):
        if not dados.get("nome") or not dados.get("local") or not dados.get("data"):
            raise ValueError("Campos 'nome', 'local' e 'data' são obrigatórios.")

        evento = Evento(local=dados["local"], data=dados["data"], nome=dados["nome"])
        db.session.add(evento)
        db.session.commit()
        return evento

    @staticmethod
    def atualizar(evento_id, dados):
        evento = EventoService.buscar_por_id(evento_id)
        evento.nome = dados.get("nome", evento.nome)
        evento.local = dados.get("local", evento.local)
        evento.data = dados.get("data", evento.data)
        db.session.commit()
        return evento

    @staticmethod
    def deletar(evento_id):
        evento = EventoService.buscar_por_id(evento_id)
        db.session.delete(evento)
        db.session.commit()

    @staticmethod
    def listar_programacao(evento_id):
        """Retorna todas as Palestras associadas ao Evento (ordenadas por horário)."""
        EventoService.buscar_por_id(evento_id)  # valida existência
        return (
            Palestra.query.filter_by(evento_id=evento_id)
            .order_by(Palestra.horario.asc())
            .all()
        )

    @staticmethod
    def listar_patrocinadores(evento_id):
        """Retorna todos os Patrocinadores associados ao Evento."""
        EventoService.buscar_por_id(evento_id)
        return Patrocinador.query.filter_by(evento_id=evento_id).all()
