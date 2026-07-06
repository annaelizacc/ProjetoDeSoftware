from flask import Blueprint, render_template

# Este blueprint serve as PÁGINAS HTML (front-end), consumidas via fetch().
# Não faz parte da API REST (/api/...) e não contém regra de negócio —
# só monta o contexto (título, colunas, campos do formulário) que os
# templates usam para configurar o motor genérico de CRUD em JS.
paginas_bp = Blueprint("paginas", __name__)


@paginas_bp.route("/")
def index():
    return render_template("index.html")


@paginas_bp.route("/eventos")
def pagina_eventos():
    return render_template(
        "crud.html",
        titulo="Eventos",
        colunas=[
            {"key": "id", "label": "ID"},
            {"key": "nome", "label": "Nome"},
            {"key": "local", "label": "Local"},
            {"key": "data", "label": "Data"},
        ],
        campos=[
            {"name": "nome", "label": "Nome do evento", "type": "text", "required": True},
            {"name": "local", "label": "Local", "type": "text", "required": True},
            {"name": "data", "label": "Data", "type": "date", "required": True},
        ],
        api={"list": "/eventos/", "create": "/eventos/", "update_prefix": "/eventos/", "delete_prefix": "/eventos/"},
    )


@paginas_bp.route("/palestras")
def pagina_palestras():
    return render_template(
        "crud.html",
        titulo="Palestras",
        colunas=[
            {"key": "id", "label": "ID"},
            {"key": "titulo", "label": "Título"},
            {"key": "tema", "label": "Tema"},
            {"key": "horario", "label": "Horário"},
            {"key": "vagas_disponiveis", "label": "Vagas"},
            {"key": "evento_id", "label": "Evento (ID)"},
        ],
        campos=[
            {"name": "titulo", "label": "Título", "type": "text", "required": True},
            {"name": "tema", "label": "Tema", "type": "text"},
            {"name": "descricao", "label": "Descrição", "type": "textarea"},
            {"name": "horario", "label": "Horário", "type": "datetime-local", "required": True},
            {"name": "vagas_disponiveis", "label": "Vagas disponíveis", "type": "number"},
            {"name": "evento_id", "label": "ID do Evento", "type": "number", "required": True},
        ],
        api={"list": "/palestras/", "create": "/palestras/", "update_prefix": "/palestras/", "delete_prefix": "/palestras/"},
    )


@paginas_bp.route("/palestrantes")
def pagina_palestrantes():
    return render_template(
        "crud.html",
        titulo="Palestrantes",
        colunas=[
            {"key": "id", "label": "ID"},
            {"key": "nome", "label": "Nome"},
            {"key": "empresa", "label": "Empresa"},
        ],
        campos=[
            {"name": "nome", "label": "Nome", "type": "text", "required": True},
            {"name": "biografia", "label": "Biografia", "type": "textarea"},
            {"name": "empresa", "label": "Empresa", "type": "text"},
            {"name": "foto", "label": "URL da foto", "type": "text"},
        ],
        api={
            "list": "/palestrantes/",
            "create": "/palestrantes/",
            "update_prefix": "/palestrantes/",
            "delete_prefix": "/palestrantes/",
        },
    )


@paginas_bp.route("/patrocinadores")
def pagina_patrocinadores():
    return render_template(
        "crud.html",
        titulo="Patrocinadores",
        colunas=[
            {"key": "id", "label": "ID"},
            {"key": "nome", "label": "Nome"},
            {"key": "evento_id", "label": "Evento (ID)"},
        ],
        campos=[
            {"name": "nome", "label": "Nome", "type": "text", "required": True},
            {"name": "logo", "label": "URL do logo", "type": "text"},
            {"name": "descricao", "label": "Descrição", "type": "textarea"},
            {"name": "evento_id", "label": "ID do Evento", "type": "number", "required": True},
        ],
        api={
            "list": "/patrocinadores/",
            "create": "/patrocinadores/",
            "update_prefix": "/patrocinadores/",
            "delete_prefix": "/patrocinadores/",
        },
    )


@paginas_bp.route("/plantas-rotas")
def pagina_plantas_rotas():
    return render_template("plantas_rotas.html")


@paginas_bp.route("/usuarios")
def pagina_usuarios():
    return render_template("usuarios.html")


@paginas_bp.route("/organizadores")
def pagina_organizadores():
    return render_template("organizadores.html")


@paginas_bp.route("/inscricoes")
def pagina_inscricoes():
    return render_template("inscricoes.html")


@paginas_bp.route("/favoritos")
def pagina_favoritos():
    return render_template("favoritos.html")


@paginas_bp.route("/feedbacks")
def pagina_feedbacks():
    return render_template("feedbacks.html")


@paginas_bp.route("/avaliacoes")
def pagina_avaliacoes():
    return render_template("avaliacoes.html")


@paginas_bp.route("/notificacoes")
def pagina_notificacoes():
    return render_template("notificacoes.html")


@paginas_bp.route("/comunicados")
def pagina_comunicados():
    return render_template("comunicados.html")
