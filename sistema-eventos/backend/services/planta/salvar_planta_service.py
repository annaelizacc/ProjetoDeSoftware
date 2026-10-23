"""
Caso de uso: salvar a planta baixa de um evento (F03, F14).

CAMADA: Services (regra de negócio do caso de uso "Salvar Planta").

Como cada evento tem no máximo uma planta, o mesmo caso de uso cria a
planta (na primeira vez) ou atualiza a que já existe. Assim o app não
precisa saber se a planta já foi cadastrada.

A imagem chega como o nome devolvido por `POST /api/uploads` e é
conferida por `validar_nome_imagem`. Ao atualizar, só mudam os campos
enviados: mandar só a `descricao` não apaga a imagem já salva. A
conferência do dono do evento é feita antes, no Controller.

Método principal:
    execute(id_evento, dados): retorna a planta salva.
"""

from backend.models.planta_baixa import PlantaBaixa
from backend.services.upload.salvar_imagem_service import validar_nome_imagem
from backend.services.validacoes_cadastro import TAMANHO_DESCRICAO, texto_opcional


class SalvarPlantaService:
    """Caso de uso responsável por criar ou atualizar a planta de um evento."""

    def execute(self, id_evento, dados):
        alteracoes = {}
        if "imagem_mapa" in dados:
            alteracoes["imagem_mapa"] = validar_nome_imagem(dados["imagem_mapa"])
        if "descricao" in dados:
            alteracoes["descricao"] = texto_opcional(
                dados["descricao"], "descrição", TAMANHO_DESCRICAO
            )

        planta = PlantaBaixa.query.filter_by(id_evento=id_evento).first()
        if planta is None:
            return PlantaBaixa.criar(id_evento=id_evento, **alteracoes)
        return PlantaBaixa.atualizar(planta.id_planta, **alteracoes)
