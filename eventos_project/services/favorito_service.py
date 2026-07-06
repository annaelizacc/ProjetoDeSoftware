from database.db import db
from models.favorito import Favorito
from models.palestra import Palestra
from models.usuario import Usuario


class FavoritoService:
    """Regras de negócio dos Favoritos."""

    @staticmethod
    def listar_por_usuario(usuario_id):
        return Favorito.query.filter_by(usuario_id=usuario_id).all()

    @staticmethod
    def buscar_por_id(favorito_id):
        favorito = Favorito.query.get(favorito_id)
        if not favorito:
            raise ValueError("Favorito não encontrado.")
        return favorito

    @staticmethod
    def adicionar(usuario_id, palestra_id):
        if not Usuario.query.get(usuario_id):
            raise ValueError("Usuário informado não existe.")
        if not Palestra.query.get(palestra_id):
            raise ValueError("Palestra informada não existe.")

        if Favorito.query.filter_by(usuario_id=usuario_id, palestra_id=palestra_id).first():
            raise ValueError("Palestra já está nos favoritos deste usuário.")

        favorito = Favorito(usuario_id=usuario_id, palestra_id=palestra_id)
        db.session.add(favorito)
        db.session.commit()
        return favorito

    @staticmethod
    def remover(usuario_id, palestra_id):
        favorito = Favorito.query.filter_by(usuario_id=usuario_id, palestra_id=palestra_id).first()
        if not favorito:
            raise ValueError("Este favorito não existe.")

        db.session.delete(favorito)
        db.session.commit()
        return True
