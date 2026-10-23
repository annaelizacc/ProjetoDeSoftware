"""
Repository: Notificacao.

CAMADA: Repositories (consultas com SQL explícito).

Consultas sobre a tabela `notificacao`, que também guarda os lembretes de
palestra (`tipo_notificacao = 'lembrete'`). Implementadas com
`sqlalchemy.text` para seguir a regra de SQL explícito na camada de
Repository.
"""

from sqlalchemy import text

from backend.extensions import db


class NotificacaoRepository:
    """Consultas SQL explícitas sobre a tabela `notificacao`."""

    @staticmethod
    def listar_por_usuario(id_usuario):
        """Lista as notificações/lembretes de um usuário, mais recentes primeiro.

        Traz também o nome do evento e o título da palestra (F09), que a aba
        Avisos mostra nos comunicados. `LEFT JOIN`, e não `JOIN`: um aviso
        sem evento ou sem palestra continua na lista, com esses campos
        vazios (`NULL`). Com `JOIN`, ele sumiria.
        """
        sql = text(
            """
            SELECT n.id_notificacao, n.mensagem, n.data_envio,
                   n.tipo_notificacao, n.id_usuario, n.id_palestra,
                   n.id_evento, e.nome AS nome_evento,
                   p.titulo AS titulo_palestra
            FROM notificacao n
            LEFT JOIN evento e ON e.id_evento = n.id_evento
            LEFT JOIN palestra p ON p.id_palestra = n.id_palestra
            WHERE n.id_usuario = :id_usuario
            ORDER BY n.data_envio DESC
            """
        )
        resultado = db.session.execute(sql, {"id_usuario": id_usuario})
        return resultado.mappings().all()

    @staticmethod
    def buscar_lembrete(id_usuario, id_palestra):
        """Verifica se já existe um lembrete ativo para este usuário/palestra.

        Usada para impedir que o mesmo lembrete seja ativado duas vezes e
        para informar ao Flutter se o botão de lembrete deve aparecer
        "ativo" ou não na tela de detalhes da palestra.
        """
        sql = text(
            """
            SELECT id_notificacao, mensagem, data_envio, tipo_notificacao,
                   id_usuario, id_palestra
            FROM notificacao
            WHERE id_usuario = :id_usuario
              AND id_palestra = :id_palestra
              AND tipo_notificacao = 'lembrete'
            """
        )
        resultado = db.session.execute(
            sql, {"id_usuario": id_usuario, "id_palestra": id_palestra}
        )
        return resultado.mappings().first()
