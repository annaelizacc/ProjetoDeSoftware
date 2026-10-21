"""
Controller: Notificação/Lembrete.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Acesso (P01): exige login. A lista só pode ser vista pela própria pessoa,
e adicionar ou remover vale sempre para a pessoa logada (o `id_usuario`
vem do token; um `id_usuario` enviado no corpo é ignorado).
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import login_obrigatorio, verificar_acesso_ao_usuario
from backend.controllers.utils import tratar_erros
from backend.services.notificacao.listar_notificacoes_service import ListarNotificacoesService
from backend.services.notificacao.ativar_lembrete_service import AtivarLembreteService
from backend.services.notificacao.desativar_lembrete_service import DesativarLembreteService


class NotificacaoController:
    """Controller responsável pelos endpoints de notificações e lembretes."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar(id_usuario):
        verificar_acesso_ao_usuario(id_usuario)
        return jsonify(ListarNotificacoesService().execute(id_usuario))

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def ativar():
        dados = request.get_json() or {}
        lembrete = AtivarLembreteService().execute(
            g.usuario.id_usuario, dados.get("id_palestra")
        )
        return jsonify(lembrete.to_dict()), 201

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def desativar():
        dados = request.get_json() or {}
        DesativarLembreteService().execute(g.usuario.id_usuario, dados.get("id_palestra"))
        return jsonify({"mensagem": "Lembrete desativado."})


notificacao_bp = Blueprint("notificacoes", __name__, url_prefix="/api")
notificacao_bp.add_url_rule(
    "/notificacoes/usuario/<int:id_usuario>",
    view_func=NotificacaoController.listar,
    methods=["GET"],
)
notificacao_bp.add_url_rule("/lembretes", view_func=NotificacaoController.ativar, methods=["POST"])
notificacao_bp.add_url_rule(
    "/lembretes", view_func=NotificacaoController.desativar, methods=["DELETE"]
)
