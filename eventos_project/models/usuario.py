from database.db import db


class Usuario(db.Model):
    """
    Usuário do sistema. Classe base da herança Usuario -> Organizador.

    Estratégia de herança: Single Table Inheritance (uma única tabela
    "usuario" com a coluna discriminadora "tipo"), já que Organizador
    não possui atributos próprios no diagrama, apenas comportamento extra.

    Relacionamentos:
      - 1:N com Inscricao, Favorito, Feedback, Avaliacao, Notificacao
    """

    __tablename__ = "usuario"

    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), nullable=False, unique=True)
    senha = db.Column(db.String(255), nullable=False)  # necessário para login(), não estava no UML
    modo_escuro = db.Column(db.Boolean, default=False)

    # Coluna discriminadora da herança
    tipo = db.Column(db.String(20), nullable=False, default="usuario")

    __mapper_args__ = {
        "polymorphic_identity": "usuario",
        "polymorphic_on": tipo,
    }

    inscricoes = db.relationship("Inscricao", back_populates="usuario", cascade="all, delete-orphan")
    favoritos = db.relationship("Favorito", back_populates="usuario", cascade="all, delete-orphan")
    feedbacks = db.relationship("Feedback", back_populates="usuario", cascade="all, delete-orphan")
    avaliacoes = db.relationship("Avaliacao", back_populates="usuario", cascade="all, delete-orphan")
    notificacoes = db.relationship("Notificacao", back_populates="usuario", cascade="all, delete-orphan")

    def __init__(self, nome, email, senha, modo_escuro=False):
        self.nome = nome
        self.email = email
        self.senha = senha
        self.modo_escuro = modo_escuro

    def to_dict(self):
        return {
            "id": self.id,
            "nome": self.nome,
            "email": self.email,
            "modo_escuro": self.modo_escuro,
            "tipo": self.tipo,
        }

    def __repr__(self):
        return f"<Usuario {self.id} - {self.nome}>"
