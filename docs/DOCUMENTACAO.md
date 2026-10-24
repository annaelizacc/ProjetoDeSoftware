# Documentação do projeto Fluxo Eventos

Registro das decisões tomadas durante o desenvolvimento e de como cada
tarefa do `PENDENCIAS.md` foi resolvida. Serve de base para a
documentação final do projeto.

---

## 1. Ajustes na modelagem durante o desenvolvimento

O diagrama do banco de dados (Seção 5 do relatório de elicitação de
requisitos) foi entregue e **não foi alterado**. Durante o
desenvolvimento, algumas diferenças entre o diagrama e o banco
implementado se mostraram necessárias. Esta seção explica cada uma.

Decisão tomada em 20/10/2026 (D01 do `PENDENCIAS.md`).

### 1.1 Tabelas e campos do diagrama que foram mantidos

| Item do diagrama | Uso no sistema |
|---|---|
| `patrocinador` | Patrocinadores do evento (RF19) |
| `avaliacao` | Avaliação das palestras por estrelas (RF16) |
| `certificado` (sem o campo `Atributo_1`) | Certificado de participação no evento |
| Ligação entre `palestra` e `localizacao` | Local da palestra e rota até ele (RF11) |
| `restaurante` | Restaurantes próximos, cadastro opcional para o organizador |

### 1.2 Diferenças em relação ao diagrama

| Item | O que o diagrama previa | O que foi implementado | Motivo |
|---|---|---|---|
| `favorito` | Não existia | Tabela criada | Sem ela não é possível favoritar palestras (RF07) |
| Vagas da palestra | `palestra` sem controle de vagas | Campos `vagas_total` e `vagas_disponiveis` | Sem eles não há controle automático de vagas (RF05) |
| `palestrante` | Não existia | Tabela criada (nome, foto, descrição, rede social), ligada à palestra | O diagrama não tinha onde guardar os dados pedidos pelos RF13 e RF14. Uma tabela própria evita repetir os dados quando a mesma pessoa dá mais de uma palestra |
| `mensagem` | Tabela com remetente, destinatário e conteúdo | Não criada | Nenhum requisito pede troca de mensagens entre usuários. Os comunicados do organizador (RF18) usam a tabela `notificacao` |
| `notificacao.id_palestra` | Obrigatório | Opcional | Um comunicado geral do organizador (RF18) não pertence a uma palestra |
| `comentario` | Tabela de comentários com campo de nota | Tabela removida; o comentário virou um campo opcional de `avaliacao` | Na tela "Avaliar", estrelas e comentário são enviados juntos. Com uma tabela só, a nota e o comentário não ficam guardados em dois lugares (RF15 e RF16) |
| `usuario.tema_preferido` | Campo no usuário | Não criado | A escolha entre modo claro e escuro (RF20) fica salva no próprio celular |
| `usuario.senha` e `usuario.google_id` | Senha obrigatória; sem `google_id` | Senha opcional e `google_id` único | Preparo para o login com Google (F18): quem entra pelo Google não tem senha no sistema. O login por e-mail e senha recusa esses usuários |
| `certificado.Atributo_1` | Campo sem nome | Não criado | O campo não tinha nome nem significado definido |
| `tipo_usuario = 'palestrante'` | Palestrante como tipo de usuário | Removido | O palestrante não usa o app (não faz login). Seus dados ficam na tabela `palestrante` |
| `evento.id_organizador` (F08, 22/10/2026) | Evento sem ligação com o organizador | Coluna obrigatória, chave estrangeira para `organizador` (`ON DELETE RESTRICT`) | Cada evento tem um só organizador responsável, que é quem o cria. Sem a ligação, qualquer organizador mexeria no evento de outro. O `RESTRICT` impede apagar um organizador que ainda tem eventos, para nenhum evento ficar sem responsável |
| `notificacao.id_evento` (F09, 23/10/2026) | Notificação sem ligação com o evento | Coluna opcional, chave estrangeira para `evento` (`ON DELETE CASCADE`), preenchida só nos comunicados do organizador | O comunicado para todos os participantes não tem palestra, então sem esse campo não haveria como saber de qual evento ele veio. Com ele, a aba Avisos mostra o nome do evento (e o da palestra, quando o comunicado é só para os inscritos dela). O `CASCADE` apaga os comunicados junto com o evento, como já acontece com a palestra |

### 1.3 Limitação conhecida

Garantir a vaga em uma palestra (inscrição) vale como confirmação de
presença para emitir o certificado. Por isso, quem se inscreveu e não
compareceu também recebe o certificado.

---

## 2. F19: atualização do banco conforme a D01

Concluída em 20/10/2026. Todas as mudanças de banco decididas na D01
foram feitas de uma vez, por uma pessoa só, antes das tarefas que usam o
banco. Assim, duas pessoas não editam o mesmo script SQL ao mesmo tempo,
o que causaria conflitos no Git.

### 2.1 O que foi feito

- Tabelas novas: `palestrante`, `avaliacao`, `patrocinador` e
  `certificado`, cada uma com a sua Model.
- `palestra` passou a apontar para `localizacao` e para `palestrante`.
  As salas que eram texto (`palestra.sala`) viraram registros de
  `localizacao`.
- A tabela `comentario` foi substituída por `avaliacao`, e a API
  `/api/comentarios` virou `/api/avaliacoes`.
- `notificacao.id_palestra` ficou opcional.
- `usuario` foi preparado para o login com Google (F18), sem implementá-lo.

### 2.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Comentário como campo opcional de `avaliacao`, e não em tabela própria | Estrelas e comentário são enviados juntos na tela "Avaliar". Duas tabelas guardariam o mesmo dado em dois lugares |
| Adaptar a API de comentários em vez de apagá-la | A F06 e a F07 começam com o backend pronto, e a F19 pôde ser testada pela API |
| Uma avaliação por pessoa e palestra (chave única no banco e conferência no Service) | Sem isso, a mesma pessoa poderia avaliar várias vezes e distorcer a média. Para mudar a nota, a avaliação é atualizada |
| Estrelas sempre inteiras de 1 a 5 (regra `CHECK` no banco e conferência no Service) | O banco recusa valores errados mesmo que venham de fora do app. O Service devolve uma mensagem clara |
| A API continua devolvendo `sala`, agora com o nome do local | As telas do app que já mostravam a sala não precisaram mudar |
| Palestrante e local opcionais na palestra (`ON DELETE SET NULL`) | Se um palestrante ou um local for apagado, a palestra continua existindo, só fica sem essa informação |
| O local de uma palestra precisa ser do mesmo evento | Uma sala de outro evento não aparece na planta nem nas rotas do evento da palestra |
| Preparar o banco para a F18 agora, sem implementá-la | Se houver tempo para o login com Google, o banco já está pronto. O `google_id` não pode ser alterado pela rota de atualizar usuário, para ninguém ligar a própria conta Google à conta de outra pessoa |

### 2.3 Limitações conhecidas

- Enquanto não houver autenticação nas rotas (P01), qualquer pessoa pode
  alterar ou apagar a avaliação de outra. Resolvido na P01 (seção 4).
- O script do banco apaga e recria tudo (`DROP DATABASE`). Quem já tinha
  o banco local precisou recriá-lo, perdendo os dados locais.

---

## 3. F20 parte 1: nova identidade visual e modo escuro (F11)

Concluída em 21/10/2026. A parte 1 cria a base visual do app (cores,
fontes, temas claro e escuro e componentes compartilhados), para que as
telas novas das outras tarefas já nasçam no visual novo. A parte 2 (F20
parte 2) refaz o layout das telas antigas.

### 3.1 O que foi feito

- **Tema:** todas as cores e fontes ficam em `lib/theme/app_theme.dart`,
  com um tema claro e um escuro. As telas pedem a cor pela função (por
  exemplo, `colorScheme.primary` para botões e títulos), e não pelo
  código da cor. Assim, ao ligar o modo escuro, o app inteiro muda junto.
- **Modo escuro (F11, RF20):** interruptor na tela Perfil. A escolha
  fica salva no celular (`lib/theme/controle_tema.dart`).
- **Fontes:** Bricolage Grotesque nos títulos, Figtree nos textos e
  JetBrains Mono em horários e rótulos, como arquivos dentro do projeto
  (`assets/fonts/`, com as licenças).
- **Componentes compartilhados** (`lib/widgets/`): barra de navegação,
  marca-texto, rótulo de seção, selo e cabeçalho de tela.
- **Navegação:** barra com cinco abas (Início, Programação, Agenda,
  Avisos e Perfil). Os Favoritos passaram para dentro do Perfil.
- **Telas novas:** Perfil (nome, Favoritos e Modo escuro) e a aba
  Programação.
- **Telas antigas:** as cores fixas foram trocadas pelas cores do tema,
  para todas acompanharem o modo escuro. Os cards de palestra deixaram
  de ter uma cor diferente para cada tema de palestra e passaram a ter
  um card único.

### 3.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Visual diferente do protótipo do Figma entregue no relatório | O protótipo tinha pouco contraste, fontes misturadas, menu duplicado (barra e sino no topo), telas sem informações essenciais (vagas, botão de inscrição) e textos em inglês. A nova proposta (S06) corrige esses pontos e já inclui o modo escuro, que é um requisito (RF20) |
| Cores e fontes só no tema, nunca nas telas | Com cores fixas, cada tela precisaria de duas versões (claro e escuro). Pelo tema, a troca de modo é feita em um lugar só |
| Escolha do tema salva no celular (`shared_preferences`), e não no banco | Decidido na D01: é uma preferência do aparelho e não precisa de API nem de tabela nova |
| Fontes como arquivos do projeto, e não pelo pacote `google_fonts` | O app funciona sem internet e não depende de um serviço externo na apresentação |
| Fontes em arquivos separados por peso (Regular, Medium, SemiBold, Bold) | O Flutter não aplica sozinho o peso de uma fonte "variável" (um arquivo com todos os pesos). Com um arquivo por peso, o negrito aparece certo |
| Cinco abas, com Favoritos dentro do Perfil | Segue o canvas da identidade visual. Avisos ganhou aba própria no lugar do sino no topo |
| Card único para todas as palestras, sem cor por tema | As cores por tema não tinham significado (eram sorteadas pelo nome) e ficavam claras demais no modo escuro. A identidade pede "sem cores saturadas espalhadas" |
| Aba Programação mostra o primeiro evento cadastrado | Hoje o sistema tem um evento principal. A escolha de outro evento continua pelo Início |

### 3.3 Limitações conhecidas

- O contador de avisos novos da barra de navegação já existe, mas fica
  zerado até a F21 (marcar avisos como lidos).
- As telas antigas (Login, Início, Programação, Detalhes, Agenda, Avisos
  e Favoritos) já usam as cores do tema, mas o layout delas só fica
  igual ao canvas na F20 parte 2.
- O botão "Sair" do Perfil entra na F17 (feito em 22/10/2026, na branch
  da F08).

---

## 4. P01: autenticação por token nas rotas da API

Concluída em 21/10/2026. Antes, o login guardava o usuário na sessão do
Flask, mas nenhuma rota conferia essa sessão: as rotas usavam o
`id_usuario` enviado no corpo ou na URL. Bastava trocar esse número para
agir em nome de outra pessoa. Também não havia diferença entre
participante e organizador.

### 4.1 O que foi feito

- **Token de login** (`backend/services/auth/token_service.py`): no
  login, a API devolve um texto assinado com a `SECRET_KEY` que leva o
  `id_usuario` e a hora de criação. O token vale 8 horas. Pode ser lido
  por qualquer pessoa, mas não pode ser alterado nem fabricado sem a
  chave.
- **Decorators** (`backend/controllers/autenticacao.py`):
  `@login_obrigatorio` confere o token e guarda o usuário em `g.usuario`
  (401 se faltar ou for inválido); `@somente_organizador` também confere
  o perfil, lido do banco (403 se não for organizador). Nas rotas com
  `<id_usuario>` na URL, `verificar_acesso_ao_usuario` só deixa passar a
  própria pessoa.
- **Rotas:** só login, logout e cadastro são públicos. Criar, alterar e
  remover eventos e palestras e listar usuários é só para organizadores.
  Desde a F08, só o organizador responsável pelo evento (ou um
  administrador) mexe no evento e nas palestras dele
  (`verificar_dono_do_evento`), e listar, ver ou remover contas de outras
  pessoas passou a ser só do administrador (`verificar_administrador`). Inscrição, favorito, lembrete e
  avaliação usam sempre o usuário do token, e um `id_usuario` no corpo é
  ignorado.
- **Avaliações:** editar, só o autor; remover, o autor ou um organizador
  (para moderar comentários ofensivos). Desde a F08, só o organizador do
  evento da palestra (ou um administrador).
- **Perfis:** o cadastro cria sempre um participante, e a atualização de
  usuário aceita só `nome`, `email` e `senha`. Organizadores são criados
  direto no banco.
- **App:** o `ApiService` guarda o token na memória depois do login e o
  envia em toda requisição, no cabeçalho `Authorization: Bearer <token>`.
  As telas não mudaram.
- **Erros:** o `tratar_erros` passou a transformar `PermissionError` em
  resposta 403.

### 4.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Token no cabeçalho, e não a sessão com cookie que já existia | O pacote `http` do Flutter não guarda cookies. No celular, o app teria que guardá-los à mão, e no navegador quem cuida deles é o próprio navegador. O token funciona igual em qualquer dispositivo |
| `itsdangerous` para criar o token, e não JWT | Já vem instalado com o Flask (é o que assina a sessão), então não foi preciso biblioteca nova |
| Verificação em decorators | A mesma conferência vale para cerca de 30 rotas. Escrita uma vez só, não há risco de esquecer em alguma rota, e cada rota ganha apenas uma linha. Segue o padrão do `@tratar_erros` |
| Perfil lido do banco, nunca da requisição ou do token | Ninguém consegue se declarar organizador. Se o perfil mudar no banco, a mudança vale na próxima requisição |
| Login exigido em todas as rotas, menos login, logout e cadastro | O app só é usado depois do login, então não há motivo para a API mostrar dados sem ele |
| Validade de 8 horas, sem renovação automática | Cobre um dia de evento. A renovação seria mais complexa e não faz falta neste projeto |
| URLs com `<id_usuario>` mantidas, comparadas com o usuário do token | Trocar por rotas como `/api/eu/agenda` mudaria o app e as telas em desenvolvimento. Comparar o `id` protege do mesmo jeito |
| Cadastro sempre como participante, e organizador criado pelo banco | O cadastro é público. Se aceitasse o tipo enviado, qualquer pessoa viraria organizadora. O evento tem uma equipe organizadora pequena e conhecida de antemão. **Atualizado na F08 (22/10/2026):** cada evento passou a ter um só organizador responsável, e cada organizador gerencia só os próprios eventos; o administrador gerencia todos (seção 1.2). Criar organizadores pelo app é a F22 |
| Atualização de usuário com lista de campos permitidos (`nome`, `email`, `senha`) | Uma lista do que é proibido deixava passar campos como o próprio `id_usuario`. Com a lista de permitidos, uma coluna nova já nasce protegida |
| Só a própria pessoa altera a conta, nem o organizador | Se um organizador pudesse trocar a senha de outra pessoa, poderia entrar na conta dela |
| Remover avaliação permitido também ao organizador; editar, só ao autor | O organizador precisa moderar comentários, mas não deve mudar a nota de outra pessoa |

### 4.3 Limitações conhecidas

- **`SECRET_KEY` padrão:** quem conhece a chave consegue fabricar tokens.
  O `config.py` tem um valor padrão fixo, que está no repositório. Cada
  instalação precisa de uma chave própria no `.env` (P04).
- **O logout não invalida o token:** o app só apaga o token da memória.
  Um token copiado antes continua valendo até vencer, mesmo se a pessoa
  trocar a senha, porque a API não guarda uma lista de tokens.
- **Token vencido:** o app mostra a mensagem "Sessão expirada ou
  inválida", mas não volta sozinho para a tela de login (F17).
- **Login a cada abertura:** o token fica só na memória, então é preciso
  fazer login toda vez que o app é aberto (F17, login lembrado).
- **Dois registros de organizador:** quem é organizador fica em
  `usuario.tipo_usuario`, que a API confere, e na tabela `organizador`.
  Ao criar um organizador pelo banco, os dois precisam ser atualizados
  (README, seção 7). Desde a F08, sem o registro na tabela `organizador`
  a pessoa não cria nem gerencia nenhum evento.

---

## 5. F01: tela de cadastro de usuário (RF01)

Concluída em 21/10/2026. A rota `POST /api/usuarios` já existia, mas não
havia tela: só era possível criar uma conta pelo banco ou pela API.

### 5.1 O que foi feito

- **Tela "Criar conta"** (`frontend/Flutter/lib/pages/cadastro_page.dart`),
  aberta pelo link no login: nome, e-mail, senha e confirmação da senha,
  com o botão de mostrar/ocultar em cada campo de senha. Depois do
  cadastro, o app já faz o login com os mesmos dados e abre o Início.
- **Fundo comum do login e do cadastro** (`lib/widgets/tela_acesso.dart`):
  fundo Céu com a curva do rio e um cartão de vidro fosco, como no canvas.
  O "grão" do vidro é sorteado uma vez só e reaproveitado, para não pesar
  enquanto o teclado abre.
- **Regras do usuário no backend, num lugar só**
  (`backend/services/usuario/validacoes_usuario.py`): `validar_nome`,
  `validar_email` e `validar_senha`, usadas pelo cadastro e pela
  atualização. Nome preenchido (sem contar espaços), e-mail em formato
  válido e senha de 8 a 16 caracteres (`TAMANHO_MINIMO_SENHA` e
  `TAMANHO_MAXIMO_SENHA`, na Model `Usuario`). Um valor que não é texto
  (ex.: número) gera erro 400 com mensagem clara, e não erro 500.
- **App:** `ApiService.cadastrar` envia só nome, e-mail e senha, sem
  `tipo_usuario` (P01).

### 5.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Regras conferidas no backend, e a tela confere de novo | A rota de cadastro é pública: quem chamasse a API direto escaparia de uma regra feita só no app. A tela confere antes só para avisar mais rápido |
| Funções de validação num arquivo próprio dos Services | Antes, a regra da senha estava copiada no cadastro e na atualização. Num lugar só, não há risco de as duas versões ficarem diferentes. Ficam nos Services, e não na Model, porque a Model cuida só de gravar e ler do banco |
| E-mail conferido por expressão regular (formato `algo@algo.algo`) | Simples e sem biblioteca nova. Confirmar que o e-mail existe exigiria enviar um e-mail de confirmação, o que fica fora do prazo |
| Senha de 8 a 16 caracteres | O mínimo de 8 é o recomendado para senhas simples. O máximo de 16 foi decidido pela equipe e também protege o servidor: a rota de cadastro é pública, e gerar o hash de um texto enorme gastaria muito processamento. Uma regra maior (exigir número, símbolo) atrapalharia o cadastro no evento |
| Erro do banco por e-mail repetido vira mensagem clara | Dois cadastros iguais ao mesmo tempo (toque duplo) passam pela conferência, e o banco recusa o segundo. Tratado como no `CriarAvaliacaoService` |
| Links "Criar conta" e "Entrar" desativados durante o envio | Trocar de tela no meio do login ou do cadastro deixava o app logado, mas na tela errada |
| Login automático depois do cadastro | A pessoa não precisa digitar tudo de novo. Se o login falhar, ela volta para a tela de login com o aviso de que a conta foi criada |
| Números 8 e 16 repetidos no Dart (`tamanhoMinimoSenha` e `tamanhoMaximoSenha`) | O app (Dart) não consegue ler uma constante do backend (Python). Um comentário em cada lado aponta para o outro |

### 5.3 Limitações conhecidas

- **E-mail não confirmado:** o formato é conferido, mas não se o e-mail
  existe ou pertence à pessoa.
- **Trocar o e-mail para um que já existe** (pelo `PUT /api/usuarios/<id>`)
  ainda dá erro 500, em vez de uma mensagem clara (P03).
- **Usuários de exemplo com senhas curtas** (`hash123`), abaixo do mínimo
  de 8 caracteres: eram da base de demonstração. Resolvido na P02: agora
  usam a senha `Senha@123`, guardada como hash.

---

## 6. P02: login só com senha guardada como hash

Concluída em 22/10/2026. O cadastro já guardava a senha como hash, mas o
login aceitava também senhas em texto puro, porque os usuários de
exemplo do banco tinham senhas como `hash123` gravadas assim. Quem
tivesse acesso ao banco via as senhas, e a tela de login vinha com o
e-mail e a senha de um usuário de exemplo já preenchidos.

### 6.1 O que foi feito

- **Login** (`backend/services/auth/autenticar_usuario_service.py`): só
  aceita senha guardada como hash do Werkzeug (prefixo `scrypt:` ou
  `pbkdf2:`). Uma senha em texto puro no banco é recusada sem
  comparação. `check_password_hash` calcula o hash do que foi digitado e
  compara com o guardado: o hash não pode ser revertido para a senha
  original.
- **Entrada conferida antes do hash:** e-mail e senha precisam ser texto,
  e a senha deve ter no máximo `TAMANHO_MAXIMO_SENHA` (16) caracteres.
  Fora disso, o login responde 401 ("Email ou senha inválidos."), e não
  erro 500.
- **Usuários de exemplo**
  (`database/sistema_eventos_atualizado.sql`): Ana, Bruno e Carla agora
  usam a senha `Senha@123`, gravada como hash scrypt, cada um com um
  salt próprio.
- **App:** a tela de login (`lib/pages/login_page.dart`) abre com os
  campos vazios.
- **Documentos:** README e `FLUXO_DE_TRABALHO.md` passaram a usar
  `Senha@123` nos exemplos de login.

### 6.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Hash do Werkzeug (scrypt), e não uma biblioteca nova | Já vem instalado com o Flask e é o mesmo que o cadastro usava. O scrypt é lento de propósito, o que dificulta testar muitas senhas por tentativa e erro |
| Salt aleatório em cada hash | O salt é um texto sorteado que entra no cálculo do hash. Com ele, duas pessoas com a mesma senha ficam com hashes diferentes, e uma tabela pronta de hashes de senhas comuns não serve para descobrir a senha |
| Recusar senha em texto puro, em vez de converter no primeiro login | Converter exigiria manter o código que compara texto puro. Os únicos usuários nessa situação eram os de exemplo, resolvidos no script do banco |
| Mesma senha `Senha@123` para os três usuários de exemplo | Atende a regra de 8 a 16 caracteres da F01 e é fácil de lembrar nos testes e na apresentação |
| Limite de tamanho também no login | A rota é pública: calcular o hash de um texto enorme gastaria processamento do servidor. Uma senha maior que 16 nunca seria aceita pelo cadastro |
| Token continua com `itsdangerous`, sem JWT | O token da P01 já funciona e é seguro para o projeto. Trocar por JWT exigiria biblioteca nova sem ganho real agora |

### 6.3 Limitações conhecidas

- **Banco precisa ser recriado:** quem tem o banco antigo continua com as
  senhas de exemplo em texto puro e não consegue entrar com elas. É
  preciso rodar de novo o script de `database/` (passo 1.4 do
  `FLUXO_DE_TRABALHO.md`), o que apaga os dados de teste.
- **É possível descobrir se um e-mail tem conta:** o cadastro responde
  "Já existe um usuário cadastrado com este email.", e o login demora um
  pouco mais quando o e-mail existe (só nesse caso o hash é calculado).
  A equipe decidiu manter a mensagem do cadastro, porque ela ajuda quem
  já tem conta.
- **Sem limite de tentativas de login:** não há bloqueio depois de várias
  senhas erradas.

---

## 7. F08: área do organizador e organizador responsável pelo evento (RF17)

Concluída em 22/10/2026. Antes, o organizador não tinha nenhuma tela no
app, e qualquer organizador podia mexer em qualquer evento. O RF17 pede
que o organizador gerencie as inscrições dos participantes.

### 7.1 O que foi feito

- **Organizador responsável** (`database/sistema_eventos_atualizado.sql`,
  `models/evento.py`): a tabela `evento` ganhou a coluna obrigatória
  `id_organizador`. Quem cria o evento (`POST /api/eventos`) vira o
  responsável, e o responsável não muda por atualização.
- **Dois níveis de acesso** (`models/organizador.py`): o `organizador`
  gerencia só os próprios eventos; o `administrador` gerencia todos. A
  regra fica num lugar só (`Organizador.usuario_pode_gerenciar`).
- **Autorização por dono** (`controllers/autenticacao.py`):
  `verificar_dono_do_evento` e `verificar_dono_da_palestra` são usadas
  nas rotas de evento, palestra e da área do organizador, e na moderação
  de avaliações. `verificar_administrador` protege as funções do sistema
  todo (listar, ver e remover contas de outras pessoas).
- **Rotas novas** (`controllers/organizador_controller.py`):
  `GET /api/organizador/eventos` (meus eventos),
  `GET /api/organizador/eventos/<id>/painel` (números e ranking),
  `GET /api/organizador/palestras/<id>/inscritos` e
  `DELETE /api/organizador/palestras/<id>/inscritos/<id_usuario>`.
- **Remover inscrição** (`services/organizador/remover_inscricao_service.py`):
  reaproveita o `CancelarInscricaoService` do participante (a vaga
  volta) e grava um aviso do tipo `atencao` para a pessoa, na mesma
  transação.
- **Telas** (`lib/pages/organizador_painel_page.dart` e
  `organizador_inscricoes_page.dart`): o painel com palestras,
  inscrições, esgotadas, ocupação das vagas e média das avaliações, o
  ranking das palestras e o seletor "Trocar evento"; a tela de inscrições
  com busca e o botão Remover, com confirmação. A entrada "Área do
  organizador" aparece no Perfil só para organizadores.
- **Sair** (parte da F17): botão no Perfil que apaga o token e volta para
  o login.
- **Campos permitidos:** a atualização de evento e de palestra passou a
  aceitar só uma lista de campos (avanço na P03).

### 7.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Um só organizador por evento | Deixa claro quem responde pelo evento. Uma equipe por evento exigiria uma tabela de ligação a mais e não é pedida pelos RFs |
| Administrador vê tudo, organizador só os próprios eventos | O fluxo previsto é: o administrador cria o organizador (F22) e o organizador cria o evento, que já fica ligado a ele |
| Conferir o dono na API, e não só esconder na tela | Esconder a opção no app não protege nada: qualquer pessoa pode chamar a rota direto. A API responde 403 para quem não é o dono |
| Remover inscrição com o mesmo Service do cancelamento | A regra da vaga fica escrita num lugar só. A diferença é quem escolhe a inscrição: o organizador (pela URL) ou a própria pessoa (pelo token) |
| Remoção e aviso numa transação só | Uma transação é um "tudo ou nada": ou a inscrição sai e o aviso entra, ou nada muda |
| Média geral pela soma das notas, e não pela média das médias | Uma palestra com 1 avaliação pesaria igual a uma com 10. Somando as notas e dividindo pelo total, cada avaliação conta igual |
| `ON DELETE RESTRICT` no responsável e mensagem clara ao remover a conta | Nenhum evento fica sem responsável. O Service avisa antes, em vez de deixar o banco dar erro 500 |
| Sair feito na branch da F08 | Era pequeno e mexia no mesmo `perfil_page.dart`. Em branches separadas, daria conflito no Git |

### 7.3 Limitações conhecidas

- **Organizadores ainda são criados pelo banco:** a tela para o
  administrador criar organizadores é a F22.
- **Sem troca de responsável:** não há rota para passar um evento para
  outro organizador. Para remover a conta de um organizador, é preciso
  remover os eventos dele antes.
- **Capacidade da palestra:** as vagas não podem ser alteradas pela API.
  Mudar a capacidade exige recalcular o saldo e fica para a F14.
- **Palestra movida de evento:** se o `id_evento` mudar sem informar o
  local, a palestra continua com a sala do evento antigo (a corrigir na
  F14).
- **Banco precisa ser recriado:** quem tem o banco antigo não tem a coluna
  `evento.id_organizador`, e o backend novo não funciona com ele (passo
  1.4 do `FLUXO_DE_TRABALHO.md`).

---

## 8. F14: cadastros do organizador com envio de imagens

Concluída em 23/10/2026. Antes, eventos, palestras, locais, palestrantes,
patrocinadores e a planta só podiam ser cadastrados direto no banco ou
por `curl`. Agora o organizador faz tudo pelo app, inclusive enviar a
planta, as fotos e os logos.

### 8.1 O que foi feito

- **Envio de imagens em duas etapas**
  (`services/upload/salvar_imagem_service.py`,
  `controllers/upload_controller.py`): o app manda a imagem para
  `POST /api/uploads` e recebe o nome com que ela foi salva; depois manda
  esse nome no cadastro (`foto`, `logo`, `imagem_mapa`), como um texto
  comum. `GET /uploads/<nome>` devolve a imagem para o app mostrar.
- **Conferência do arquivo:** o tipo é descoberto pelos primeiros bytes
  do arquivo (PNG, JPG ou WEBP), e não pela extensão do nome; o arquivo
  ganha um nome aleatório (`uuid4`); o limite é de 5 MB
  (`MAX_CONTENT_LENGTH`, com resposta 413 em JSON). Nos cadastros,
  `validar_nome_imagem` só aceita um nome no formato gerado pela API e de
  um arquivo que exista na pasta `backend/uploads/`.
- **Planta** (`controllers/planta_controller.py`):
  `GET` e `PUT /api/eventos/<id>/planta`. O `PUT` cria a planta na
  primeira vez e depois só muda os campos enviados.
- **Locais, palestrantes e patrocinadores:** rotas de criar, editar e
  remover (`/api/locais`, `/api/palestrantes`, `/api/patrocinadores`),
  cada uma conferindo se quem pede é dono do evento do registro
  (`verificar_dono_pelo_evento`, em `controllers/autenticacao.py`).
  A lista de palestrantes aceita `?id_evento=` e `&busca=` (pelo nome).
- **Palestrante ligado ao evento** (`database/sistema_eventos_atualizado.sql`,
  `models/palestrante.py`): a tabela `palestrante` ganhou `id_evento`. A
  palestra só aceita local e palestrante do mesmo evento dela.
- **Vagas editáveis** (`services/palestra/atualizar_palestra_service.py`):
  ao mudar `vagas_total`, as vagas livres são recalculadas pela
  contagem de inscrições. O total não pode ficar abaixo do número de
  inscritos.
- **Excluir evento com senha** (`services/evento/remover_evento_service.py`):
  o `DELETE /api/eventos/<id>` pede a senha de quem está logado (dono do
  evento ou administrador).
- **Tamanho dos textos** (`services/validacoes_cadastro.py`): nomes,
  links e descrições são conferidos antes de ir para o banco, com
  mensagem clara em vez de erro 500.
- **Telas** (`lib/pages/organizador_*_page.dart`): evento e planta,
  locais, palestrantes, palestras e patrocinadores, abertas pelo menu do
  painel. Os widgets `FormularioOrganizador`, `CampoImagem` e
  `ListaCadastro` são usados por todas. O campo de imagem mostra os tipos
  aceitos (`PNG, JPG OU WEBP · ATÉ 5 MB`). A tela de patrocinadores dos
  participantes (F10) passou a mostrar o logo.

### 8.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Envio da imagem separado do cadastro | O cadastro continua sendo um JSON simples, e a mesma rota de envio serve para planta, foto e logo. A alternativa (mandar a imagem junto, em `multipart`) obrigaria a mudar todas as rotas de cadastro |
| Tipo do arquivo pelos primeiros bytes | O nome e o tipo informados pelo navegador podem ser trocados por quem envia. Os primeiros bytes de cada formato de imagem são fixos e mostram o que o arquivo realmente é |
| Nome aleatório para o arquivo salvo | Evita que um nome enviado como `../app.py` saia da pasta de imagens e que dois arquivos com o mesmo nome se sobrescrevam |
| Rota de exibição pública | As imagens aparecem para todos os participantes, e o `Image.network` do Flutter não manda o token. O nome aleatório não pode ser adivinhado |
| Palestrante cadastrado por evento | O organizador cadastra a pessoa uma vez no evento e a indica nas palestras. Em eventos diferentes, a mesma pessoa tem um cadastro em cada um, e um organizador não mexe no palestrante do outro |
| Senha para excluir o evento | Excluir apaga em cascata palestras, inscrições e avaliações. Pedir a senha evita uma exclusão por engano ou feita por quem pegou o celular desbloqueado |
| Vagas livres recalculadas pela contagem de inscrições | Fazer uma conta com o saldo antigo poderia acumular erros. Contar as inscrições sempre dá o número certo, e a linha da palestra fica travada (`with_for_update`) enquanto a conta é feita |
| Locais e palestrantes antes das palestras no menu | A palestra só escolhe entre o que já existe; cadastrar nessa ordem evita voltar telas |

### 8.3 Limitações conhecidas

- **Imagens sem uso ficam no servidor:** trocar ou remover uma imagem
  não apaga o arquivo antigo da pasta `backend/uploads/` (melhoria
  futura).
- **Imagens fora do Git:** a pasta `backend/uploads/` é ignorada pelo
  Git; cada computador tem só as imagens enviadas nele.
- **Palestrante sem login:** o palestrante não tem área própria no app
  (registrado como F23).
- **Banco precisa ser recriado:** quem tem o banco antigo não tem a coluna
  `palestrante.id_evento` (passo 1.4 do `FLUXO_DE_TRABALHO.md`).
- Os dois itens da seção 7.3 sobre a palestra (capacidade e palestra
  movida de evento) foram resolvidos nesta tarefa.

## 9. F24: dados de demonstração com eventos encerrado, acontecendo e futuro (S05)

Concluída em 23/10/2026. Os dois eventos de exemplo tinham datas fixas
que já tinham passado: o Início mostrava um evento antigo, a "próxima
palestra" ficava vazia e havia só 2 palestras, o que não mostrava bem o
controle de vagas, a busca e a agenda. Agora o banco sempre tem um
evento em cada situação e um exemplo de cada estado que o app mostra.

### 9.1 O que foi feito

- **Datas relativas** (`database/sistema_eventos_atualizado.sql`): as
  datas são calculadas a partir do dia em que o script roda. `@hoje`
  guarda `CURDATE()`, e cada data é escrita como `@hoje - INTERVAL 1 DAY`
  (ontem) ou `TIMESTAMP(@hoje + INTERVAL 1 DAY, '09:00')` (amanhã às
  09:00). A palestra "acontecendo agora" usa `@hora_cheia` (a hora cheia
  atual): começa uma hora antes e termina três horas depois.
- **Três eventos:** Semana de Tecnologia (de ontem até amanhã,
  acontecendo), Feira de Ciências (daqui a 14 dias, futuro) e Mostra de
  Projetos (há 30 dias, encerrado). A Mostra entrou por último para os
  ids 1 e 2 continuarem os mesmos dos exemplos do README.
- **10 palestras**, cada uma com uma situação: já aconteceu, acontecendo
  agora, esgotada (1 vaga), última vaga (2 vagas, 1 ocupada), com vagas
  e sem avaliações, e uma sem palestrante. Os temas são variados para a
  busca.
- **Avaliações:** uma palestra com média de duas notas, e uma em que a
  Ana está inscrita e ainda não avaliou, para mostrar a tela Avaliar e a
  média mudando.
- **Avisos:** um de cada tipo (comunicado do evento, comunicado de uma
  palestra, inscrição removida pela organização e lembrete), com as
  mesmas mensagens que a API grava.
- **README:** a seção "Dados de demonstração (S05)" explica os três
  eventos e o que testar com cada usuário.

### 9.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Datas relativas, e não fixas | Com datas fixas, os dados envelhecem: o problema que motivou a tarefa voltaria na apresentação final. A alternativa de gerar os dados com um script em Python foi descartada, porque o próprio SQL resolve |
| Um evento em cada situação | Cada tela que depende da data (Início, Avaliar, aviso de início da F02 e, depois, a F16) tem o que mostrar |
| A palestrante Carla não se inscreve nem avalia a própria palestra | A usuária Carla Souza é a mesma pessoa da palestrante (decisão da F05). Avaliar a própria palestra iria contra a regra de negócio |
| Avisos de exemplo gravados com `UTC_TIMESTAMP()` | A aba Avisos lê `data_envio` em UTC, como os avisos criados pela API (contorno da P06). Na hora local, eles apareceriam 3 horas atrasados |
| Fotos, logos e planta fora do script | São arquivos enviados pelo app (F14), guardados em `backend/uploads/`, que fica fora do Git |

### 9.3 Limitações conhecidas

- **Janela da palestra "acontecendo agora":** ela só está acontecendo
  por 2 a 3 horas depois de o script rodar (e cai em outro dia perto da
  meia-noite). No dia da apresentação, o banco deve ser recriado pouco
  antes.
- **Fuso do MySQL:** `CURDATE()` e `NOW()` usam o fuso do MySQL, que
  precisa ser o mesmo do computador do backend (o padrão de uma
  instalação local).
- **Datas de avaliações e favoritos de exemplo** ficam na hora local, e
  as criadas pela API ficam em UTC. Nenhuma tela mostra essas datas
  hoje; a correção é a P06.
- **Banco precisa ser recriado:** quem tem o banco antigo continua com
  os dados velhos (passo 1.4 do `FLUXO_DE_TRABALHO.md`).

---

## 10. F05: palestrantes, busca por nome e perfil (RF13, RF14)

Concluída em 23/10/2026. O relatório pede que o participante pesquise
palestrantes pelo nome (RF13) e veja as informações de cada um (RF14).
A F14 já tinha feito a parte do backend (rotas de palestrantes por
evento, com busca) e o perfil aberto pelos detalhes da palestra; faltava
uma tela onde o participante encontrasse os palestrantes sem precisar
abrir uma palestra antes.

### 10.1 O que foi feito

- **Tela "Palestrantes"** (`pages/palestrantes_page.dart`), aberta pelo
  atalho "Palestrantes" do Início, que antes aparecia como "Em breve".
  Mostra os palestrantes do evento (foto ou iniciais, nome e o começo da
  descrição) e um campo "Pesquisar pelo nome".
- **Busca na API:** a cada letra digitada, o app chama
  `GET /api/palestrantes?id_evento=<id>&busca=<texto>`.
- **Perfil reaproveitado:** tocar num palestrante abre o mesmo perfil
  dos detalhes da palestra (`abrirPerfilPalestrante`, RF14), e tocar
  numa palestra do perfil abre os detalhes dela.

### 10.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Busca feita pela API, e não filtrando a lista no próprio app | A rota com `busca` já existia (F14) e é o lugar da regra; filtrar no app repetiria a regra em dois lugares |
| A busca roda a cada letra, sem botão | Com poucos palestrantes por evento, a resposta é rápida. O `FutureBuilder` mostra só o resultado da busca mais recente: uma resposta antiga que chegue atrasada é ignorada |
| A lista anterior continua na tela enquanto a nova busca carrega | Sem isso, o círculo de carregando piscaria a cada letra (`snapshot.hasData` durante a espera) |
| Entrada pelo atalho do Início | O canvas já previa o atalho "Palestrantes" no Início; a barra de navegação tem só 5 abas |

### 10.3 Limitações conhecidas

- **Uma requisição por letra:** para eventos com muitos palestrantes,
  valeria esperar a pessoa parar de digitar antes de buscar (técnica
  chamada *debounce*).
- **Rede social só para copiar:** o link aparece como texto selecionável;
  abrir o navegador exigiria o pacote `url_launcher` (depois da P17).

---

## 11. F02: aviso de início das palestras no celular (RF09)

Concluída em 23/10/2026. O RF09 pede que o participante seja avisado do
início das palestras. Antes, o botão "Ativar lembrete" só gravava um
registro na tabela `notificacao`, que aparecia na aba Avisos: nada
avisava a pessoa na hora.

### 11.1 O que foi feito

- **Notificação local** (`lib/services/lembrete_service.dart`, pacotes
  `flutter_local_notifications` e `timezone`): ao ativar o lembrete, o
  app grava no backend (como antes) e agenda no próprio celular um aviso
  10 minutos antes do início: "Começa em 10 minutos · Sala A1". O aviso
  aparece na barra do celular mesmo com o app fechado.
- **Menos de 10 minutos:** o aviso aparece na hora, com o tempo que
  falta ("Começa em 4 minutos"). Palestra já começada não recebe aviso,
  e o sino some dos detalhes.
- **Cancelamento:** desativar o lembrete cancela o aviso. Cancelar a
  inscrição desliga o lembrete no backend e cancela o aviso.
- **Horário alterado:** ao entrar no app, os avisos são apagados e
  refeitos a partir dos lembretes do backend (`sincronizar`), então uma
  mudança de horário feita pelo organizador também muda o aviso.
- **Toque no aviso:** abre os detalhes da palestra. Com o app fechado, os
  detalhes abrem logo depois do login.
- **Android:** permissão de notificação (o Android 13 ou mais novo
  pergunta uma vez), recebedores do pacote no `AndroidManifest.xml` (que
  também refazem os avisos depois de reiniciar o celular) e o
  *desugaring* no `build.gradle.kts`, exigido pelo pacote.
- **README:** como rodar num celular Android pelo cabo USB.

### 11.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Notificação local, e não push (Firebase Cloud Messaging) | Push exigiria conta no Firebase, guardar o identificador de cada celular e uma tarefa agendada no servidor. Como o horário da palestra já é conhecido, o próprio celular consegue decidir quando avisar (decisão de 20/10/2026) |
| Agendamento "aproximado" (`inexactAllowWhileIdle`) | O agendamento exato exige a permissão `SCHEDULE_EXACT_ALARM`, que o Android 14 nega por padrão para apps comuns. Para "começa em 10 minutos", 1 ou 2 minutos de atraso não atrapalham |
| Refazer todos os avisos ao entrar no app | Mais simples do que comparar horário por horário: apaga tudo e agenda de novo a partir do backend, que é a fonte da verdade |
| Cancelar a inscrição também desliga o lembrete | Sem inscrição, o aviso não faz sentido. Desligar no backend evita que o aviso volte na próxima sincronização |
| Horário convertido pelo instante (`TZDateTime.from(..., tz.UTC)`) | O app lê o horário no fuso do celular; converter pelo instante mantém o mesmo momento sem depender de configurar o fuso no pacote `timezone` |
| Teste num celular pelo cabo USB, com `adb reverse tcp:5000 tcp:5000` | O emulador não abriu (a virtualização está desligada na BIOS do computador). O `adb reverse` faz o `127.0.0.1:5000` do celular chegar à API do computador, sem mudar o endereço no app |

### 11.3 Limitações conhecidas

- **Só no Android:** no Chrome, o lembrete é gravado e aparece em Avisos,
  mas não há notificação. No iPhone, faltaria configurar o projeto iOS
  (e testar num Mac).
- **Sincronização só ao entrar no app:** se o organizador mudar o
  horário e a pessoa não abrir o app, o aviso sai no horário antigo. A
  F15 (aviso de alteração de palestra) completa esse caso.
- **Celular pelo cabo:** sem o cabo (e sem o `adb reverse`), o app no
  celular não alcança a API local. Na rede Wi-Fi, é preciso usar o IP do
  computador (`--dart-define=API_URL=...`).
- **Pacotes novos mudaram o `pubspec.lock`:** quem puxar a `main` roda
  `flutter pub get`. As versões das outras dependências também mudaram,
  pela diferença de versão do Flutter entre as máquinas (P17).

## 12. F20 parte 2: telas restantes no visual do canvas, fundo céu suave e eventos, lugares e salas

Concluída em 23/10/2026, em duas branches: `f20-telas-restantes` (PR #21:
abertura, favoritos, programação e agenda) e `f20-ceu-e-eventos` (o
restante). A parte 1 (seção 3) criou a base visual; a parte 2 refaz o
layout das telas antigas, uma por commit, seguindo a página "Telas do
projeto · opção 1 refinada" do canvas.

### 12.1 O que foi feito

- **Fundo céu suave:** a Manuela comparou no canvas três opções de fundo
  (céu puro, céu suave e papel com topo céu) e escolheu o céu suave
  (`#E3F3FF`) para o app todo. A troca foi feita só em
  `lib/theme/app_theme.dart` (fundo, linhas, bordas, texto secundário,
  blocos de apoio e estrelas): nenhuma tela usa cor fixa, então todas
  mudaram juntas. O modo escuro não mudou.
- **Abertura, Favoritos, Programação e Agenda** (PR #21): a abertura com
  o rio de espessura fixa; a Programação com todos os dias do evento,
  filtros e selos de situação (`ENCERRADA`, `EM ANDAMENTO`, `INSCRITA`,
  `ESGOTADA`); a Agenda como linha do tempo de um dia por vez, com a
  palestra atual ou a próxima em destaque e as pausas entre as palestras.
- **Avisos:** o cabeçalho das abas, com a hora da última atualização.
- **Detalhes da palestra:** topo Céu com o rio, o selo do tema e o título
  grande; o picote (linha tracejada, `lib/widgets/picote.dart`) acima da
  barra de ações; o "Como chegar" recolhido. Depois que a palestra
  começa, o cartão de vagas e o lembrete somem, e a barra fica só com
  favoritar e Avaliar (para quem estava inscrito).
- **Localização** (antes "Planta do local"): o nome do lugar do evento,
  quantas salas ele tem, a planta com zoom e as salas com o caminho e
  quantas palestras cada uma recebe.
- **Escolher evento** (tela nova) e o cartão "Você está no evento" no
  Início, no lugar da lista "Trocar evento". O card do evento mostra
  quantas palestras e salas o evento tem.
- **Perfil:** e-mail, número de inscrições e favoritas, **Editar perfil**
  (tela nova, troca nome e e-mail), Certificados como "Em breve" e Sair
  na cor de atenção.
- **Início:** o card "Próxima na agenda" como um ingresso, com o picote e
  os recortes em meia-lua.

### 12.2 Decisões e motivos

| Decisão | Motivo |
|---|---|
| Atualizar a própria página refinada do canvas com o céu suave e as telas novas, em vez de adotar outra página | O `CLAUDE.md` define a página refinada como a fonte oficial do visual. Atualizá-la mantém a regra e evita duas referências diferentes |
| Céu suave no app todo, e não só nas três telas desenhadas | Com duas paletas misturadas, o app pareceria inacabado. Pelo tema, a troca é feita em um lugar só |
| Um evento acontece em um **lugar**, que tem **salas** (proposta "eventos, lugares e salas") | Separa o que o participante confundia: trocar de evento (outro encontro), a planta (o mapa do lugar) e a sala (onde fica a palestra) |
| Tela e atalho chamados "Localização" | Pedido da Manuela: o nome descreve melhor a tela, que vai além da imagem da planta |
| "Como chegar" recolhido por padrão | Deixa a tela dos Detalhes mais curta para quem não precisa do caminho |
| Palestra já começada: sem vagas, sem lembrete e sem inscrição | Ninguém entra nem sai de uma palestra em andamento (regra da F16, bloqueada também no backend). O favoritar continua para quem favoritou, para poder desfavoritar |
| Contagem de palestras e salas feita no app, com a programação | Não precisa mudar o backend agora. Com muitos eventos, o certo é a API mandar os totais (F25) |
| Editar perfil só com nome e e-mail | A rota já é protegida (só a própria pessoa e só esses campos, desde a P01). E-mail repetido, troca de senha e foto ficaram na F26, que passa pelo `/security-review` |
| Rótulo dos Avisos com a hora da última busca, e não "N novos" | O banco ainda não guarda se o aviso foi lido (F21). Mostrar um número sem base confundiria |
| Picote como componente compartilhado | É usado nos Detalhes (deitado) e no Início (em pé). O Flutter não tem borda tracejada pronta, então a linha é desenhada com um `CustomPainter` |

### 12.3 Limitações conhecidas

- **Avisos novos:** o "N NOVOS" do canvas e o contador da barra esperam a
  F21.
- **Contagem por requisição:** Escolher evento busca a programação de
  cada evento só para contar as palestras, e a Localização busca a lista
  de eventos para achar o lugar (F25).
- **Editar perfil:** e-mail que já é de outra conta volta como erro
  genérico (500), e não há troca de senha nem foto (F26).
- **"Lembrete ativo" no Início** e **"Começa em 10 min" nos Avisos**, que
  aparecem no canvas, ficaram como próximos passos.
- **Certificados** aparecem como "Em breve" até a F12.
