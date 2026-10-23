"""
Model: Palestra.

CAMADA: Models (entidade de domínio + persistência).

Representa uma palestra pertencente a um Evento. Além dos campos vindos
do banco oficial (título, resumo, tema, horários), a Palestra controla o
número de vagas disponíveis para inscrição — regra que existia antes desta
refatoração e foi preservada.

Local e palestrante (F19/D01): o antigo texto livre `sala` virou
`id_localizacao` (um registro de `localizacao`, usado na tela de rotas da
F04), e `id_palestrante` liga a palestra a quem a apresenta (F05). Os dois
são opcionais. Para o app não precisar mudar, o `to_dict` continua
devolvendo o campo `sala`, agora com o nome do local.

Herda `db.Model` (tabela `palestra`) e `CRUDMixin` (CRUD padrão). O método
`criar` é sobrescrito porque a Palestra tem uma regra própria: ao ser
criada, `vagas_disponiveis` deve começar igual a `vagas_total` (ninguém
se inscreveu ainda). Essa é uma regra de dados simples o suficiente para
viver na Model; regras que dependem de outras entidades (como verificar
se o Evento existe) continuam no Service.
"""

from backend.extensions import db
from backend.models.crud_mixin import CRUDMixin


class Palestra(db.Model, CRUDMixin):
    """Palestra alinhada às colunas do banco oficial."""

    __tablename__ = "palestra"

    id_palestra = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(200), nullable=False)
    resumo = db.Column(db.Text)
    tema = db.Column(db.String(120))
    horario_inicio = db.Column(db.DateTime)
    horario_fim = db.Column(db.DateTime)
    id_evento = db.Column(
        db.Integer, db.ForeignKey("evento.id_evento"), nullable=False
    )
    id_localizacao = db.Column(
        db.Integer, db.ForeignKey("localizacao.id_localizacao")
    )
    id_palestrante = db.Column(
        db.Integer, db.ForeignKey("palestrante.id_palestrante")
    )
    # Extensão necessária para controlar vagas de inscrição.
    vagas_total = db.Column(db.Integer, nullable=False, default=50)
    vagas_disponiveis = db.Column(db.Integer, nullable=False, default=50)

    evento = db.relationship("Evento", back_populates="palestras")
    localizacao = db.relationship("Localizacao")
    palestrante = db.relationship("Palestrante")

    @classmethod
    def criar(cls, **dados):
        """Cria a palestra garantindo que `vagas_disponiveis` comece cheia.

        Sobrescreve o `criar` genérico do CRUDMixin porque esta Model tem
        uma regra própria de inicialização de dados (não é uma regra de
        negócio entre entidades, por isso permanece aqui e não no Service).
        """
        dados = dict(dados)
        total = int(dados.get("vagas_total", 50) or 50)
        dados["vagas_total"] = total
        dados.setdefault("vagas_disponiveis", total)
        instancia = cls(**dados)
        db.session.add(instancia)
        db.session.commit()
        return instancia

    def to_dict(self):
        """Serializa a palestra, incluindo o nome do evento, o local, o palestrante e o status das vagas."""
        return {
            "id_palestra": self.id_palestra,
            "titulo": self.titulo,
            "resumo": self.resumo,
            "tema": self.tema,
            "sala": self.localizacao.nome_local if self.localizacao else None,
            "id_localizacao": self.id_localizacao,
            # Passo a passo da entrada até a sala (F04, RF11), escrito pelo
            # organizador no cadastro do local, um passo por linha.
            "como_chegar": self.localizacao.descricao if self.localizacao else None,
            "id_palestrante": self.id_palestrante,
            "palestrante": self.palestrante.nome if self.palestrante else None,
            "horario_inicio": (
                self.horario_inicio.isoformat() if self.horario_inicio else None
            ),
            "horario_fim": (
                self.horario_fim.isoformat() if self.horario_fim else None
            ),
            "id_evento": self.id_evento,
            "nome_evento": self.evento.nome if self.evento else None,
            "vagas_total": self.vagas_total,
            "vagas_disponiveis": self.vagas_disponiveis,
            "status_vagas": (
                "lotada" if self.vagas_disponiveis <= 0 else "disponível"
            ),
        }
