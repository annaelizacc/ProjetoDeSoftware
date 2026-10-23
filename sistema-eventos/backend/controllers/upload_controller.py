"""
Controller: Upload de imagens (F14).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

- `POST /api/uploads`: o organizador envia uma imagem em uma requisição
  "multipart/form-data" (o formato que o navegador e o app usam para
  mandar arquivos), no campo `imagem`. A resposta traz o nome com que o
  arquivo foi salvo, que o app grava depois no cadastro.
- `GET /uploads/<nome>`: devolve a imagem para o app mostrar com
  `Image.network`. É pública (sem login) porque as imagens aparecem para
  todos os participantes, como a planta e os logos.

Acesso (P01): enviar é só para organizadores.
"""

from flask import Blueprint, jsonify, request, send_from_directory
from werkzeug.exceptions import RequestEntityTooLarge

from backend.config import Config
from backend.controllers.autenticacao import somente_organizador
from backend.controllers.utils import tratar_erros
from backend.services.upload.salvar_imagem_service import SalvarImagemService


class UploadController:
    """Controller responsável pelo envio e pela exibição de imagens."""

    @staticmethod
    @tratar_erros
    @somente_organizador
    def enviar():
        # O Flask só lê o arquivo ao acessar `request.files`. Se passar
        # de 5 MB, o erro aparece aqui, e não no `tratar_erros` (que o
        # transformaria em um 500 genérico).
        try:
            arquivo = request.files.get("imagem")
        except RequestEntityTooLarge:
            return jsonify({"erro": "A imagem passa de 5 MB."}), 413
        nome = SalvarImagemService().execute(arquivo)
        return jsonify({"arquivo": nome}), 201

    @staticmethod
    def exibir(nome):
        # `send_from_directory` só entrega arquivos de dentro da pasta:
        # um nome como `../app.py` responde 404.
        return send_from_directory(Config.PASTA_UPLOADS, nome)


upload_bp = Blueprint("uploads", __name__)
upload_bp.add_url_rule("/api/uploads", view_func=UploadController.enviar, methods=["POST"])
upload_bp.add_url_rule("/uploads/<nome>", view_func=UploadController.exibir, methods=["GET"])
