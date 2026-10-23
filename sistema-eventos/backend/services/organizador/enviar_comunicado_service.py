"""
Caso de uso: o organizador envia um comunicado geral (F09, RF18).

CAMADA: Services (regra de negócio do caso de uso "Enviar comunicado").

O organizador escolhe para quem vai o comunicado:

- sem `id_palestra`: todos os participantes do evento, ou seja, quem
  está inscrito em pelo menos uma palestra dele;
- com `id_palestra`: só quem está inscrito nessa palestra.

Não existe uma tabela própria de comunicados (D01): cada pessoa recebe
uma cópia na tabela `notificacao`, com `tipo_notificacao = "comunicado"`,
o `id_evento` (para a aba Avisos mostrar o nome do evento) e o
`id_palestra` quando o comunicado é de uma palestra.

Ordem dos passos:

1. confere a mensagem: obrigatória e com até 500 caracteres;
2. com palestra, confere se ela existe e se é deste evento. Sem essa
   conferência, o dono de um evento poderia mandar avisos para os
   inscritos de uma palestra de outro evento, porque o Controller só
   confere o dono do evento da URL;
3. busca os destinatários. Sem nenhum, responde o erro em vez de
   "enviar" para ninguém;
4. coloca uma notificação por pessoa na sessão do banco e grava todas
   num `commit` só (uma transação: ou todas as cópias entram, ou
   nenhuma). Se algo falhar no meio, o `rollback` desfaz tudo.

O dono do evento já foi conferido no Controller
(`verificar_dono_do_evento`), como nas outras rotas do organizador.

Método principal:
    execute(id_evento, mensagem, id_palestra=None): envia o comunicado e
    devolve quantas pessoas o receberam.
"""

from backend.extensions import db
from backend.models.notificacao import Notificacao
from backend.models.palestra import Palestra
from backend.repositories.organizador_repository import OrganizadorRepository

TAMANHO_MAXIMO = 500


class EnviarComunicadoService:
    """Caso de uso responsável por enviar um comunicado aos participantes."""

    def execute(self, id_evento, mensagem, id_palestra=None):
        if not isinstance(mensagem, str) or not mensagem.strip():
            raise ValueError("Escreva a mensagem do comunicado.")
        mensagem = mensagem.strip()
        if len(mensagem) > TAMANHO_MAXIMO:
            raise ValueError(
                f"O comunicado pode ter no máximo {TAMANHO_MAXIMO} caracteres."
            )

        if id_palestra is None:
            participantes = OrganizadorRepository.listar_participantes_do_evento(id_evento)
            if not participantes:
                raise ValueError("Nenhum participante inscrito neste evento ainda.")
        else:
            # `bool` é um tipo de `int` no Python (`True == 1`), por isso é
            # recusado à parte.
            if not isinstance(id_palestra, int) or isinstance(id_palestra, bool):
                raise ValueError("Palestra inválida.")
            palestra = Palestra.buscar_por_id(id_palestra)
            if not palestra or palestra.id_evento != id_evento:
                raise ValueError("Palestra não encontrada neste evento.")
            inscritos = OrganizadorRepository.listar_inscritos(id_palestra)
            participantes = [linha["id_usuario"] for linha in inscritos]
            if not participantes:
                raise ValueError("Nenhuma pessoa inscrita nesta palestra ainda.")

        try:
            for id_usuario in participantes:
                db.session.add(
                    Notificacao(
                        mensagem=mensagem,
                        tipo_notificacao="comunicado",
                        id_usuario=id_usuario,
                        id_evento=id_evento,
                        id_palestra=id_palestra,
                    )
                )
            db.session.commit()
        except Exception:
            db.session.rollback()
            raise
        return len(participantes)
