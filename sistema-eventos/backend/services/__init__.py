"""
Pacote de Services.

CAMADA: Services (casos de uso da aplicação).

Cada subpasta representa uma entidade do domínio (auth, usuario, evento,
palestra, agenda, participacao, favorito, notificacao, avaliacao) e
contém uma classe por caso de uso, cada uma com um único método
`execute()`. Essa organização evita Services "gigantes" com muitas
responsabilidades misturadas — cada arquivo aqui faz exatamente uma coisa,
e o nome do arquivo/classe já diz qual é essa coisa.
"""
