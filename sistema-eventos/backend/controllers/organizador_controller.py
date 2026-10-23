"""
Controller: Área do organizador (F08, RF17).

CAMADA: Controllers (recebe a requisição HTTP e chama o Service certo).

Rotas usadas pelas telas "Área do organizador" (painel) e "Inscrições"
do Flutter:

- `GET /api/organizador/eventos`: os eventos que a pessoa logada
  gerencia (todos, para o administrador);
- `GET /api/organizador/eventos/<id_evento>/painel`: números do evento e
  ranking das palestras;
- `GET /api/organizador/palestras/<id_palestra>/inscritos`: quem está
  inscrito na palestra;
- `DELETE /api/organizador/palestras/<id_palestra>/inscritos/<id_usuario>`:
  remove a inscrição de uma pessoa, devolve a vaga e avisa a pessoa;
- `POST /api/organizador/eventos/<id_evento>/comunicados`: envia um
  comunicado para todos os inscritos no evento ou, com `id_palestra` no
  corpo, só para os inscritos dessa palestra (F09, RF18).

Acesso (P01): todas as rotas são só para organizadores
(`@somente_organizador`: 401 sem login, 403 para participantes). Por
isso, aqui o `id_usuario` pode vir da URL: é o organizador quem escolhe
de quem remover. Na rota do participante (`/api/inscricoes`), ele vem
sempre do token.

Desde a ligação do evento ao organizador, as rotas com evento ou
palestra conferem também o dono (`verificar_dono_do_evento` e
`verificar_dono_da_palestra`): um organizador só vê os inscritos e os
números dos próprios eventos; o administrador vê todos.
"""

from flask import Blueprint, g, jsonify, request

from backend.controllers.autenticacao import (
    somente_organizador,
    verificar_dono_da_palestra,
    verificar_dono_do_evento,
)
from backend.controllers.utils import tratar_erros
from backend.services.organizador.enviar_comunicado_service import EnviarComunicadoService
from backend.services.organizador.listar_inscritos_service import ListarInscritosService
from backend.services.organizador.listar_meus_eventos_service import ListarMeusEventosService
from backend.services.organizador.obter_painel_service import ObterPainelService
from backend.services.organizador.remover_inscricao_service import RemoverInscricaoService


class OrganizadorController:
    """Controller responsável pelos endpoints da área do organizador."""

    @staticmethod
    @tratar_erros
    @somente_organizador
    def meus_eventos():
        return jsonify(ListarMeusEventosService().execute(g.usuario))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def painel(id_evento):
        verificar_dono_do_evento(id_evento)
        return jsonify(ObterPainelService().execute(id_evento))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def listar_inscritos(id_palestra):
        verificar_dono_da_palestra(id_palestra)
        return jsonify(ListarInscritosService().execute(id_palestra))

    @staticmethod
    @tratar_erros
    @somente_organizador
    def remover_inscricao(id_palestra, id_usuario):
        verificar_dono_da_palestra(id_palestra)
        RemoverInscricaoService().execute(id_usuario, id_palestra)
        return jsonify({"mensagem": "Inscrição removida e vaga devolvida."})

    @staticmethod
    @tratar_erros
    @somente_organizador
    def enviar_comunicado(id_evento):
        verificar_dono_do_evento(id_evento)
        dados = request.get_json() or {}
        total = EnviarComunicadoService().execute(
            id_evento, dados.get("mensagem"), dados.get("id_palestra")
        )
        return jsonify({"mensagem": "Comunicado enviado.", "total_destinatarios": total}), 201


organizador_bp = Blueprint("organizador", __name__, url_prefix="/api/organizador")
organizador_bp.add_url_rule(
    "/eventos", view_func=OrganizadorController.meus_eventos, methods=["GET"]
)
organizador_bp.add_url_rule(
    "/eventos/<int:id_evento>/painel",
    view_func=OrganizadorController.painel,
    methods=["GET"],
)
organizador_bp.add_url_rule(
    "/palestras/<int:id_palestra>/inscritos",
    view_func=OrganizadorController.listar_inscritos,
    methods=["GET"],
)
organizador_bp.add_url_rule(
    "/palestras/<int:id_palestra>/inscritos/<int:id_usuario>",
    view_func=OrganizadorController.remover_inscricao,
    methods=["DELETE"],
)
organizador_bp.add_url_rule(
    "/eventos/<int:id_evento>/comunicados",
    view_func=OrganizadorController.enviar_comunicado,
    methods=["POST"],
)
