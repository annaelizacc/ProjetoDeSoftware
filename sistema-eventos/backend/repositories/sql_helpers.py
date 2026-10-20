"""
Utilitário: conversão de linhas de SQL puro para dicionários JSON-seguros.

CAMADA: Repositories (apoio às consultas com SQL explícito).

Quando uma consulta é feita com `sqlalchemy.text` (SQL puro), o resultado
vem como `RowMapping` — parecido com um dicionário, mas com tipos nativos
do Python/driver do banco (`datetime.datetime`, `decimal.Decimal`, etc.),
que o `jsonify` do Flask não sabe serializar diretamente.

Esta função central evita que cada Service precise reimplementar a mesma
conversão (`isoformat()`, `float()`) sempre que usa um Repository com SQL
explícito.
"""

from datetime import date, datetime
from decimal import Decimal


def linha_para_dict(linha):
    """Converte uma RowMapping (ou dict) em um dict pronto para `jsonify`."""
    dados = dict(linha)
    for chave, valor in dados.items():
        if isinstance(valor, (datetime, date)):
            dados[chave] = valor.isoformat()
        elif isinstance(valor, Decimal):
            dados[chave] = float(valor)
    return dados
