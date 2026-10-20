"""Importar os Models aqui registra todas as tabelas no metadata do SQLAlchemy."""

from backend.models.avaliacao import Avaliacao
from backend.models.certificado import Certificado
from backend.models.evento import Evento
from backend.models.favorito import Favorito
from backend.models.localizacao import Localizacao
from backend.models.notificacao import Notificacao
from backend.models.organizador import Organizador
from backend.models.palestra import Palestra
from backend.models.palestrante import Palestrante
from backend.models.participacao import Participacao
from backend.models.patrocinador import Patrocinador
from backend.models.planta_baixa import PlantaBaixa
from backend.models.restaurante import Restaurante
from backend.models.restaurante_evento import RestauranteEvento
from backend.models.usuario import Usuario

__all__ = [
    "Avaliacao",
    "Certificado",
    "Evento",
    "Favorito",
    "Localizacao",
    "Notificacao",
    "Organizador",
    "Palestra",
    "Palestrante",
    "Participacao",
    "Patrocinador",
    "PlantaBaixa",
    "Restaurante",
    "RestauranteEvento",
    "Usuario",
]
