"""
Repository: Comentario.

CAMADA: Repositories (consultas com SQL explícito).

Consulta usada para listar os comentários de uma palestra já com o nome
do autor (JOIN com `usuario`), evitando que o Flutter precise buscar cada
usuário separadamente para montar a lista de comentários na tela de
detalhes da palestra.
"""

from sqlalchemy import text

from backend.extensions import db


class ComentarioRepository:
    """Consultas SQL explícitas sobre a tabela `comentario`."""

    @staticmethod
    def listar_por_palestra(id_palestra):
        """Lista os comentários de uma palestra, do mais recente para o mais antigo."""
        sql = text(
            """
            SELECT c.id_comentario, c.texto, c.nota, c.data,
                   c.id_usuario, c.id_palestra, u.nome AS nome_usuario
            FROM comentario c
            JOIN usuario u ON u.id_usuario = c.id_usuario
            WHERE c.id_palestra = :id_palestra
            ORDER BY c.data DESC
            """
        )
        resultado = db.session.execute(sql, {"id_palestra": id_palestra})
        return resultado.mappings().all()
