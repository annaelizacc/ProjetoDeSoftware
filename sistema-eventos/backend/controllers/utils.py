"""
Utilitário: decorator `tratar_erros`.

CAMADA: apoio aos Controllers.

Todos os Controllers usam este decorator para não precisar repetir o
mesmo bloco try/except em cada método. Ele traduz:

- `ValueError` levantado por um Service (uma regra de negócio violada,
  como "Palestra não encontrada" ou "Não há vagas disponíveis") em uma
  resposta HTTP 400, com a mensagem exata do erro;
- qualquer outra exceção não prevista em uma resposta HTTP 500 genérica,
  sem vazar detalhes internos (stack trace, erro de SQL, etc.) para quem
  chamou a API.
"""

from functools import wraps

from flask import jsonify


def tratar_erros(func):
    """Transforma erros de regra de negócio em respostas HTTP compreensíveis."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ValueError as erro:
            return jsonify({"erro": str(erro)}), 400
        except Exception:
            # Não expõe detalhes internos da conexão ou do banco ao usuário.
            return jsonify({"erro": "Erro interno no servidor."}), 500

    return wrapper
