from database.db import db
from models.planta_baixa import PlantaBaixa
from models.evento import Evento


class PlantaBaixaService:
    """Regras de negócio relacionadas à PlantaBaixa."""

    @staticmethod
    def buscar_por_id(planta_id):
        planta = PlantaBaixa.query.get(planta_id)
        if not planta:
            raise ValueError("Planta baixa não encontrada.")
        return planta

    @staticmethod
    def buscar_por_evento(evento_id):
        planta = PlantaBaixa.query.filter_by(evento_id=evento_id).first()
        if not planta:
            raise ValueError("Este evento ainda não possui planta baixa cadastrada.")
        return planta

    @staticmethod
    def criar(dados):
        if not dados.get("mapa") or not dados.get("evento_id"):
            raise ValueError("Campos 'mapa' e 'evento_id' são obrigatórios.")

        if not Evento.query.get(dados["evento_id"]):
            raise ValueError("Evento informado não existe.")

        if PlantaBaixa.query.filter_by(evento_id=dados["evento_id"]).first():
            raise ValueError("Este evento já possui uma planta baixa (relação é 1:1).")

        planta = PlantaBaixa(mapa=dados["mapa"], evento_id=dados["evento_id"])
        db.session.add(planta)
        db.session.commit()
        return planta

    @staticmethod
    def atualizar(planta_id, dados):
        planta = PlantaBaixaService.buscar_por_id(planta_id)
        planta.mapa = dados.get("mapa", planta.mapa)
        db.session.commit()
        return planta

    @staticmethod
    def deletar(planta_id):
        planta = PlantaBaixaService.buscar_por_id(planta_id)
        db.session.delete(planta)
        db.session.commit()

    @staticmethod
    def vizualizar_mapa(evento_id):
        """Retorna a URL/caminho do mapa associado ao evento."""
        planta = PlantaBaixaService.buscar_por_evento(evento_id)
        return planta.mapa
