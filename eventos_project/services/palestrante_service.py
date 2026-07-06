from database.db import db
from models.palestrante import Palestrante


class PalestranteService:
    """Regras de negócio relacionadas ao Palestrante."""

    @staticmethod
    def listar_todos():
        return Palestrante.query.all()

    @staticmethod
    def buscar_por_id(palestrante_id):
        palestrante = Palestrante.query.get(palestrante_id)
        if not palestrante:
            raise ValueError("Palestrante não encontrado.")
        return palestrante

    @staticmethod
    def criar(dados):
        if not dados.get("nome"):
            raise ValueError("Campo 'nome' é obrigatório.")

        palestrante = Palestrante(
            nome=dados["nome"],
            biografia=dados.get("biografia"),
            empresa=dados.get("empresa"),
            foto=dados.get("foto"),
        )
        db.session.add(palestrante)
        db.session.commit()
        return palestrante

    @staticmethod
    def atualizar(palestrante_id, dados):
        palestrante = PalestranteService.buscar_por_id(palestrante_id)
        palestrante.nome = dados.get("nome", palestrante.nome)
        palestrante.biografia = dados.get("biografia", palestrante.biografia)
        palestrante.empresa = dados.get("empresa", palestrante.empresa)
        palestrante.foto = dados.get("foto", palestrante.foto)
        db.session.commit()
        return palestrante

    @staticmethod
    def deletar(palestrante_id):
        palestrante = PalestranteService.buscar_por_id(palestrante_id)
        db.session.delete(palestrante)
        db.session.commit()

    @staticmethod
    def vizualizar_informacoes(palestrante_id):
        palestrante = PalestranteService.buscar_por_id(palestrante_id)
        return palestrante.to_dict()
