"""
Repository: Área do organizador (F08, RF17).

CAMADA: Repositories (consultas com SQL explícito).

Reúne as consultas que o painel e a tela de inscrições do organizador
precisam e que não são um CRUD simples:

1. `listar_palestras_com_totais`: as palestras de um evento, cada uma com
   o número de inscritos, a quantidade de avaliações e a soma das notas.
   É a base do painel: o Service calcula as médias e soma essas linhas
   para montar os números do evento (palestras, inscrições, esgotadas,
   ocupação e média geral).
2. `listar_inscritos`: as pessoas inscritas em uma palestra, com nome e
   e-mail (JOIN entre `participacao` e `usuario`).
3. `listar_eventos`: os eventos de um organizador (ou todos, para o
   administrador), do mais próximo para o mais distante.

Por que subconsultas, e não um único JOIN com `GROUP BY`: se a mesma
consulta juntasse `participacao` e `avaliacao` à palestra, cada inscrição
seria repetida para cada avaliação (3 inscritos × 2 avaliações = 6
linhas), e o `COUNT` contaria errado. Com uma subconsulta para cada
número, cada um é contado separadamente.
"""

from sqlalchemy import text

from backend.extensions import db


class OrganizadorRepository:
    """Consultas SQL explícitas da área do organizador."""

    @staticmethod
    def listar_palestras_com_totais(id_evento):
        """Lista as palestras do evento com inscritos e avaliações.

        Ordena das mais procuradas para as menos procuradas (ranking do
        painel); em caso de empate, pelo horário.
        """
        sql = text(
            """
            SELECT p.id_palestra, p.titulo, p.horario_inicio, p.horario_fim,
                   l.nome_local AS sala,
                   p.vagas_total, p.vagas_disponiveis,
                   (SELECT COUNT(*) FROM participacao pa
                     WHERE pa.id_palestra = p.id_palestra) AS total_inscritos,
                   (SELECT COUNT(*) FROM avaliacao a
                     WHERE a.id_palestra = p.id_palestra) AS total_avaliacoes,
                   (SELECT COALESCE(SUM(a.nota_estrelas), 0) FROM avaliacao a
                     WHERE a.id_palestra = p.id_palestra) AS soma_notas
            FROM palestra p
            LEFT JOIN localizacao l ON l.id_localizacao = p.id_localizacao
            WHERE p.id_evento = :id_evento
            ORDER BY total_inscritos DESC, p.horario_inicio ASC
            """
        )
        resultado = db.session.execute(sql, {"id_evento": id_evento})
        return resultado.mappings().all()

    @staticmethod
    def listar_inscritos(id_palestra):
        """Lista quem está inscrito na palestra, em ordem alfabética."""
        sql = text(
            """
            SELECT u.id_usuario, u.nome, u.email
            FROM participacao pa
            JOIN usuario u ON u.id_usuario = pa.id_usuario
            WHERE pa.id_palestra = :id_palestra
            ORDER BY u.nome ASC
            """
        )
        resultado = db.session.execute(sql, {"id_palestra": id_palestra})
        return resultado.mappings().all()

    @staticmethod
    def listar_eventos(id_organizador=None):
        """Lista os eventos do organizador; com `id_organizador=None`, todos.

        O trecho do filtro é um texto fixo (o valor vai sempre como
        parâmetro), como no `PalestraRepository.listar`. `is not None`, e
        não só `if id_organizador`: um id 0 não pode virar "todos".
        """
        filtro_sql = "WHERE id_organizador = :id_organizador" if id_organizador is not None else ""
        sql = text(
            f"""
            SELECT id_evento, nome, data_inicio, data_fim, local, id_organizador
            FROM evento
            {filtro_sql}
            ORDER BY data_inicio ASC
            """
        )
        resultado = db.session.execute(sql, {"id_organizador": id_organizador})
        return resultado.mappings().all()
