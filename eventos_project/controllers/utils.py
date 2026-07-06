from functools import wraps
from flask import jsonify


def handle_errors(func):
    """
    Decorator para os Controllers: centraliza o tratamento de erros para não
    repetir try/except em cada rota.
      - ValueError (regra de negócio violada, vindo do Service) -> 400
      - Exception genérica (erro inesperado) -> 500
    """

    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ValueError as erro:
            return jsonify({"erro": str(erro)}), 400
        except Exception as erro:  # pragma: no cover - fallback de segurança
            return jsonify({"erro": "Erro interno no servidor.", "detalhes": str(erro)}), 500

    return wrapper
