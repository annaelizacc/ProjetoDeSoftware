"""Importar os Models aqui registra todas as tabelas no metadata do SQLAlchemy."""

from backend.models.evento import Evento
from backend.models.comentario import Comentario
from backend.models.favorito import Favorito
from backend.models.localizacao import Localizacao
from backend.models.notificacao import Notificacao
from backend.models.organizador import Organizador
from backend.models.palestra import Palestra
from backend.models.participacao import Participacao
from backend.models.planta_baixa import PlantaBaixa
from backend.models.restaurante import Restaurante
from backend.models.restaurante_evento import RestauranteEvento
from backend.models.usuario import Usuario

__all__ = [
    "Evento",
    "Comentario",
    "Favorito",
    "Localizacao",
    "Notificacao",
    "Organizador",
    "Palestra",
    "Participacao",
    "PlantaBaixa",
    "Restaurante",
    "RestauranteEvento",
    "Usuario",
]
