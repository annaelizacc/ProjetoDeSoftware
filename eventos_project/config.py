import os
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env (se existir)
load_dotenv()


class Config:
    """
    Configurações centrais da aplicação.
    Todas as variáveis sensíveis vêm do .env (nunca hardcode senha/credenciais aqui).
    """

    SECRET_KEY = os.getenv("SECRET_KEY", "dev-key-nao-usar-em-producao")

    # --- Configuração do MySQL ---
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME", "eventos_db")

    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Ativa/desativa modo debug do Flask
    DEBUG = os.getenv("FLASK_DEBUG", "1") == "1"
