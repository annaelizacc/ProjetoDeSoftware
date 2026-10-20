"""
Controller: Autenticação (login/logout).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Responsabilidade: ler o corpo da requisição, chamar o
`AutenticarUsuarioService`, guardar o usuário logado na sessão Flask e
devolver a resposta HTTP. Nenhuma regra de negócio vive aqui.
"""

from flask import Blueprint, jsonify, request, session

from backend.controllers.utils import tratar_erros
from backend.services.auth.autenticar_usuario_service import AutenticarUsuarioService


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

        session["id_usuario"] = usuario.id_usuario
        return jsonify({"mensagem": "Login realizado.", "usuario": usuario.to_dict()})

    @staticmethod
    def me():
        if "id_usuario" not in session:
            return jsonify({"erro": "Nenhum usuário logado."}), 401
        return jsonify({"id_usuario": session["id_usuario"]})

    @staticmethod
    def logout():
        session.clear()
        return jsonify({"mensagem": "Logout realizado."})


auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")
auth_bp.add_url_rule("/login", view_func=AuthController.login, methods=["POST"])
auth_bp.add_url_rule("/me", view_func=AuthController.me, methods=["GET"])
auth_bp.add_url_rule("/logout", view_func=AuthController.logout, methods=["POST"])
