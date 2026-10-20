"""
Repository: Avaliacao.

CAMADA: Repositories (consultas com SQL explícito).

Consultas sobre a tabela `avaliacao` (antiga `comentario`, F19/D01):

1. `listar_por_palestra`: lista as avaliações de uma palestra já com o
   nome do autor (JOIN com `usuario`), evitando que o Flutter precise
   buscar cada usuário separadamente para montar a lista na tela de
   detalhes da palestra.
2. `buscar`: procura a avaliação de um usuário sobre uma palestra, usada
   para impedir que a mesma pessoa avalie a mesma palestra duas vezes.
"""

from sqlalchemy import text

from backend.extensions import db


class AvaliacaoRepository:
    """Consultas SQL explícitas sobre a tabela `avaliacao`."""

    @staticmethod
    def listar_por_palestra(id_palestra):
        """Lista as avaliações de uma palestra, da mais recente para a mais antiga."""
        sql = text(
            """
            SELECT a.id_avaliacao, a.nota_estrelas, a.comentario, a.data,
                   a.id_usuario, a.id_palestra, u.nome AS nome_usuario
            FROM avaliacao a
            JOIN usuario u ON u.id_usuario = a.id_usuario
            WHERE a.id_palestra = :id_palestra
            ORDER BY a.data DESC
            """
        )
        resultado = db.session.execute(sql, {"id_palestra": id_palestra})
        return resultado.mappings().all()

    @staticmethod
    def buscar(id_usuario, id_palestra):
        """Retorna a avaliação do usuário sobre a palestra, ou None se não existir."""
        sql = text(
            """
            SELECT id_avaliacao, nota_estrelas, comentario, data,
                   id_usuario, id_palestra
            FROM avaliacao
            WHERE id_usuario = :id_usuario AND id_palestra = :id_palestra
            """
        )
        resultado = db.session.execute(
            sql, {"id_usuario": id_usuario, "id_palestra": id_palestra}
        )
        return resultado.mappings().first()
