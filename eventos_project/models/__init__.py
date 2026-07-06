# Importa todos os Models num só lugar para que o SQLAlchemy
# reconheça as tabelas ao rodar db.create_all().
from models.associations import palestra_palestrante
from models.evento import Evento
from models.planta_baixa import PlantaBaixa
from models.rota import Rota
from models.patrocinador import Patrocinador
from models.palestrante import Palestrante
from models.palestra import Palestra
from models.usuario import Usuario
from models.organizador import Organizador
from models.comunicado import Comunicado
from models.notificacao import Notificacao
from models.inscricao import Inscricao
from models.favorito import Favorito
from models.feedback import Feedback
from models.avaliacao import Avaliacao

__all__ = [
    "palestra_palestrante",
    "Evento",
    "PlantaBaixa",
    "Rota",
    "Patrocinador",
    "Palestrante",
    "Palestra",
    "Usuario",
    "Organizador",
    "Comunicado",
    "Notificacao",
    "Inscricao",
    "Favorito",
    "Feedback",
    "Avaliacao",
]
