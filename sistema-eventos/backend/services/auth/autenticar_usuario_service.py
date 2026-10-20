"""
Caso de uso: autenticação de usuário (login).

CAMADA: Services (regra de negócio do caso de uso "Login").

O Controller de autenticação chama este Service quando recebe um POST em
`/api/auth/login`. O Service localiza o usuário pelo email e confere a
senha, sem se preocupar com sessão HTTP (isso é responsabilidade do
Controller) nem com como o dado chegou até aqui.

Por que a checagem de hash é "híbrida": o banco de demonstração fornecido
pelo professor tem senhas em texto puro (ex.: "hash123"), enquanto novos
usuários cadastrados pelo `CriarUsuarioService` usam hash do Werkzeug
(prefixo "pbkdf2:" ou "scrypt:"). Detectar o formato evita erros ao tentar
comparar um hash Werkzeug com `check_password_hash` de uma senha que não é
hash nenhum.

Usuários sem senha (preparo para a F18, quem entra só pelo Google) são
recusados aqui: não existe senha para comparar.

Método principal:
    execute(email, senha): retorna o Usuario autenticado, ou None.
"""

from werkzeug.security import check_password_hash

from backend.models.usuario import Usuario


class AutenticarUsuarioService:
    """Caso de uso responsável por validar as credenciais de login."""

    def execute(self, email, senha):
        usuario = Usuario.query.filter_by(email=email.strip().lower()).first()
        if not usuario or not usuario.senha:
            return None

        senha_e_hash = usuario.senha.startswith(("pbkdf2:", "scrypt:"))
        if senha_e_hash:
            senha_valida = check_password_hash(usuario.senha, senha)
        else:
            senha_valida = usuario.senha == senha

        return usuario if senha_valida else None
