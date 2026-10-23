"""
Utilitário: decorators de autenticação e de perfil.

CAMADA: apoio aos Controllers (como o `tratar_erros`, de `utils.py`).

Um decorator é uma função que "envolve" outra: ele roda antes da rota e
decide se ela pode rodar. Assim a verificação fica escrita uma vez só, e
cada rota protegida ganha apenas uma linha (`@login_obrigatorio`).

- `@login_obrigatorio`: confere o token do cabeçalho
  `Authorization: Bearer <token>`. Sem token, ou com token inválido ou
  vencido, responde 401 (não sei quem você é). Com token válido, guarda o
  usuário em `g.usuario`, que a rota usa no lugar de um `id_usuario`
  vindo do corpo ou da URL.
- `@somente_organizador`: faz o mesmo e, além disso, responde 403 (sei
  quem você é, mas você não pode) se o usuário não for organizador. O
  perfil vem do banco, nunca da requisição.
- `verificar_acesso_ao_usuario`: para as rotas que têm `<id_usuario>` na
  URL, confere se o id é o da própria pessoa logada.
- `verificar_dono_do_evento` e `verificar_dono_da_palestra` (F08): o
  organizador só mexe no evento ligado a ele (e no que pertence ao
  evento); o administrador mexe em todos. É a "autorização por dono":
  além de saber QUEM é a pessoa e QUAL o perfil dela, a API confere se o
  recurso é DELA.

`g` é um objeto do Flask que dura só uma requisição: o que o decorator
guarda nele fica disponível para a rota e some quando a resposta sai.

Ordem de uso nas rotas: `@tratar_erros` por fora e o decorator de
autenticação logo abaixo, para que um erro inesperado ao conferir o
token também vire a resposta 500 genérica.
"""

from functools import wraps

from flask import g, jsonify, request

from backend.models.evento import Evento
from backend.models.organizador import Organizador
from backend.models.palestra import Palestra
from backend.models.usuario import TIPO_ORGANIZADOR
from backend.services.auth.token_service import TokenService


def login_obrigatorio(func):
    """Libera a rota só para quem enviou um token de login válido."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        cabecalho = request.headers.get("Authorization", "")
        if not cabecalho.startswith("Bearer "):
            return jsonify({"erro": "Faça login para continuar."}), 401

        usuario = TokenService().buscar_usuario(cabecalho[len("Bearer "):])
        if usuario is None:
            return jsonify({"erro": "Sessão expirada ou inválida. Faça login de novo."}), 401

        g.usuario = usuario
        return func(*args, **kwargs)

    return wrapper


def somente_organizador(func):
    """Libera a rota só para usuários logados do tipo organizador."""

    @wraps(func)
    @login_obrigatorio
    def wrapper(*args, **kwargs):
        if g.usuario.tipo_usuario != TIPO_ORGANIZADOR:
            return jsonify({"erro": "Acesso permitido só para organizadores."}), 403
        return func(*args, **kwargs)

    return wrapper


def verificar_acesso_ao_usuario(id_usuario, administrador_pode=False):
    """Confere se o `id_usuario` da URL é o da pessoa logada.

    Com `administrador_pode=True`, o administrador também passa (ex.: ver
    ou remover a conta de outra pessoa). Até a F08 qualquer organizador
    passava; desde então, o organizador comum só gerencia os próprios
    eventos. Se não puder, lança `PermissionError`, que o `tratar_erros`
    transforma em 403.
    """
    if g.usuario.id_usuario == id_usuario:
        return
    if administrador_pode and g.usuario.tipo_usuario == TIPO_ORGANIZADOR:
        organizador = Organizador.buscar_por_usuario(g.usuario.id_usuario)
        if organizador is not None and organizador.eh_administrador:
            return
    raise PermissionError("Você não tem permissão para acessar dados de outro usuário.")


def verificar_dono_do_evento(id_evento):
    """Confere se a pessoa logada pode gerenciar o evento.

    Usar depois de `@somente_organizador`. Lança `ValueError` (400) se o
    evento não existir e `PermissionError` (403) se for de outro
    organizador. Um usuário sem registro em `organizador` nunca passa,
    mesmo com `tipo_usuario = 'organizador'`.
    """
    evento = Evento.buscar_por_id(id_evento)
    if not evento:
        raise ValueError("Evento não encontrado.")
    if not Organizador.usuario_pode_gerenciar(g.usuario, evento):
        raise PermissionError("Você só pode gerenciar os eventos que organiza.")


def verificar_dono_da_palestra(id_palestra):
    """Confere se a pessoa logada pode gerenciar o evento da palestra."""
    palestra = Palestra.buscar_por_id(id_palestra)
    if not palestra:
        raise ValueError("Palestra não encontrada.")
    verificar_dono_do_evento(palestra.id_evento)


def verificar_administrador():
    """Libera só o administrador (`nivel_acesso = 'administrador'`).

    Usar depois de `@somente_organizador`, nas funções que valem para o
    sistema todo, e não para um evento (ex.: ver e remover contas de
    outras pessoas). Lança `PermissionError` (403).
    """
    organizador = Organizador.buscar_por_usuario(g.usuario.id_usuario)
    if organizador is None or not organizador.eh_administrador:
        raise PermissionError("Acesso permitido só para o administrador.")
