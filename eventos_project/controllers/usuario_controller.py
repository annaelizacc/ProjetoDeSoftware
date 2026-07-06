from flask import Blueprint, request, jsonify

from services.usuario_service import UsuarioService
from controllers.utils import handle_errors

usuario_bp = Blueprint("usuario", __name__)


@usuario_bp.route("/", methods=["GET"])
@handle_errors
def listar():
    usuarios = UsuarioService.listar_todos()
    return jsonify([u.to_dict() for u in usuarios]), 200


@usuario_bp.route("/<int:usuario_id>", methods=["GET"])
@handle_errors
def buscar_por_id(usuario_id):
    usuario = UsuarioService.buscar_por_id(usuario_id)
    return jsonify(usuario.to_dict()), 200


@usuario_bp.route("/cadastro", methods=["POST"])
@handle_errors
def cadastrar():
    dados = request.get_json() or {}
    usuario = UsuarioService.cadastrar(dados.get("nome"), dados.get("email"), dados.get("senha"))
    return jsonify(usuario.to_dict()), 201


@usuario_bp.route("/login", methods=["POST"])
@handle_errors
def login():
    dados = request.get_json() or {}
    usuario = UsuarioService.login(dados.get("email"), dados.get("senha"))
    return jsonify(usuario.to_dict()), 200


@usuario_bp.route("/<int:usuario_id>/tema", methods=["PUT"])
@handle_errors
def alterar_tema(usuario_id):
    dados = request.get_json() or {}
    usuario = UsuarioService.alterar_tema(usuario_id, dados.get("modo_escuro", False))
    return jsonify(usuario.to_dict()), 200


@usuario_bp.route("/<int:usuario_id>/agenda", methods=["GET"])
@handle_errors
def visualizar_agenda(usuario_id):
    agenda = UsuarioService.visualizar_agenda(usuario_id)
    return jsonify(agenda), 200


@usuario_bp.route("/<int:usuario_id>/pesquisar-palestra", methods=["GET"])
@handle_errors
def pesquisar_palestra(usuario_id):
    # usuario_id mantido na rota por semântica do UML, mas a pesquisa em si é global
    nome = request.args.get("nome", "")
    palestras = UsuarioService.pesquisar_palestra(nome)
    return jsonify([p.to_dict() for p in palestras]), 200


@usuario_bp.route("/<int:usuario_id>/favoritar", methods=["POST"])
@handle_errors
def favoritar_palestra(usuario_id):
    dados = request.get_json() or {}
    favorito = UsuarioService.favoritar_palestra(usuario_id, dados.get("palestra_id"))
    return jsonify(favorito.to_dict()), 201


@usuario_bp.route("/<int:usuario_id>/desfavoritar", methods=["POST"])
@handle_errors
def desfavoritar_palestra(usuario_id):
    dados = request.get_json() or {}
    UsuarioService.desfavoritar_palestra(usuario_id, dados.get("palestra_id"))
    return jsonify({"mensagem": "Palestra removida dos favoritos."}), 200


@usuario_bp.route("/<int:usuario_id>/inscrever", methods=["POST"])
@handle_errors
def inscrever_palestra(usuario_id):
    dados = request.get_json() or {}
    inscricao = UsuarioService.inscrever_palestra(usuario_id, dados.get("palestra_id"))
    return jsonify(inscricao.to_dict()), 201


@usuario_bp.route("/inscricao/<int:inscricao_id>", methods=["DELETE"])
@handle_errors
def cancelar_inscricao(inscricao_id):
    UsuarioService.cancelar_inscricao(inscricao_id)
    return jsonify({"mensagem": "Inscrição cancelada com sucesso."}), 200


@usuario_bp.route("/<int:usuario_id>/feedback", methods=["POST"])
@handle_errors
def enviar_feedback(usuario_id):
    dados = request.get_json() or {}
    feedback = UsuarioService.enviar_feedback(
        usuario_id, dados.get("palestra_id"), dados.get("comentario")
    )
    return jsonify(feedback.to_dict()), 201


@usuario_bp.route("/<int:usuario_id>/avaliar", methods=["POST"])
@handle_errors
def avaliar_palestra(usuario_id):
    dados = request.get_json() or {}
    avaliacao = UsuarioService.avaliar_palestra(
        usuario_id, dados.get("palestra_id"), dados.get("estrelas")
    )
    return jsonify(avaliacao.to_dict()), 201
