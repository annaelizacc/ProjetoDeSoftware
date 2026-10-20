"""
Mixin de CRUD compartilhado por todas as Models do projeto.

CAMADA: Models (infraestrutura de persistência via SQLAlchemy).

POR QUE ESTE ARQUIVO EXISTE:
As instruções do projeto pedem que cada Model possua métodos de CRUD
(criar, buscar_por_id, listar, atualizar, remover). Se esses métodos fossem
escritos manualmente em cada uma das 12 Models, o código ficaria repetido
(mesma lógica de "adicionar na sessão e commitar", "buscar pela chave
primária", etc.) em todos os arquivos, o que fere a regra de "não duplicar
lógica desnecessariamente".

Por isso, a implementação padrão do CRUD fica centralizada aqui, em um
Mixin. Cada Model continua herdando de `db.Model` normalmente (o Mixin é
uma classe adicional, não substitui `db.Model`) e ganha os métodos abaixo
por herança múltipla, por exemplo:

    class Evento(db.Model, CRUDMixin):
        ...

Quando uma Model precisa de uma regra especial no momento de criar ou
atualizar um registro (por exemplo, a Palestra precisa calcular
`vagas_disponiveis` a partir de `vagas_total`), ela apenas sobrescreve o
método correspondente e continua usando `super()` quando fizer sentido.

COM QUEM SE COMUNICA:
Os Services (camada de casos de uso) chamam estes métodos para executar
operações de persistência. O Mixin usa a sessão do SQLAlchemy (`db.session`)
diretamente, pois lidar com a chave primária e com objetos já mapeados é
responsabilidade da própria Model — não é uma "consulta" complexa que
justificaria um Repository com SQL explícito (essa camada é usada apenas
quando a consulta envolve filtros, ordenações ou JOINs mais elaborados).
"""

from backend.extensions import db


class CRUDMixin:
    """Implementação padrão das operações de CRUD para uma Model."""

    @classmethod
    def criar(cls, **dados):
        """Cria e persiste um novo registro a partir dos dados recebidos.

        Os `dados` são passados como palavras-chave e mapeados diretamente
        para as colunas da Model. Regras de negócio (validações, valores
        calculados, hashes de senha, etc.) não pertencem a este método —
        elas devem ser resolvidas no Service antes de chamar `criar`.
        """
        instancia = cls(**dados)
        db.session.add(instancia)
        db.session.commit()
        return instancia

    @classmethod
    def buscar_por_id(cls, id_registro):
        """Retorna o registro pela chave primária, ou None se não existir.

        Usamos `db.session.get`, a forma recomendada pelo SQLAlchemy para
        busca por chave primária. Isso não conflita com a regra de "SQL
        puro nos Repositories": aquela regra vale para consultas com
        filtros/JOINs, que ficam na camada de Repository.
        """
        return db.session.get(cls, id_registro)

    @classmethod
    def listar(cls):
        """Retorna todos os registros da tabela, sem filtros.

        Listagens que precisam de filtros, ordenação especial ou JOINs
        devem ser implementadas em um Repository com SQL explícito, e não
        aqui — este método cobre apenas o caso trivial "listar tudo".
        """
        return cls.query.all()

    @classmethod
    def atualizar(cls, id_registro, **dados):
        """Localiza o registro pelo ID e atualiza os campos informados.

        Somente os atributos existentes na Model são alterados; chaves
        desconhecidas em `dados` são ignoradas silenciosamente, para evitar
        que um payload mal formado quebre a atualização inteira.
        Retorna a instância atualizada, ou None se o registro não existir
        (quem chama decide como tratar esse caso — normalmente lançando
        um ValueError na camada de Service).
        """
        instancia = cls.buscar_por_id(id_registro)
        if instancia is None:
            return None
        for campo, valor in dados.items():
            if hasattr(instancia, campo):
                setattr(instancia, campo, valor)
        db.session.commit()
        return instancia

    @classmethod
    def remover(cls, id_registro):
        """Remove o registro pelo ID. Retorna True se removeu, False se não existia."""
        instancia = cls.buscar_por_id(id_registro)
        if instancia is None:
            return False
        db.session.delete(instancia)
        db.session.commit()
        return True
