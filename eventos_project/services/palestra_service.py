from database.db import db
from models.palestra import Palestra
from models.evento import Evento
from models.palestrante import Palestrante


class PalestraService:
    """Regras de negócio relacionadas à Palestra."""

    @staticmethod
    def listar_todas():
        return Palestra.query.all()

    @staticmethod
    def buscar_por_id(palestra_id):
        palestra = Palestra.query.get(palestra_id)
        if not palestra:
            raise ValueError("Palestra não encontrada.")
        return palestra

    @staticmethod
    def criar(dados):
        obrigatorios = ("titulo", "horario", "evento_id")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("Campos 'titulo', 'horario' e 'evento_id' são obrigatórios.")

        if not Evento.query.get(dados["evento_id"]):
            raise ValueError("Evento informado não existe.")

        palestra = Palestra(
            titulo=dados["titulo"],
            horario=dados["horario"],
            evento_id=dados["evento_id"],
            tema=dados.get("tema"),
            descricao=dados.get("descricao"),
            vagas_disponiveis=dados.get("vagas_disponiveis", 0),
        )

        # Associação N:N com Palestrantes, se informado
        ids_palestrantes = dados.get("palestrante_ids", [])
        if ids_palestrantes:
            palestrantes = Palestrante.query.filter(Palestrante.id.in_(ids_palestrantes)).all()
            if len(palestrantes) != len(ids_palestrantes):
                raise ValueError("Um ou mais palestrantes informados não existem.")
            palestra.palestrantes = palestrantes

        db.session.add(palestra)
        db.session.commit()
        return palestra

    @staticmethod
    def atualizar(palestra_id, dados):
        palestra = PalestraService.buscar_por_id(palestra_id)
        palestra.titulo = dados.get("titulo", palestra.titulo)
        palestra.tema = dados.get("tema", palestra.tema)
        palestra.descricao = dados.get("descricao", palestra.descricao)
        palestra.horario = dados.get("horario", palestra.horario)
        palestra.vagas_disponiveis = dados.get("vagas_disponiveis", palestra.vagas_disponiveis)

        if "palestrante_ids" in dados:
            palestrantes = Palestrante.query.filter(
                Palestrante.id.in_(dados["palestrante_ids"])
            ).all()
            palestra.palestrantes = palestrantes

        db.session.commit()
        return palestra

    @staticmethod
    def deletar(palestra_id):
        palestra = PalestraService.buscar_por_id(palestra_id)
        db.session.delete(palestra)
        db.session.commit()

    @staticmethod
    def exibir_detalhes(palestra_id):
        palestra = PalestraService.buscar_por_id(palestra_id)
        return palestra.to_dict()

    @staticmethod
    def verificar_vagas(palestra_id):
        palestra = PalestraService.buscar_por_id(palestra_id)
        return palestra.vagas_disponiveis

    @staticmethod
    def pesquisar_por_nome(nome):
        """Pesquisa palestras cujo título contenha o termo informado."""
        if not nome:
            return []
        return Palestra.query.filter(Palestra.titulo.ilike(f"%{nome}%")).all()
