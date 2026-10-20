"""
Caso de uso: obter os detalhes de uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Detalhes da Palestra").

Além dos dados da própria palestra, este caso de uso calcula três
"flags" relativas ao usuário que está vendo a tela (se está inscrito, se
favoritou e se tem lembrete ativo), usadas pelo Flutter para decidir o
estado inicial dos botões da tela de detalhes.

Método principal:
    execute(id_palestra, id_usuario=None): retorna um dict com os
    detalhes da palestra e as flags do usuário.
"""

from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.favorito import Favorito
from backend.repositories.notificacao_repository import NotificacaoRepository


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

        return dados
