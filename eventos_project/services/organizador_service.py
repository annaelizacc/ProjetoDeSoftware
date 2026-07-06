from database.db import db
from models.organizador import Organizador
from models.inscricao import Inscricao
from services.comunicado_service import ComunicadoService


class OrganizadorService:
    """Regras de negócio específicas do Organizador."""

    @staticmethod
    def buscar_por_id(organizador_id):
        organizador = Organizador.query.get(organizador_id)
        if not organizador:
            raise ValueError("Organizador não encontrado.")
        return organizador

    @staticmethod
    def cadastrar(nome, email, senha):
        from werkzeug.security import generate_password_hash

        if Organizador.query.filter_by(email=email).first():
            raise ValueError("Já existe um usuário cadastrado com este e-mail.")

        organizador = Organizador(nome=nome, email=email, senha=generate_password_hash(senha))
        db.session.add(organizador)
        db.session.commit()
        return organizador

    @staticmethod
    def gerenciar_inscricoes(palestra_id=None, status=None):
        """Lista as inscrições do evento, opcionalmente filtradas por palestra/status."""
        query = Inscricao.query
        if palestra_id:
            query = query.filter_by(palestra_id=palestra_id)
        if status:
            query = query.filter_by(status=status)
        return query.all()

    @staticmethod
    def enviar_comunicado(organizador_id, titulo, mensagem):
        """Cria o Comunicado e já publica (dispara as notificações)."""
        OrganizadorService.buscar_por_id(organizador_id)
        comunicado = ComunicadoService.criar(organizador_id, titulo, mensagem)
        return ComunicadoService.publicar(comunicado.id)
