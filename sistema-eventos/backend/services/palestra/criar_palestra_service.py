"""
Caso de uso: criar uma nova palestra.

CAMADA: Services (regra de negócio do caso de uso "Criar Palestra").

Valida os campos obrigatórios, confere se o evento (e, quando informados,
o local e o palestrante) existem e converte as datas recebidas do Flutter (texto ISO) para `datetime` antes
de delegar a criação para a Model (`Palestra.criar`, que já cuida de
inicializar `vagas_disponiveis`).

Método principal:
    execute(dados): cria e retorna a nova Palestra.
"""

from datetime import datetime

from backend.models.evento import Evento
from backend.models.localizacao import Localizacao
from backend.models.palestra import Palestra
from backend.models.palestrante import Palestrante


def _converter_data(valor):
    """Converte o texto ISO vindo do Flutter para `datetime` (ou None)."""
    if not valor:
        return None
    if isinstance(valor, datetime):
        return valor
    return datetime.fromisoformat(str(valor).replace("Z", "+00:00")).replace(tzinfo=None)


def validar_local_e_palestrante(dados, id_evento):
    """Confere o local e o palestrante, quando informados.

    O local precisa existir e ser do mesmo evento da palestra (uma sala de
    outro evento não aparece na planta nem nas rotas deste). Desde a F14,
    o palestrante também precisa ser do mesmo evento: o organizador só
    indica palestrantes que ele mesmo cadastrou no evento. Também usada
    pelo `AtualizarPalestraService`, para a regra ficar em um lugar só.
    """
    if dados.get("id_localizacao"):
        local = Localizacao.buscar_por_id(dados["id_localizacao"])
        if not local:
            raise ValueError("Local não encontrado.")
        if local.id_evento != int(id_evento):
            raise ValueError("O local não pertence ao evento da palestra.")
    if dados.get("id_palestrante"):
        palestrante = Palestrante.buscar_por_id(dados["id_palestrante"])
        if not palestrante:
            raise ValueError("Palestrante não encontrado.")
        if palestrante.id_evento != int(id_evento):
            raise ValueError("O palestrante não pertence ao evento da palestra.")


def validar_vagas(valor):
    """Confere o total de vagas: um número inteiro de 1 para cima."""
    try:
        total = int(valor)
    except (TypeError, ValueError):
        raise ValueError("O total de vagas precisa ser um número.") from None
    if total < 1:
        raise ValueError("A palestra precisa ter pelo menos 1 vaga.")
    return total


class CriarPalestraService:
    """Caso de uso responsável pelo cadastro de uma nova palestra."""

    def execute(self, dados):
        obrigatorios = ("titulo", "id_evento")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("titulo e id_evento são obrigatórios.")
        if not Evento.buscar_por_id(dados["id_evento"]):
            raise ValueError("Evento não encontrado.")
        validar_local_e_palestrante(dados, dados["id_evento"])

        return Palestra.criar(
            titulo=dados["titulo"],
            resumo=dados.get("resumo"),
            tema=dados.get("tema"),
            horario_inicio=_converter_data(dados.get("horario_inicio")),
            horario_fim=_converter_data(dados.get("horario_fim")),
            id_evento=dados["id_evento"],
            id_localizacao=dados.get("id_localizacao"),
            id_palestrante=dados.get("id_palestrante"),
            vagas_total=validar_vagas(dados.get("vagas_total", 50)),
        )
