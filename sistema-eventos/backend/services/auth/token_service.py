"""
Caso de uso: criar e conferir o token de login.

CAMADA: Services (regra de negócio da autenticação por token).

O token é a "pulseira" que a pessoa recebe no login: um texto assinado
com a `SECRET_KEY` que leva o `id_usuario` e a hora em que foi criado.
O app guarda esse texto e o envia em toda requisição, no cabeçalho
`Authorization: Bearer <token>`, e a API descobre quem fez o pedido sem
confiar no que veio no corpo ou na URL.

Por que `itsdangerous`: a biblioteca já vem instalada junto com o Flask
(é ela que o Flask usa para assinar a sessão). Assinar não esconde o
conteúdo (qualquer pessoa consegue ler o `id_usuario` do token), mas
impede que ele seja alterado ou fabricado sem a `SECRET_KEY`. Por isso
o token nunca leva senha nem outro dado sensível.

O `salt` separa os tokens de login de outras assinaturas feitas com a
mesma chave: uma assinatura criada para outro fim não serve como token.

Métodos principais:
    gerar(usuario): devolve o token do usuário.
    buscar_usuario(token): devolve o Usuario dono do token, ou None se o
        token for inválido, estiver vencido ou o usuário não existir mais.
"""

from flask import current_app
from itsdangerous import BadSignature, URLSafeTimedSerializer

from backend.models.usuario import Usuario

# 8 horas: um dia de evento. Depois disso, é preciso fazer login de novo.
VALIDADE_SEGUNDOS = 8 * 60 * 60


class TokenService:
    """Caso de uso responsável por criar e validar tokens de login."""

    def _serializador(self):
        return URLSafeTimedSerializer(current_app.config["SECRET_KEY"], salt="token-login")

    def gerar(self, usuario):
        return self._serializador().dumps({"id_usuario": usuario.id_usuario})

    def buscar_usuario(self, token):
        try:
            # `max_age` confere a hora gravada dentro do token. Token
            # vencido (`SignatureExpired`) é um tipo de `BadSignature`.
            dados = self._serializador().loads(token, max_age=VALIDADE_SEGUNDOS)
        except BadSignature:
            return None
        return Usuario.buscar_por_id(dados.get("id_usuario"))
