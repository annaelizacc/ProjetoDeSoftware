"""
Caso de uso: obter os detalhes de uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Detalhes da Palestra").

Além dos dados da própria palestra, este caso de uso calcula três
"flags" relativas ao usuário que está vendo a tela (se está inscrito, se
favoritou e se tem lembrete ativo), usadas pelo Flutter para decidir o
estado inicial dos botões da tela de detalhes.

Desde a F06/F07, também devolve:
- `media_estrelas` e `total_avaliacoes`: a nota da palestra;
- `minha_avaliacao`: a avaliação do usuário (ou None), para a tela saber
  se mostra "Avaliar" ou "Editar avaliação" e qual id usar ao editar ou
  excluir;
- `pode_avaliar`: se o usuário pode CRIAR uma avaliação (inscrito e
  palestra já começada). Usa a mesma regra do `CriarAvaliacaoService`.
  Editar e excluir não dependem dela: quem tem `minha_avaliacao` sempre
  pode, mesmo depois de cancelar a inscrição.

Método principal:
    execute(id_palestra, id_usuario=None): retorna um dict com os
    detalhes da palestra e as flags do usuário.
"""

from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.favorito import Favorito
from backend.repositories.avaliacao_repository import AvaliacaoRepository
from backend.repositories.notificacao_repository import NotificacaoRepository
from backend.repositories.sql_helpers import linha_para_dict
from backend.services.avaliacao.criar_avaliacao_service import motivo_para_nao_avaliar


class BuscarPalestraService:
    """Caso de uso responsável por montar os detalhes de uma palestra."""

    def execute(self, id_palestra, id_usuario=None):
        palestra = Palestra.buscar_por_id(id_palestra)
        if not palestra:
            raise ValueError("Palestra não encontrada.")

        dados = palestra.to_dict()
        dados["inscrito"] = False
        dados["favorita"] = False
        dados["lembrete_ativo"] = False
        dados.update(linha_para_dict(AvaliacaoRepository.media_por_palestra(id_palestra)))
        dados["minha_avaliacao"] = None
        dados["pode_avaliar"] = False

        if id_usuario:
            dados["inscrito"] = (
                Participacao.query.filter_by(
                    id_usuario=id_usuario, id_palestra=id_palestra
                ).first()
                is not None
            )
            dados["favorita"] = (
                Favorito.query.filter_by(
                    id_usuario=id_usuario, id_palestra=id_palestra
                ).first()
                is not None
            )
            dados["lembrete_ativo"] = (
                NotificacaoRepository.buscar_lembrete(id_usuario, id_palestra)
                is not None
            )
            minha = AvaliacaoRepository.buscar(id_usuario, id_palestra)
            dados["minha_avaliacao"] = linha_para_dict(minha) if minha else None
            dados["pode_avaliar"] = motivo_para_nao_avaliar(id_usuario, palestra) is None

        return dados
