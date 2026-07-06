from database.db import db
from models.rota import Rota
from models.planta_baixa import PlantaBaixa


class RotaService:
    """Regras de negócio relacionadas à Rota (dentro de uma PlantaBaixa)."""

    @staticmethod
    def listar_por_planta(planta_baixa_id):
        return Rota.query.filter_by(planta_baixa_id=planta_baixa_id).all()

    @staticmethod
    def buscar_por_id(rota_id):
        rota = Rota.query.get(rota_id)
        if not rota:
            raise ValueError("Rota não encontrada.")
        return rota

    @staticmethod
    def criar(dados):
        obrigatorios = ("origem", "destino", "planta_baixa_id")
        if not all(dados.get(campo) for campo in obrigatorios):
            raise ValueError("Campos 'origem', 'destino' e 'planta_baixa_id' são obrigatórios.")

        if not PlantaBaixa.query.get(dados["planta_baixa_id"]):
            raise ValueError("Planta baixa informada não existe.")

        rota = Rota(
            origem=dados["origem"], destino=dados["destino"], planta_baixa_id=dados["planta_baixa_id"]
        )
        db.session.add(rota)
        db.session.commit()
        return rota

    @staticmethod
    def atualizar(rota_id, dados):
        rota = RotaService.buscar_por_id(rota_id)
        rota.origem = dados.get("origem", rota.origem)
        rota.destino = dados.get("destino", rota.destino)
        db.session.commit()
        return rota

    @staticmethod
    def deletar(rota_id):
        rota = RotaService.buscar_por_id(rota_id)
        db.session.delete(rota)
        db.session.commit()

    @staticmethod
    def calcular_rota(rota_id):
        """
        Regra simplificada (projeto acadêmico): retorna a descrição do trajeto.
        Um cálculo real de rota (ex: menor caminho) dependeria de um grafo de
        pontos da planta baixa, fora do escopo deste diagrama.
        """
        rota = RotaService.buscar_por_id(rota_id)
        return f"Trajeto sugerido: {rota.origem} → {rota.destino}"

    @staticmethod
    def exibir_rota(rota_id):
        rota = RotaService.buscar_por_id(rota_id)
        return rota.to_dict()
