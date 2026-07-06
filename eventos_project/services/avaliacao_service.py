from database.db import db
from models.avaliacao import Avaliacao
from models.palestra import Palestra
from models.usuario import Usuario


class AvaliacaoService:
    """Regras de negócio das Avaliações (nota em estrelas)."""

    @staticmethod
    def listar_por_palestra(palestra_id):
        return Avaliacao.query.filter_by(palestra_id=palestra_id).all()

    @staticmethod
    def buscar_por_id(avaliacao_id):
        avaliacao = Avaliacao.query.get(avaliacao_id)
        if not avaliacao:
            raise ValueError("Avaliação não encontrada.")
        return avaliacao

    @staticmethod
    def avaliar(usuario_id, palestra_id, estrelas):
        if not isinstance(estrelas, int) or not (1 <= estrelas <= 5):
            raise ValueError("A nota deve ser um inteiro entre 1 e 5.")
        if not Usuario.query.get(usuario_id):
            raise ValueError("Usuário informado não existe.")
        if not Palestra.query.get(palestra_id):
            raise ValueError("Palestra informada não existe.")

        existente = Avaliacao.query.filter_by(usuario_id=usuario_id, palestra_id=palestra_id).first()
        if existente:
            existente.estrelas = estrelas
            db.session.commit()
            return existente

        avaliacao = Avaliacao(estrelas=estrelas, usuario_id=usuario_id, palestra_id=palestra_id)
        db.session.add(avaliacao)
        db.session.commit()
        return avaliacao

    @staticmethod
    def media_por_palestra(palestra_id):
        avaliacoes = AvaliacaoService.listar_por_palestra(palestra_id)
        if not avaliacoes:
            return 0
        return round(sum(a.estrelas for a in avaliacoes) / len(avaliacoes), 2)
