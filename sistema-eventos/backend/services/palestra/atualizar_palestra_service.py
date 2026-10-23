"""
Caso de uso: atualizar uma palestra existente.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Palestra").

Quando `id_localizacao` ou `id_palestrante` são enviados, passam pelas
mesmas conferências da criação (existem? o local é do mesmo evento?).

Só os campos de `CAMPOS_EDITAVEIS` são aceitos (lista do que é
permitido, desde a F08, como no evento e no usuário).

Vagas (F14): o organizador pode mudar o total de vagas (`vagas_total`),
mas `vagas_disponiveis` nunca vem da requisição: é recalculado aqui.
Quem já se inscreveu continua inscrito, então:
- inscritos = total antigo - vagas disponíveis;
- o total novo não pode ser menor que o número de inscritos;
- vagas disponíveis = total novo - inscritos.

Método principal:
    execute(id_palestra, dados): retorna a Palestra atualizada.
"""

from datetime import datetime

from backend.models.palestra import Palestra
from backend.services.palestra.criar_palestra_service import (
    validar_local_e_palestrante,
    validar_vagas,
)

CAMPOS_EDITAVEIS = (
    "titulo",
    "resumo",
    "tema",
    "horario_inicio",
    "horario_fim",
    "id_evento",
    "id_localizacao",
    "id_palestrante",
)


def _converter_data(valor):
    """Converte o texto ISO vindo do Flutter para `datetime` (ou None)."""
    if not valor:
        return None
    if isinstance(valor, datetime):
        return valor
    return datetime.fromisoformat(str(valor).replace("Z", "+00:00")).replace(tzinfo=None)


def recalcular_vagas(palestra, novo_total):
    """Devolve as vagas livres para um novo total, sem tirar ninguém."""
    inscritos = palestra.vagas_total - palestra.vagas_disponiveis
    if novo_total < inscritos:
        raise ValueError(
            f"A palestra já tem {inscritos} inscrições. O total de vagas não pode ser menor."
        )
    return novo_total - inscritos


class AtualizarPalestraService:
    """Caso de uso responsável pela atualização de uma palestra existente."""

    def execute(self, id_palestra, dados):
        dados_recebidos = dados
        dados = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "horario_inicio" in dados:
            dados["horario_inicio"] = _converter_data(dados["horario_inicio"])
        if "horario_fim" in dados:
            dados["horario_fim"] = _converter_data(dados["horario_fim"])

        atual = Palestra.buscar_por_id(id_palestra)
        if not atual:
            raise ValueError("Palestra não encontrada.")
        validar_local_e_palestrante(dados, dados.get("id_evento") or atual.id_evento)

        if "vagas_total" in dados_recebidos:
            novo_total = validar_vagas(dados_recebidos["vagas_total"])
            dados["vagas_total"] = novo_total
            dados["vagas_disponiveis"] = recalcular_vagas(atual, novo_total)

        return Palestra.atualizar(id_palestra, **dados)
