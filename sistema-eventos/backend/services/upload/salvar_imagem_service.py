"""
Caso de uso: salvar uma imagem enviada pelo organizador (F14).

CAMADA: Services (regra de negócio do caso de uso "Enviar Imagem").

A mesma solução serve para a planta do evento (F03), a foto do
palestrante (F05) e o logo do patrocinador (F10). O envio acontece em
duas etapas:

1. o app envia o arquivo para `POST /api/uploads`, e este Service
   devolve o nome com que ele foi salvo;
2. o app manda esse nome junto com o cadastro (JSON normal), e o
   Service do cadastro confere o nome com `validar_nome_imagem`.

Regras de segurança:
- o tipo é descoberto pelos primeiros bytes do arquivo (a "assinatura"
  de cada formato), e não pela extensão, que qualquer pessoa troca. Um
  `.txt` renomeado para `.png` é recusado;
- o arquivo é salvo com um nome aleatório (`uuid4`), nunca com o nome
  enviado. Um nome como `../../app.py` poderia gravar fora da pasta
  (ataque chamado "path traversal");
- o tamanho máximo (5 MB) é conferido pelo próprio Flask
  (`MAX_CONTENT_LENGTH`, em `config.py`).

Método principal:
    execute(arquivo): salva o arquivo e retorna o nome gerado.
"""

import re
import uuid

from backend.config import Config

TIPOS_ACEITOS = "PNG, JPG ou WEBP"

# Nome que este Service gera: 32 letras/números do uuid + extensão.
FORMATO_NOME = re.compile(r"^[0-9a-f]{32}\.(png|jpg|webp)$")


def descobrir_tipo(inicio):
    """Devolve a extensão pela assinatura do arquivo, ou None se não for aceito."""
    if inicio.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if inicio.startswith(b"\xff\xd8\xff"):
        return "jpg"
    if inicio[:4] == b"RIFF" and inicio[8:12] == b"WEBP":
        return "webp"
    return None


def validar_nome_imagem(nome):
    """Confere o nome de imagem recebido em um cadastro.

    Vazio é aceito (o cadastro fica sem imagem). Caso contrário, o nome
    precisa ter o formato gerado por este Service e o arquivo precisa
    existir na pasta de uploads. Assim ninguém grava no banco um caminho
    qualquer ou o endereço de outro site. Retorna o nome ou None.
    """
    if not nome:
        return None
    if not isinstance(nome, str) or not FORMATO_NOME.match(nome):
        raise ValueError("Imagem inválida. Envie a imagem de novo.")
    if not (Config.PASTA_UPLOADS / nome).is_file():
        raise ValueError("Imagem não encontrada. Envie a imagem de novo.")
    return nome


class SalvarImagemService:
    """Caso de uso responsável por guardar uma imagem na pasta de uploads."""

    def execute(self, arquivo):
        if arquivo is None:
            raise ValueError("Envie a imagem no campo 'imagem'.")

        conteudo = arquivo.read()
        extensao = descobrir_tipo(conteudo[:12])
        if extensao is None:
            raise ValueError(f"Tipo de arquivo não aceito. Envie {TIPOS_ACEITOS}.")

        nome = f"{uuid.uuid4().hex}.{extensao}"
        Config.PASTA_UPLOADS.mkdir(exist_ok=True)
        (Config.PASTA_UPLOADS / nome).write_bytes(conteudo)
        return nome
