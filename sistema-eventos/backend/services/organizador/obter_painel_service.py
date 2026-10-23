"""
Caso de uso: montar o painel do organizador de um evento (F08, RF17).

CAMADA: Services (regra de negócio do caso de uso "Ver painel").

O Repository devolve as palestras do evento, cada uma com os seus totais.
Este Service soma essas linhas para montar o resumo do evento:

- `total_palestras` e `total_inscricoes`;
- `palestras_esgotadas`: palestras sem nenhuma vaga disponível;
- `ocupacao_percentual`: vagas preenchidas ÷ vagas totais, de 0 a 100;
- `media_avaliacoes`: média de TODAS as avaliações do evento (ou `None`
  se ainda não houver nenhuma), com uma casa decimal.

Por que a média geral não é a média das médias: uma palestra com uma
avaliação de 5 estrelas e outra com dez avaliações de 3 estrelas dariam
4,0 na média das médias, mas a média real das onze avaliações é 3,2.
Por isso o Repository devolve a SOMA das notas e a quantidade de
avaliações de cada palestra: a média de uma palestra é a soma dela ÷ a
quantidade dela, e a média geral é a soma de todas ÷ a quantidade de
todas.

Cada palestra da lista ganha `media_avaliacoes` (ou `None`, sem
avaliações); a `soma_notas` só serve para a conta e sai da resposta.

Método principal:
    execute(id_evento): retorna o evento, o resumo e as palestras (o
    ranking, das mais procuradas para as menos procuradas).
"""

from backend.models.evento import Evento
from backend.repositories.organizador_repository import OrganizadorRepository
from backend.repositories.sql_helpers import linha_para_dict


class ObterPainelService:
    """Caso de uso responsável por montar o painel do organizador."""

    def execute(self, id_evento):
        evento = Evento.buscar_por_id(id_evento)
        if not evento:
            raise ValueError("Evento não encontrado.")

        palestras = [
            linha_para_dict(linha)
            for linha in OrganizadorRepository.listar_palestras_com_totais(id_evento)
        ]

        total_inscricoes = sum(p["total_inscritos"] for p in palestras)
        total_vagas = sum(p["vagas_total"] for p in palestras)
        total_avaliacoes = sum(p["total_avaliacoes"] for p in palestras)
        soma_notas = sum(p["soma_notas"] for p in palestras)

        for palestra in palestras:
            soma = palestra.pop("soma_notas")
            quantidade = palestra["total_avaliacoes"]
            palestra["media_avaliacoes"] = round(soma / quantidade, 1) if quantidade else None

        resumo = {
            "total_palestras": len(palestras),
            "total_inscricoes": total_inscricoes,
            "palestras_esgotadas": sum(1 for p in palestras if p["vagas_disponiveis"] == 0),
            "ocupacao_percentual": (
                round(total_inscricoes * 100 / total_vagas) if total_vagas else 0
            ),
            "total_avaliacoes": total_avaliacoes,
            "media_avaliacoes": (
                round(soma_notas / total_avaliacoes, 1) if total_avaliacoes else None
            ),
        }

        return {"evento": evento.to_dict(), "resumo": resumo, "palestras": palestras}
