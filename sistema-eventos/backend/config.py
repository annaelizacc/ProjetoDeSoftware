"""Configuração central do backend.

As credenciais ficam em variáveis de ambiente. Assim o código pode ser
entregue ao professor sem expor senha de banco no repositório.
"""

import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).with_name(".env"))


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "chave-local-do-projeto")
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://root:@localhost:3306/sistema_eventos",
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_AS_ASCII = False

    # Imagens enviadas pelo organizador (F14): planta, foto do palestrante
    # e logo do patrocinador. O banco guarda só o nome do arquivo.
    PASTA_UPLOADS = Path(__file__).with_name("uploads")
    # Limite de tamanho de qualquer requisição (5 MB). Acima disso, o
    # Flask recusa o envio antes de o arquivo ser lido.
    MAX_CONTENT_LENGTH = 5 * 1024 * 1024