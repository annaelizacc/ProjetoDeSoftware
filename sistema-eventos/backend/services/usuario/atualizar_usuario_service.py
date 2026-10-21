"""
Caso de uso: atualizar dados de um usuário.

CAMADA: Services (regra de negócio do caso de uso "Atualizar Usuário").

Só `nome`, `email` e `senha` podem ser alterados (lista de campos
permitidos, como na atualização de avaliação). Os outros campos
recebidos são ignorados, entre eles (P01):

- `tipo_usuario`: se a pessoa pudesse trocar o próprio tipo, viraria
  organizadora sozinha. Organizadores são criados direto no banco (ver
  README);
- `google_id` (preparo para a F18): se qualquer um pudesse gravá-lo,
  poderia ligar a própria conta Google à conta de outra pessoa e entrar
  como ela. Só o futuro login com Google deve preencher esse campo;
- `id_usuario`: a chave primária nunca muda.

Usar uma lista do que é permitido, em vez de uma lista do que é
proibido, faz com que uma coluna nova na tabela já nasça protegida.

Se uma nova senha for enviada, ela é convertida em hash antes de chegar
à Model — a Model nunca deve receber senha em texto puro para gravação.
Cada campo enviado passa pelas mesmas validações do cadastro
(`validacoes_usuario.py`, F01), para as regras valerem em todo o sistema.
Assim, senha vazia ou curta é recusada (gravá-la deixaria a conta fraca
ou sem conseguir entrar), e o mesmo vale para email vazio ou fora do
formato.

Método principal:
    execute(id_usuario, dados): retorna o Usuario atualizado.
"""

from werkzeug.security import generate_password_hash

from backend.models.usuario import Usuario
from backend.services.usuario.validacoes_usuario import (
    validar_email,
    validar_nome,
    validar_senha,
)

CAMPOS_EDITAVEIS = ("nome", "email", "senha")


class AtualizarUsuarioService:
    """Caso de uso responsável pela atualização de um usuário existente."""

    def execute(self, id_usuario, dados):
        alteracoes = {campo: dados[campo] for campo in CAMPOS_EDITAVEIS if campo in dados}
        if "nome" in alteracoes:
            alteracoes["nome"] = validar_nome(alteracoes["nome"])
        if "email" in alteracoes:
            alteracoes["email"] = validar_email(alteracoes["email"])
        if "senha" in alteracoes:
            alteracoes["senha"] = generate_password_hash(validar_senha(alteracoes["senha"]))

        usuario = Usuario.atualizar(id_usuario, **alteracoes)
        if not usuario:
            raise ValueError("Usuário não encontrado.")
        return usuario
