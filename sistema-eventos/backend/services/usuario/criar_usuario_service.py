"""
Caso de uso: cadastro de um novo usuário.

CAMADA: Services (regra de negócio do caso de uso "Criar Usuário").

O Controller chama este Service ao receber um POST de cadastro. O Service
valida os campos obrigatórios, garante que o email ainda não está em uso
e gera o hash da senha antes de delegar a persistência para a Model
(`Usuario.criar`). Gerar o hash aqui, e não na Model, mantém a Model livre
de decisões de segurança e deixa essa responsabilidade no caso de uso que
realmente sabe de onde a senha em texto puro está vindo.

Método principal:
    execute(dados): cria e retorna o novo Usuario.
"""

from werkzeug.security import generate_password_hash

from backend.models.usuario import Usuario


class CriarUsuarioService:
    """Caso de uso responsável pelo cadastro de um novo usuário."""

    def execute(self, dados):
        obrigatorios = ("nome", "email", "senha", "tipo_usuario")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("nome, email, senha e tipo_usuario são obrigatórios.")

        email = dados["email"].strip().lower()
        if Usuario.query.filter_by(email=email).first():
            raise ValueError("Já existe um usuário cadastrado com este email.")

        return Usuario.criar(
            nome=dados["nome"],
            email=email,
            senha=generate_password_hash(dados["senha"]),
            tipo_usuario=dados["tipo_usuario"],
        )
