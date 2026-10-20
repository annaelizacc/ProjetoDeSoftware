"""
Caso de uso: atualizar uma palestra existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Palestra").

Método principal:
    execute(id_palestra, dados): retorna a Palestra atualizada.
"""

from datetime import datetime

from backend.models.palestra import Palestra


def _converter_data(valor):
    """Converte o texto ISO vindo do Flutter para `datetime` (ou None)."""
    if not valor:
        return None
    if isinstance(valor, datetime):
        return valor
    return datetime.fromisoformat(str(valor).replace("Z", "+00:00")).replace(tzinfo=None)


class AtualizarPalestraService:
    """Caso de uso responsável pela atualização de uma palestra existente."""

    def execute(self, id_palestra, dados):
        dados = dict(dados)
        if "horario_inicio" in dados:
            dados["horario_inicio"] = _converter_data(dados["horario_inicio"])
        if "horario_fim" in dados:
            dados["horario_fim"] = _converter_data(dados["horario_fim"])

        palestra = Palestra.atualizar(id_palestra, **dados)
        if not palestra:
            raise ValueError("Palestra não encontrada.")
        return palestra
