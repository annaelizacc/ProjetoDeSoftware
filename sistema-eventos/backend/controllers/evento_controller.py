"""
Controller: Evento.

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Expõe o CRUD completo de eventos, além dos endpoints derivados de
programação e agenda que já existiam no projeto original.

Acesso (P01): consultar exige login; criar, atualizar e remover são só
para organizadores; a agenda só pode ser vista pela própria pessoa.
Desde a F08, o evento criado fica ligado a quem o criou, e só esse
organizador (ou um administrador) altera ou remove o evento. Desde a
F14, remover pede também a senha da pessoa logada.
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import (
    login_obrigatorio,
    somente_organizador,
    verificar_acesso_ao_usuario,
    verificar_dono_do_evento,
)
from backend.controllers.utils import tratar_erros
from backend.services.evento.listar_eventos_service import ListarEventosService
from backend.services.evento.buscar_evento_service import BuscarEventoService
from backend.services.evento.criar_evento_service import CriarEventoService
from backend.services.evento.atualizar_evento_service import AtualizarEventoService
from backend.services.evento.remover_evento_service import RemoverEventoService
from backend.services.evento.obter_programacao_service import ObterProgramacaoService
from backend.services.agenda.obter_agenda_usuario_service import ObterAgendaUsuarioService


class EventoController:
    """Controller responsável pelos endpoints de evento."""

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def listar():
        return jsonify(ListarEventosService().execute())

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def buscar(id_evento):
        evento = BuscarEventoService().execute(id_evento)
        return jsonify(evento.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def criar():
        evento = CriarEventoService().execute(request.get_json() or {}, g.usuario)
        return jsonify(evento.to_dict()), 201

    @staticmethod
    @tratar_erros
    @somente_organizador
    def atualizar(id_evento):
        verificar_dono_do_evento(id_evento)
        dados = request.get_json() or {}
        evento = AtualizarEventoService().execute(id_evento, dados)
        return jsonify(evento.to_dict())

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover(id_evento):
        verificar_dono_do_evento(id_evento)
        # A senha vai no corpo da requisição (F14): confirma que é a
        # própria pessoa que está apagando o evento.
        senha = (request.get_json(silent=True) or {}).get("senha")
        RemoverEventoService().execute(id_evento, g.usuario, senha)
        return jsonify({"mensagem": "Evento removido."})

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def programacao(id_evento):
        return jsonify(ObterProgramacaoService().execute(id_evento))

    @staticmethod
    @tratar_erros
    @login_obrigatorio
    def agenda(id_usuario):
        verificar_acesso_ao_usuario(id_usuario)
        return jsonify(ObterAgendaUsuarioService().execute(id_usuario))


evento_bp = Blueprint("eventos", __name__, url_prefix="/api/eventos")
evento_bp.add_url_rule("", view_func=EventoController.listar, methods=["GET"])
evento_bp.add_url_rule("", view_func=EventoController.criar, methods=["POST"])
evento_bp.add_url_rule("/<int:id_evento>", view_func=EventoController.buscar, methods=["GET"])
evento_bp.add_url_rule(
    "/<int:id_evento>", view_func=EventoController.atualizar, methods=["PUT", "PATCH"]
)
evento_bp.add_url_rule(
    "/<int:id_evento>", view_func=EventoController.remover, methods=["DELETE"]
)
evento_bp.add_url_rule(
    "/<int:id_evento>/programacao",
    view_func=EventoController.programacao,
    methods=["GET"],
)
evento_bp.add_url_rule(
    "/<int:id_usuario>/agenda",
    view_func=EventoController.agenda,
    methods=["GET"],
)
