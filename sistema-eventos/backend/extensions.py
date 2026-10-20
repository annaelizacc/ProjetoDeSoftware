"""Extensões compartilhadas pela aplicação Flask.

Manter uma única instância de SQLAlchemy facilita o entendimento do projeto:
os Models importam `db`, e o app apenas conecta essa instância à aplicação.
"""

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()