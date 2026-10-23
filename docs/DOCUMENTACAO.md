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
