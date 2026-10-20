"""
Caso de uso: criar uma nova palestra.

CAMADA: Services (regra de negócio do caso de uso "Criar Palestra").

Valida os campos obrigatórios, confere se o evento informado existe e
converte as datas recebidas do Flutter (texto ISO) para `datetime` antes
de delegar a criação para a Model (`Palestra.criar`, que já cuida de
inicializar `vagas_disponiveis`).

Método principal:
    execute(dados): cria e retorna a nova Palestra.
"""

from datetime import datetime

from backend.models.evento import Evento
from backend.models.palestra import Palestra


def _converter_data(valor):
    """Converte o texto ISO vindo do Flutter para `datetime` (ou None)."""
    if not valor:
        return None
    if isinstance(valor, datetime):
        return valor
    return datetime.fromisoformat(str(valor).replace("Z", "+00:00")).replace(tzinfo=None)


class CriarPalestraService:
    """Caso de uso responsável pelo cadastro de uma nova palestra."""

    def execute(self, dados):
        obrigatorios = ("titulo", "id_evento")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("titulo e id_evento são obrigatórios.")
        if not Evento.buscar_por_id(dados["id_evento"]):
            raise ValueError("Evento não encontrado.")

        return Palestra.criar(
            titulo=dados["titulo"],
            resumo=dados.get("resumo"),
            tema=dados.get("tema"),
            sala=dados.get("sala"),
            horario_inicio=_converter_data(dados.get("horario_inicio")),
            horario_fim=_converter_data(dados.get("horario_fim")),
            id_evento=dados["id_evento"],
            vagas_total=dados.get("vagas_total", 50),
        )
