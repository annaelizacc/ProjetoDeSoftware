"""
Repository: Palestra e Agenda.

CAMADA: Repositories (consultas com SQL explícito).

Reúne duas consultas que não são um CRUD simples:

1. `PalestraRepository.listar`: lista palestras com filtros opcionais
   (evento e busca por tema/título) e ordenação por horário.
2. `AgendaRepository.listar_por_usuario`: a "agenda pessoal" do usuário,
   que exige um JOIN entre `participacao` e `palestra` (e `evento`, para
   trazer o nome do evento junto).

Ambas usam `sqlalchemy.text` com parâmetros nomeados, evitando SQL
Injection e seguindo a regra de SQL explícito nos Repositories.

Desde a F19, o local da palestra fica em `localizacao`. As duas consultas
fazem um LEFT JOIN com essa tabela e devolvem o nome do local com o
apelido `sala`, como antes, para o Flutter não precisar mudar. O LEFT
JOIN (e não JOIN) mantém na lista as palestras que ainda não têm local.
"""

from sqlalchemy import text

from backend.extensions import db


class PalestraRepository:
    """Consultas de listagem/filtro sobre a tabela `palestra`."""

    @staticmethod
    def listar(id_evento=None, tema=None):
        """Lista palestras, filtrando por evento e/ou por termo de busca.

        O filtro de tema é aplicado tanto sobre `tema` quanto sobre
        `titulo`, pois é comum o usuário buscar por uma palavra que está
        no título e não necessariamente cadastrada como tema.
        """
        condicoes = []
        parametros = {}

        if id_evento:
            condicoes.append("p.id_evento = :id_evento")
            parametros["id_evento"] = id_evento

        if tema:
            condicoes.append("(p.tema LIKE :termo OR p.titulo LIKE :termo)")
            parametros["termo"] = f"%{tema.strip()}%"

        filtro_sql = f"WHERE {' AND '.join(condicoes)}" if condicoes else ""

        sql = text(
            f"""
            SELECT p.id_palestra, p.titulo, p.resumo, p.tema,
                   l.nome_local AS sala, p.id_localizacao, p.id_palestrante,
                   p.horario_inicio, p.horario_fim, p.id_evento,
                   p.vagas_total, p.vagas_disponiveis
            FROM palestra p
            LEFT JOIN localizacao l ON l.id_localizacao = p.id_localizacao
            {filtro_sql}
            ORDER BY p.horario_inicio ASC
            """
        )
        resultado = db.session.execute(sql, parametros)
        return resultado.mappings().all()


class AgendaRepository:
    """Consulta específica da agenda: participações + palestras + eventos."""

    @staticmethod
    def listar_por_usuario(id_usuario):
        """Lista as palestras em que o usuário está inscrito, com o nome do evento.

        O JOIN com `evento` existe porque a tela de Agenda do Flutter
        mostra em qual evento cada palestra agendada acontece.
        """
        sql = text(
            """
            SELECT p.id_palestra, p.titulo, p.resumo, p.tema,
                   l.nome_local AS sala, p.id_localizacao, p.id_palestrante,
                   p.horario_inicio, p.horario_fim, p.id_evento,
                   p.vagas_total, p.vagas_disponiveis,
                   e.nome AS nome_evento
            FROM participacao pa
            JOIN palestra p ON p.id_palestra = pa.id_palestra
            JOIN evento e ON e.id_evento = p.id_evento
            LEFT JOIN localizacao l ON l.id_localizacao = p.id_localizacao
            WHERE pa.id_usuario = :id_usuario
            ORDER BY p.horario_inicio ASC
            """
        )
        resultado = db.session.execute(sql, {"id_usuario": id_usuario})
        return resultado.mappings().all()
