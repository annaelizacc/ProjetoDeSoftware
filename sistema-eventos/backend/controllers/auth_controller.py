"""
Controller: Autenticação (login/logout).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Responsabilidade: ler o corpo da requisição, chamar o
`AutenticarUsuarioService` e, se o login der certo, devolver o token
criado pelo `TokenService` (P01). O app guarda esse token e o envia nas
próximas requisições. Nenhuma regra de negócio vive aqui.

O logout não precisa fazer nada no servidor: o token não fica guardado
na API, então quem "sai" é o app, apagando o token da memória.
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio
from backend.controllers.utils import tratar_erros
from backend.services.auth.autenticar_usuario_service import AutenticarUsuarioService
from backend.services.auth.token_service import TokenService


class AuthController:
    """Controller responsável pelos endpoints de login/logout."""

    @staticmethod
    @tratar_erros
    def login():
        dados = request.get_json() or {}
        email, senha = dados.get("email"), dados.get("senha")
        if not email or not senha:
            return jsonify({"erro": "email e senha são obrigatórios."}), 400

        usuario = AutenticarUsuarioService().execute(email, senha)
        if not usuario:
            return jsonify({"erro": "Email ou senha inválidos."}), 401

        return jsonify(
            {
                "mensagem": "Login realizado.",
                "usuario": usuario.to_dict(),
                "token": TokenService().gerar(usuario),
            }
        )

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def me():
        return jsonify(g.usuario.to_dict())

    @staticmethod
    def logout():
        return jsonify({"mensagem": "Logout realizado. Apague o token no app."})


auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")
auth_bp.add_url_rule("/login", view_func=AuthController.login, methods=["POST"])
auth_bp.add_url_rule("/me", view_func=AuthController.me, methods=["GET"])
auth_bp.add_url_rule("/logout", view_func=AuthController.logout, methods=["POST"])
