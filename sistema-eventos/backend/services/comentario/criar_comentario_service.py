"""
Caso de uso: criar um comentário/avaliação sobre uma palestra.

CAMADA: Services (regra de negócio do caso de uso "Criar Comentário").

Método principal:
    execute(dados): cria e retorna o novo Comentario.
"""

from backend.models.comentario import Comentario
from backend.models.palestra import Palestra
from backend.models.usuario import Usuario


class CriarComentarioService:
    """Caso de uso responsável pela criação de um comentário."""

    def execute(self, dados):
        obrigatorios = ("texto", "id_usuario", "id_palestra")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("texto, id_usuario e id_palestra são obrigatórios.")
        if not Usuario.buscar_por_id(dados["id_usuario"]):
            raise ValueError("Usuário não encontrado.")
        if not Palestra.buscar_por_id(dados["id_palestra"]):
            raise ValueError("Palestra não encontrada.")

        return Comentario.criar(
            texto=dados["texto"],
            nota=dados.get("nota"),
            id_usuario=dados["id_usuario"],
            id_palestra=dados["id_palestra"],
        )
