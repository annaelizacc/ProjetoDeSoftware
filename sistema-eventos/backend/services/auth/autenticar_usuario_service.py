"""
Caso de uso: autenticação de usuário (login).

CAMADA: Services (regra de negócio do caso de uso "Login").

O Controller de autenticação chama este Service quando recebe um POST em
`/api/auth/login`. O Service localiza o usuário pelo email e confere a
senha, sem se preocupar com sessão HTTP (isso é responsabilidade do
Controller) nem com como o dado chegou até aqui.

Só senhas guardadas como hash do Werkzeug são aceitas (P02). O hash é
gerado no cadastro (`CriarUsuarioService`) e não pode ser revertido para
a senha original: no login, `check_password_hash` calcula o hash do que
foi digitado e compara com o guardado. Uma senha gravada em texto puro
no banco (sem o prefixo "scrypt:" ou "pbkdf2:") é recusada, e a única
forma de liberar a conta é gravar um hash no banco (por exemplo,
recriando o banco com o script de `database/`).

Antes de calcular o hash, a senha digitada precisa ser texto e ter no
máximo `TAMANHO_MAXIMO_SENHA` caracteres: a rota de login é pública, e
calcular o hash de um texto enorme gastaria processamento do servidor.
Um valor que não é texto (número, lista) também quebraria o cálculo e
viraria erro 500.

Usuários sem senha (preparo para a F18, quem entra só pelo Google) são
recusados aqui: não existe senha para comparar.

Método principal:
    execute(email, senha): retorna o Usuario autenticado, ou None.
"""

from werkzeug.security import check_password_hash

from backend.models.usuario import TAMANHO_MAXIMO_SENHA, Usuario


class AutenticarUsuarioService:
    """Caso de uso responsável por validar as credenciais de login."""

    def execute(self, email, senha):
        if not isinstance(email, str) or not isinstance(senha, str):
            return None
        if len(senha) > TAMANHO_MAXIMO_SENHA:
            return None

        usuario = Usuario.query.filter_by(email=email.strip().lower()).first()
        if not usuario or not usuario.senha:
            return None

        # Senha em texto puro no banco: recusa sem tentar comparar.
        if not usuario.senha.startswith(("scrypt:", "pbkdf2:")):
            return None

        return usuario if check_password_hash(usuario.senha, senha) else None
