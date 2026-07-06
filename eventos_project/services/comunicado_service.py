from database.db import db
from models.comunicado import Comunicado
from models.organizador import Organizador
from services.notificacao_service import NotificacaoService


class ComunicadoService:
    """
    Regras de negócio dos Comunicados.
    Ao publicar um comunicado, uma Notificacao é gerada para todos os usuários
    (regra de negócio que preenche a lacuna identificada na Etapa 1: o diagrama
    não desenha uma relação direta entre Comunicado e Notificacao).
    """

    @staticmethod
    def listar_todos():
        return Comunicado.query.all()

    @staticmethod
    def buscar_por_id(comunicado_id):
        comunicado = Comunicado.query.get(comunicado_id)
        if not comunicado:
            raise ValueError("Comunicado não encontrado.")
        return comunicado

    @staticmethod
    def criar(organizador_id, titulo, mensagem):
        organizador = Organizador.query.get(organizador_id)
        if not organizador:
            raise ValueError("Organizador informado não existe.")
        if not titulo or not mensagem:
            raise ValueError("Campos 'titulo' e 'mensagem' são obrigatórios.")

        comunicado = Comunicado(titulo=titulo, mensagem=mensagem, organizador_id=organizador_id)
        db.session.add(comunicado)
        db.session.commit()
        return comunicado

    @staticmethod
    def publicar(comunicado_id):
        """Confirma a publicação e dispara notificações para todos os usuários."""
        comunicado = ComunicadoService.buscar_por_id(comunicado_id)
        NotificacaoService.enviar_para_todos(f"[{comunicado.titulo}] {comunicado.mensagem}")
        return comunicado

    @staticmethod
    def deletar(comunicado_id):
        comunicado = ComunicadoService.buscar_por_id(comunicado_id)
        db.session.delete(comunicado)
        db.session.commit()
