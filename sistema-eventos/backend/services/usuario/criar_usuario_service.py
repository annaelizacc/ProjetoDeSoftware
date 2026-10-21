"""
Caso de uso: cadastro de um novo usuário.

CAMADA: Services (regra de negócio do caso de uso "Criar Usuário").

O Controller chama este Service ao receber um POST de cadastro. O Service
valida os campos obrigatórios, garante que o email ainda não está em uso
e gera o hash da senha antes de delegar a persistência para a Model
(`Usuario.criar`). Gerar o hash aqui, e não na Model, mantém a Model livre
de decisões de segurança e deixa essa responsabilidade no caso de uso que
realmente sabe de onde a senha em texto puro está vindo.

Todo cadastro cria um participante (P01): o cadastro é público, então,
se aceitasse o `tipo_usuario` enviado, qualquer pessoa poderia se
cadastrar como organizador. Um `tipo_usuario` recebido é ignorado.
Organizadores são criados direto no banco (ver README).

Nome, email e senha passam pelas validações de `validacoes_usuario.py`
(F01): nome preenchido, email em formato válido e senha com 8 a 16
caracteres. As mesmas regras valem na atualização.

O email repetido é conferido antes de gravar, para devolver uma mensagem
clara. Se dois cadastros com o mesmo email chegarem ao mesmo tempo (ex.:
toque duplo no botão), os dois passam pela conferência, e o banco recusa
o segundo pela coluna única: esse erro (`IntegrityError`) também vira a
mesma mensagem clara, como no `CriarAvaliacaoService`.

Método principal:
    execute(dados): cria e retorna o novo Usuario.
"""

from sqlalchemy.exc import IntegrityError
from werkzeug.security import generate_password_hash

from backend.extensions import db
from backend.models.usuario import TIPO_PARTICIPANTE, Usuario
from backend.services.usuario.validacoes_usuario import (
    validar_email,
    validar_nome,
    validar_senha,
)


class CriarUsuarioService:
    """Caso de uso responsável pelo cadastro de um novo usuário."""

    def execute(self, dados):
        nome = validar_nome(dados.get("nome"))
        email = validar_email(dados.get("email"))
        senha = validar_senha(dados.get("senha"))

        if Usuario.query.filter_by(email=email).first():
            raise ValueError("Já existe um usuário cadastrado com este email.")

        try:
            return Usuario.criar(
                nome=nome,
                email=email,
                senha=generate_password_hash(senha),
                tipo_usuario=TIPO_PARTICIPANTE,
            )
        except IntegrityError:
            db.session.rollback()
            raise ValueError("Já existe um usuário cadastrado com este email.")
