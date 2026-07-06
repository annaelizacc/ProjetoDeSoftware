from database.db import db

# Tabela associativa pura (sem atributos próprios) para o relacionamento N:N
# entre Palestra e Palestrante: uma palestra pode ter vários palestrantes
# (ex: mesa redonda) e um palestrante pode ministrar várias palestras.
palestra_palestrante = db.Table(
    "palestra_palestrante",
    db.Column("palestra_id", db.Integer, db.ForeignKey("palestra.id"), primary_key=True),
    db.Column("palestrante_id", db.Integer, db.ForeignKey("palestrante.id"), primary_key=True),
)
