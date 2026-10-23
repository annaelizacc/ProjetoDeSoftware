"""
Caso de uso: criar um novo evento.

CAMADA: Services (regra de negócio do caso de uso "Criar Evento").

Responsável (F08): o evento fica ligado ao organizador que o criou. O
Controller passa o usuário logado (do token); um `id_organizador`
enviado no corpo é ignorado, para ninguém criar um evento em nome de
outra pessoa.

Método principal:
    execute(dados, usuario): cria e retorna o novo Evento.
"""

from datetime import date

from backend.models.evento import Evento
from backend.models.organizador import Organizador


class CriarEventoService:
    """Caso de uso responsável pelo cadastro de um novo evento."""

    def execute(self, dados, usuario):
        obrigatorios = ("nome", "data_inicio", "data_fim")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("nome, data_inicio e data_fim são obrigatórios.")

        # `tipo_usuario` e a tabela `organizador` precisam estar iguais
        # (README, seção 7). Se faltar o registro, o evento não teria dono.
        organizador = Organizador.buscar_por_usuario(usuario.id_usuario)
        if organizador is None:
            raise PermissionError("Seu cadastro de organizador está incompleto.")

        return Evento.criar(
            nome=dados["nome"],
            descricao=dados.get("descricao"),
            data_inicio=date.fromisoformat(str(dados["data_inicio"])),
            data_fim=date.fromisoformat(str(dados["data_fim"])),
            local=dados.get("local"),
            id_organizador=organizador.id_organizador,
        )
