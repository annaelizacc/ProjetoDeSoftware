"""
Caso de uso: avaliar uma palestra (estrelas + comentário opcional).

CAMADA: Services (regra de negócio do caso de uso "Avaliar Palestra").

Regras:
- `nota_estrelas` é obrigatória e precisa ser um número inteiro de 1 a 5;
- o comentário é opcional, com no máximo 500 caracteres;
- só quem está inscrito na palestra pode avaliar (F06/F07);
- a avaliação só abre quando a palestra começa (`horario_inicio`),
  comparado com a hora local do servidor: os horários das palestras são
  gravados na hora local, sem fuso, então as duas precisam estar no
  mesmo fuso para a comparação valer;
- cada usuário avalia cada palestra uma vez só (para mudar a nota, usa-se
  a atualização). O banco também garante isso com a chave única
  `uk_avaliacao_usuario_palestra`, mas conferir aqui antes permite
  devolver uma mensagem clara em vez de um erro do banco. Se dois
  pedidos chegarem ao mesmo tempo (ex.: toque duplo no botão), os dois
  passam pela conferência, e o banco recusa o segundo: esse erro
  (`IntegrityError`) também vira a mesma mensagem clara.

Método principal:
    execute(dados): cria e retorna a nova Avaliacao.
"""

from datetime import datetime

from sqlalchemy.exc import IntegrityError

from backend.extensions import db
from backend.models.avaliacao import Avaliacao
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.usuario import Usuario
from backend.repositories.avaliacao_repository import AvaliacaoRepository


TAMANHO_MAXIMO_COMENTARIO = 500


def validar_comentario(valor):
    """Confere o comentário (opcional) e o devolve sem espaços nas pontas.

    Também usada pelo `AtualizarAvaliacaoService`. Comentário vazio vira
    `None`, para a avaliação ficar só com as estrelas. O limite de
    tamanho existe aqui, e não só no campo da tela, porque a API pode ser
    chamada sem passar pelo app.
    """
    if valor is None:
        return None
    if not isinstance(valor, str):
        raise ValueError("comentario deve ser um texto.")
    valor = valor.strip()
    if len(valor) > TAMANHO_MAXIMO_COMENTARIO:
        raise ValueError(
            f"O comentário pode ter no máximo {TAMANHO_MAXIMO_COMENTARIO} caracteres."
        )
    return valor or None


def motivo_para_nao_avaliar(id_usuario, palestra):
    """Diz por que o usuário ainda não pode avaliar a palestra, ou None se pode.

    Também usada pelo `BuscarPalestraService`, que devolve `pode_avaliar`
    para o Flutter decidir se mostra o botão "Avaliar". Assim a regra
    fica em um lugar só, e o que o app mostra é sempre o que o backend
    aceita.
    """
    inscrito = Participacao.query.filter_by(
        id_usuario=id_usuario, id_palestra=palestra.id_palestra
    ).first()
    if not inscrito:
        return "Só quem está inscrito na palestra pode avaliá-la."
    if not palestra.horario_inicio or palestra.horario_inicio > datetime.now():
        return "A avaliação abre quando a palestra começar."
    return None


def validar_estrelas(valor):
    """Confere se a nota é um inteiro de 1 a 5 e a devolve como `int`.

    Também usada pelo `AtualizarAvaliacaoService`, para a regra ficar em
    um lugar só. Aceita `4.0` (o Flutter pode enviar números como
    decimais), mas recusa `4.5`. `bool` é recusado de propósito: em
    Python, `True` também é um `int` (vale 1).
    """
    if isinstance(valor, float) and valor.is_integer():
        valor = int(valor)
    if isinstance(valor, bool) or not isinstance(valor, int) or not 1 <= valor <= 5:
        raise ValueError("nota_estrelas deve ser um número inteiro de 1 a 5.")
    return valor


class CriarAvaliacaoService:
    """Caso de uso responsável pela criação de uma avaliação."""

    def execute(self, dados):
        obrigatorios = ("nota_estrelas", "id_usuario", "id_palestra")
        if not all(dados.get(campo) is not None for campo in obrigatorios):
            raise ValueError("nota_estrelas, id_usuario e id_palestra são obrigatórios.")
        nota = validar_estrelas(dados["nota_estrelas"])
        if not Usuario.buscar_por_id(dados["id_usuario"]):
            raise ValueError("Usuário não encontrado.")
        palestra = Palestra.buscar_por_id(dados["id_palestra"])
        if not palestra:
            raise ValueError("Palestra não encontrada.")
        motivo = motivo_para_nao_avaliar(dados["id_usuario"], palestra)
        if motivo:
            raise ValueError(motivo)
        if AvaliacaoRepository.buscar(dados["id_usuario"], dados["id_palestra"]):
            raise ValueError("Você já avaliou esta palestra.")

        try:
            return Avaliacao.criar(
                nota_estrelas=nota,
                comentario=validar_comentario(dados.get("comentario")),
                id_usuario=dados["id_usuario"],
                id_palestra=dados["id_palestra"],
            )
        except IntegrityError:
            db.session.rollback()
            raise ValueError("Você já avaliou esta palestra.")
