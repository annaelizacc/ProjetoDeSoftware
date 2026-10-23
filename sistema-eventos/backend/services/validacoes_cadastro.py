"""
Validações compartilhadas pelos cadastros do organizador (F14).

CAMADA: Services (regras usadas por mais de um caso de uso).

Os campos de texto opcionais (site, rede social, descrição) vêm do app
como texto, mas a API pode receber qualquer coisa (um número, uma lista
ou um texto maior que a coluna do banco). Sem esta conferência, o MySQL
recusaria o valor e a pessoa veria só "Erro interno no servidor.". Com
ela, a resposta é um 400 com uma mensagem clara.
"""

# Tamanho das colunas VARCHAR no banco (`sistema_eventos_atualizado.sql`).
TAMANHO_NOME = 150
TAMANHO_LINK = 255
# As colunas TEXT aceitam muito mais; o limite evita textos enormes.
TAMANHO_DESCRICAO = 5000


def texto_opcional(valor, rotulo, maximo):
    """Devolve o texto sem espaços nas pontas, ou None se vier vazio.

    Lança ValueError se não for texto ou se passar de `maximo` caracteres.
    """
    if valor is None:
        return None
    if not isinstance(valor, str):
        raise ValueError(f"O campo {rotulo} precisa ser um texto.")
    valor = valor.strip()
    if len(valor) > maximo:
        raise ValueError(f"O campo {rotulo} pode ter no máximo {maximo} caracteres.")
    return valor or None


def texto_obrigatorio(valor, mensagem, maximo):
    """Como `texto_opcional`, mas vazio lança ValueError com `mensagem`."""
    valor = texto_opcional(valor, "nome", maximo)
    if not valor:
        raise ValueError(mensagem)
    return valor
