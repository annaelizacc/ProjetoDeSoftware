"""
Validações dos dados de um usuário: nome, email e senha.

CAMADA: Services (regras de negócio compartilhadas pelos casos de uso de
usuário).

O cadastro (`CriarUsuarioService`) e a atualização
(`AtualizarUsuarioService`) recebem os mesmos campos e precisam seguir as
mesmas regras. Antes, cada um tinha a sua cópia da conferência da senha;
se a regra mudasse em um e não no outro, o sistema passaria a ter duas
regras diferentes. Aqui cada regra existe uma vez só, e os dois Services
chamam estas funções (F01).

As regras ficam no backend, e não só na tela de cadastro do app, porque
a rota de cadastro é pública: quem chamasse a API direto (com `curl`, por
exemplo) escaparia de uma conferência feita só no Flutter.

Cada função recebe o valor enviado, levanta `ValueError` com uma mensagem
clara se ele não servir (o `@tratar_erros` transforma isso em HTTP 400) e
devolve o valor já arrumado para gravar.

Também é conferido se o valor é um texto (`isinstance(valor, str)`): o
JSON pode trazer um número ou uma lista no lugar, e funções de texto como
`len` e `strip` dariam um erro inesperado (HTTP 500) em vez de uma
mensagem clara.
"""

import re

from backend.models.usuario import TAMANHO_MAXIMO_SENHA, TAMANHO_MINIMO_SENHA

# Tamanho máximo do nome e do email: o mesmo das colunas `String(150)` da
# Model `Usuario`. Um texto maior seria recusado pelo banco com erro 500.
TAMANHO_MAXIMO_TEXTO = 150

# Formato de email, escrito como expressão regular (um "molde" de texto):
# algo sem espaço e sem "@", um "@", algo, um ponto e algo
# (ex.: ana@email.com). Confere só o formato, não se o email existe.
# A tela de cadastro (`cadastro_page.dart`) usa o mesmo molde.
FORMATO_EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def validar_nome(nome):
    """Confere o nome e o devolve sem espaços nas pontas."""
    if not isinstance(nome, str) or not nome.strip():
        raise ValueError("Informe o nome.")
    nome = nome.strip()
    if len(nome) > TAMANHO_MAXIMO_TEXTO:
        raise ValueError(f"O nome pode ter no máximo {TAMANHO_MAXIMO_TEXTO} caracteres.")
    return nome


def validar_email(email):
    """Confere o formato do email e o devolve em minúsculas, sem espaços nas pontas."""
    if not isinstance(email, str):
        raise ValueError("Digite um email válido.")
    email = email.strip().lower()
    if len(email) > TAMANHO_MAXIMO_TEXTO or not FORMATO_EMAIL.match(email):
        raise ValueError("Digite um email válido.")
    return email


def validar_senha(senha):
    """Confere se a senha é um texto com 8 a 16 caracteres.

    O máximo também protege o servidor: a rota de cadastro é pública, e
    gerar o hash de uma "senha" com milhões de caracteres gastaria muito
    processamento a cada pedido.
    """
    if (
        not isinstance(senha, str)
        or not TAMANHO_MINIMO_SENHA <= len(senha) <= TAMANHO_MAXIMO_SENHA
    ):
        raise ValueError(
            f"A senha precisa ter de {TAMANHO_MINIMO_SENHA} a "
            f"{TAMANHO_MAXIMO_SENHA} caracteres."
        )
    return senha
