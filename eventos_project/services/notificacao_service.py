from database.db import db
from models.notificacao import Notificacao
from models.usuario import Usuario


class NotificacaoService:
    """Regras de negócio das Notificações."""

    @staticmethod
    def listar_por_usuario(usuario_id):
        return Notificacao.query.filter_by(usuario_id=usuario_id).all()

    @staticmethod
    def buscar_por_id(notificacao_id):
        notificacao = Notificacao.query.get(notificacao_id)
        if not notificacao:
            raise ValueError("Notificação não encontrada.")
        return notificacao

    @staticmethod
    def enviar(usuario_id, mensagem):
        if not Usuario.query.get(usuario_id):
            raise ValueError("Usuário informado não existe.")
        if not mensagem or not mensagem.strip():
            raise ValueError("A mensagem da notificação não pode ser vazia.")

        notificacao = Notificacao(mensagem=mensagem.strip(), usuario_id=usuario_id)
        db.session.add(notificacao)
        db.session.commit()
        return notificacao

    @staticmethod
    def enviar_para_todos(mensagem):
        """Cria uma notificação para todos os usuários cadastrados (usado pelo Comunicado)."""
        usuarios = Usuario.query.all()
        notificacoes = []
        for usuario in usuarios:
            notificacao = Notificacao(mensagem=mensagem, usuario_id=usuario.id)
            db.session.add(notificacao)
            notificacoes.append(notificacao)
        db.session.commit()
        return notificacoes
