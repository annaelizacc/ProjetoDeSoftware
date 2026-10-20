"""
Controller: Usuário.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Este Controller é NOVO nesta refatoração: o projeto já tinha a Model e o
login, mas não expunha CRUD de usuário via API. Ele foi adicionado sem
alterar nenhum endpoint existente, então não há risco de quebrar o que o
Flutter já consome — é uma extensão pura.
"""

from flask import Blueprint, jsonify, request

from backend.controllers.utils import tratar_erros
from backend.services.usuario.listar_usuarios_service import ListarUsuariosService
from backend.services.usuario.buscar_usuario_service import BuscarUsuarioService
from backend.services.usuario.criar_usuario_service import CriarUsuarioService
from backend.services.usuario.atualizar_usuario_service import AtualizarUsuarioService
from backend.services.usuario.remover_usuario_service import RemoverUsuarioService


class UsuarioController:
    """Controller responsável pelos endpoints de usuário."""

    @staticmethod
    @tratar_erros
    def listar():
        usuarios = ListarUsuariosService().execute()
        return jsonify([usuario.to_dict() for usuario in usuarios])

    @staticmethod
    @tratar_erros
    def buscar(id_usuario):
        usuario = BuscarUsuarioService().execute(id_usuario)
        return jsonify(usuario.to_dict())

    @staticmethod
    @tratar_erros
    def criar():
        usuario = CriarUsuarioService().execute(request.get_json() or {})
        return jsonify(usuario.to_dict()), 201

    @staticmethod
    @tratar_erros
    def atualizar(id_usuario):
        usuario = AtualizarUsuarioService().execute(id_usuario, request.get_json() or {})
        return jsonify(usuario.to_dict())

    @staticmethod
    @tratar_erros
    def remover(id_usuario):
        RemoverUsuarioService().execute(id_usuario)
        return jsonify({"mensagem": "Usuário removido."})


usuario_bp = Blueprint("usuarios", __name__, url_prefix="/api/usuarios")
usuario_bp.add_url_rule("", view_func=UsuarioController.listar, methods=["GET"])
usuario_bp.add_url_rule("", view_func=UsuarioController.criar, methods=["POST"])
usuario_bp.add_url_rule("/<int:id_usuario>", view_func=UsuarioController.buscar, methods=["GET"])
usuario_bp.add_url_rule(
    "/<int:id_usuario>", view_func=UsuarioController.atualizar, methods=["PUT", "PATCH"]
)
usuario_bp.add_url_rule(
    "/<int:id_usuario>", view_func=UsuarioController.remover, methods=["DELETE"]
)
