from werkzeug.security import generate_password_hash, check_password_hash

from database.db import db
from models.usuario import Usuario
from services.favorito_service import FavoritoService
from services.inscricao_service import InscricaoService
from services.feedback_service import FeedbackService
from services.avaliacao_service import AvaliacaoService
from services.palestra_service import PalestraService


class UsuarioService:
    """
    Regras de negócio do Usuario.
    Vários métodos aqui apenas orquestram/delegam para services mais específicos
    (Inscricao, Favorito, Feedback, Avaliacao), conforme o diagrama concentra
    essas ações na classe Usuario.
    """

    @staticmethod
    def listar_todos():
        return Usuario.query.all()

    @staticmethod
    def buscar_por_id(usuario_id):
        usuario = Usuario.query.get(usuario_id)
        if not usuario:
            raise ValueError("Usuário não encontrado.")
        return usuario

    @staticmethod
    def cadastrar(nome, email, senha):
        if not nome or not email or not senha:
            raise ValueError("Campos 'nome', 'email' e 'senha' são obrigatórios.")

        if Usuario.query.filter_by(email=email).first():
            raise ValueError("Já existe um usuário cadastrado com este e-mail.")

        usuario = Usuario(nome=nome, email=email, senha=generate_password_hash(senha))
        db.session.add(usuario)
        db.session.commit()
        return usuario

    @staticmethod
    def login(email, senha):
        usuario = Usuario.query.filter_by(email=email).first()
        if not usuario or not check_password_hash(usuario.senha, senha):
            raise ValueError("E-mail ou senha inválidos.")
        return usuario

    @staticmethod
    def alterar_tema(usuario_id, modo_escuro):
        usuario = UsuarioService.buscar_por_id(usuario_id)
        usuario.modo_escuro = bool(modo_escuro)
        db.session.commit()
        return usuario

    # --- Ações delegadas (a classe Usuario concentra essas chamadas no diagrama) ---

    @staticmethod
    def favoritar_palestra(usuario_id, palestra_id):
        return FavoritoService.adicionar(usuario_id, palestra_id)

    @staticmethod
    def desfavoritar_palestra(usuario_id, palestra_id):
        return FavoritoService.remover(usuario_id, palestra_id)

    @staticmethod
    def inscrever_palestra(usuario_id, palestra_id):
        return InscricaoService.criar(usuario_id, palestra_id)

    @staticmethod
    def cancelar_inscricao(inscricao_id):
        return InscricaoService.cancelar(inscricao_id)

    @staticmethod
    def pesquisar_palestra(nome):
        return PalestraService.pesquisar_por_nome(nome)

    @staticmethod
    def enviar_feedback(usuario_id, palestra_id, comentario):
        return FeedbackService.registrar_comentario(usuario_id, palestra_id, comentario)

    @staticmethod
    def avaliar_palestra(usuario_id, palestra_id, estrelas):
        return AvaliacaoService.avaliar(usuario_id, palestra_id, estrelas)

    @staticmethod
    def visualizar_agenda(usuario_id):
        """
        Retorna a 'AgendaPersonalizada' do usuário: palestras em que está
        inscrito + palestras favoritadas.
        """
        usuario = UsuarioService.buscar_por_id(usuario_id)
        return {
            "inscricoes": [i.to_dict() for i in usuario.inscricoes],
            "favoritos": [f.to_dict() for f in usuario.favoritos],
        }
