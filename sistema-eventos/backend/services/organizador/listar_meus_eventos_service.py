"""
Caso de uso: listar os eventos que o organizador logado gerencia (F08).

CAMADA: Services (regra de negócio do caso de uso "Meus eventos").

Usado pela tela "Área do organizador" para saber qual painel abrir (e,
com mais de um evento, montar o seletor de evento):

- o administrador gerencia todos os eventos;
- o organizador, só os ligados a ele (`evento.id_organizador`);
- um usuário sem registro em `organizador` não gerencia nenhum.

Método principal:
    execute(usuario): retorna a lista de eventos (dicts).
"""

from backend.models.organizador import Organizador
from backend.repositories.organizador_repository import OrganizadorRepository
from backend.repositories.sql_helpers import linha_para_dict


class ListarMeusEventosService:
    """Caso de uso responsável por listar os eventos do organizador logado."""

    def execute(self, usuario):
        organizador = Organizador.buscar_por_usuario(usuario.id_usuario)
        if organizador is None:
            return []

        id_filtro = None if organizador.eh_administrador else organizador.id_organizador
        linhas = OrganizadorRepository.listar_eventos(id_filtro)
        return [linha_para_dict(linha) for linha in linhas]
