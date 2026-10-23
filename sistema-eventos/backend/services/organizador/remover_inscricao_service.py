"""
Caso de uso: o organizador remove a inscrição de um participante (F08, RF17).

CAMADA: Services (regra de negócio do caso de uso "Remover inscrição").

Reaproveita o `CancelarInscricaoService`, o mesmo que o participante usa
ao cancelar a própria inscrição: ele apaga a inscrição e devolve a vaga
à palestra. Assim, a regra da vaga continua escrita num lugar só. A
diferença é quem escolhe a inscrição: aqui, o organizador (o
`id_usuario` vem da URL); lá, a própria pessoa (o `id_usuario` vem do
token).

Junto com a remoção, grava um aviso para o participante, que aparece na
aba Avisos dele. O tipo `atencao` já tem ícone próprio no app (P08).

Ordem dos passos:

1. confere se a inscrição existe. Se não existir, responde o erro antes
   de criar qualquer aviso (nem para um usuário que não existe);
2. coloca o aviso na sessão do banco (`db.session.add`) sem gravar;
3. o `commit` do `CancelarInscricaoService` grava a remoção e o aviso
   juntos, numa transação só. Uma transação é um "tudo ou nada": ou a
   inscrição sai e o aviso entra, ou nada muda. Se algo falhar no
   meio, o `rollback` desfaz tudo.

Método principal:
    execute(id_usuario, id_palestra): remove a inscrição e avisa a pessoa.
"""

from backend.extensions import db
from backend.models.notificacao import Notificacao
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.services.participacao.cancelar_inscricao_service import CancelarInscricaoService


class RemoverInscricaoService:
    """Caso de uso responsável por o organizador remover uma inscrição."""

    def execute(self, id_usuario, id_palestra):
        palestra = Palestra.buscar_por_id(id_palestra)
        if not palestra:
            raise ValueError("Palestra não encontrada.")
        inscrito = Participacao.query.filter_by(
            id_usuario=id_usuario, id_palestra=id_palestra
        ).first()
        if not inscrito:
            raise ValueError("Inscrição não encontrada.")

        db.session.add(
            Notificacao(
                mensagem=f"Sua inscrição em {palestra.titulo} foi removida pela organização.",
                tipo_notificacao="atencao",
                id_usuario=id_usuario,
                id_palestra=id_palestra,
            )
        )
        try:
            CancelarInscricaoService().execute(id_usuario, id_palestra)
        except Exception:
            db.session.rollback()
            raise
