"""
Repository: Favorito.

CAMADA: Repositories (consultas com SQL explícito).

Este Repository existe porque `listar_por_usuario` precisa combinar dados
de duas tabelas (`favorito` e `palestra`) em uma única consulta. Seguindo
a regra do projeto, isso é feito com SQL explícito via `sqlalchemy.text`,
e não com `Favorito.query`/`joinedload` do ORM.

Retorno: os métodos devolvem `RowMapping` (linhas "parecidas com dict"),
que os Services transformam no formato final de resposta da API.
"""

from sqlalchemy import text

from backend.extensions import db


class FavoritoRepository:
    """Consultas SQL explícitas sobre a tabela `favorito`."""

    @staticmethod
    def buscar(id_usuario, id_palestra):
        """Verifica se já existe um favorito para este par usuário/palestra.

        Usada pelo `AdicionarFavoritoService` para impedir duplicidade
        antes mesmo de depender da UniqueConstraint do banco, retornando
        um erro de negócio mais amigável ao Flutter.
        """
        sql = text(
            """
            SELECT id_favorito, id_usuario, id_palestra, data_favoritacao
            FROM favorito
            WHERE id_usuario = :id_usuario AND id_palestra = :id_palestra
            """
        )
        resultado = db.session.execute(
            sql, {"id_usuario": id_usuario, "id_palestra": id_palestra}
        )
        return resultado.mappings().first()

    @staticmethod
    def listar_por_usuario(id_usuario):
        """Lista os favoritos de um usuário já com os dados da palestra.

        O JOIN evita que o Flutter precise fazer uma segunda chamada para
        cada favorito só para saber o título/horário da palestra.
        """
        sql = text(
            """
            SELECT
                f.id_favorito,
                f.id_usuario,
                f.id_palestra,
                f.data_favoritacao,
                p.titulo,
                p.resumo,
                p.tema,
                p.sala,
                p.horario_inicio,
                p.horario_fim,
                p.id_evento,
                p.vagas_total,
                p.vagas_disponiveis
            FROM favorito f
            JOIN palestra p ON p.id_palestra = f.id_palestra
            WHERE f.id_usuario = :id_usuario
            ORDER BY f.data_favoritacao DESC
            """
        )
        resultado = db.session.execute(sql, {"id_usuario": id_usuario})
        return resultado.mappings().all()
