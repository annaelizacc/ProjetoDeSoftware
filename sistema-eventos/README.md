# Fluxo Eventos

Aplicativo acadêmico de gerenciamento de eventos, feito com **Flutter** no
frontend, **Flask + SQLAlchemy** no backend e **MySQL** no banco de dados.

O projeto foi montado a partir dos dois materiais enviados: o visual e as
regras de inscrição/favoritos do primeiro projeto foram aproveitados; a
estrutura de Models e Repositories compatível com o banco oficial veio do
segundo projeto. O SQL final preserva as tabelas e os dados do banco oficial.

## 1. Funcionalidades implementadas

1. Visualizar a programação geral do evento.
2. Visualizar detalhes de uma palestra.
3. Inscrever-se em uma palestra com controle automático de vagas.
4. Cancelar inscrição e devolver a vaga.
5. Favoritar uma palestra.
6. Visualizar agenda personalizada com as palestras inscritas.
7. Visualizar notificações relacionadas às palestras.
8. Pesquisar palestras por tema pela API.
9. Visualizar e gerenciar os favoritos.
10. Ativar e desativar lembretes de palestras.
11. Alternar entre modo claro e modo escuro (Perfil → Modo escuro); a
    escolha fica salva no celular.
12. Criar uma conta pelo app (Login → "Criar conta"): nome, e-mail e
    senha de 8 a 16 caracteres. Depois do cadastro, a pessoa já
    entra no app.
13. Avaliar uma palestra com 1 a 5 estrelas e um comentário opcional
    (Detalhes → "Avaliar"), além de editar ou excluir a própria
    avaliação. Só quem está inscrito pode avaliar, e só depois que a
    palestra começa. A média aparece nos cards da Programação e nos
    Detalhes, com a lista de comentários.

Todas as funcionalidades principais percorrem:

```text
Flutter
  -> API Flask
  -> Controller (classe)
  -> Service
  -> Model ou Repository
  -> MySQL
  -> JSON para o Flutter
```

## 2. Pré-requisitos

- MySQL ou MariaDB;
- Python 3.10 ou mais recente;
- Flutter 3 ou mais recente;
- Android Studio, Chrome ou outro dispositivo Flutter.

## 3. Criar o banco oficial

Abra o MySQL Workbench, DBeaver ou o terminal e execute:

```text
database/sistema_eventos_atualizado.sql
```

O script cria o banco `sistema_eventos` com dados fictícios para
demonstração. Em relação ao banco oficial, ele:

- adiciona `vagas_total` e `vagas_disponiveis` em `palestra`;
- cria `favorito` com chave única para impedir duplicidade;
- segue o diagrama do relatório em `palestrante`, `avaliacao` (estrelas de
  1 a 5 e comentário opcional, no lugar da antiga `comentario`),
  `patrocinador` e `certificado`, e liga cada palestra ao seu local
  (`palestra.id_localizacao`, no lugar do texto `sala`);
- deixa `usuario` preparado para o login com Google (`senha` opcional e
  `google_id`), ainda não implementado.

Ao criar ou alterar uma palestra pela API, o local é informado por
`id_localizacao` (e o palestrante por `id_palestrante`). O campo `sala`
não é mais aceito na entrada, mas continua nas respostas, com o nome do
local, para o app não precisar mudar.

**Atenção:** o script começa com `DROP DATABASE`, ou seja, apaga e recria o
banco inteiro. Quem já tinha o banco criado por uma versão anterior precisa
rodá-lo de novo, sabendo que os dados locais serão perdidos.

A tabela oficial `notificacao` já tinha `id_palestra` e `tipo_notificacao`.
Por isso ela também armazena os lembretes, sem criar uma tabela adicional.

Os dados de teste do banco são (a senha é a mesma para os três):

```text
Participante: ana.silva@email.com   / Senha@123
Participante: carla.souza@email.com / Senha@123
Organizador:  bruno.costa@email.com / Senha@123
```

O banco guarda só o hash das senhas, nunca o texto puro. O login recusa
qualquer senha que não esteja guardada como hash.

## 4. Configurar e executar o backend

Passo a passo detalhado, com a instalação do MySQL e do Flutter, a
explicação de cada comando e os erros mais comuns:
`docs/FLUXO_DE_TRABALHO.md`, seções "0. Preparar o computador" e "Rodar o
sistema no dia a dia".

No terminal, a partir da raiz do repositório (`ProjetoDeSoftware/`):

```bash
cd sistema-eventos
python3 -m venv .venv
```

No Windows, o comando é `python -m venv .venv`.

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows:

```bash
.venv\Scripts\activate
```

Instale as dependências:

```bash
pip install -r backend/requirements.txt
```

Crie `backend/.env` a partir de `backend/.env.example` e ajuste a senha do
MySQL. No Ubuntu, o `root` do MySQL não aceita login com senha: crie um
usuário próprio para o projeto (ver o passo 0.2 do fluxo de trabalho).
Depois execute:

```bash
python -m backend.app
```

A API ficará disponível em:

```text
http://127.0.0.1:5000
```

Teste rápido:

```bash
curl http://127.0.0.1:5000/api/health
```

Resposta esperada:

```json
{"status": "ok"}
```

## 5. Executar o Flutter

Em outro terminal, também a partir da raiz do repositório:

```bash
cd sistema-eventos/frontend/Flutter
flutter pub get
flutter run
```

### URL da API por dispositivo

O endereço padrão é `http://127.0.0.1:5000`.

Para Android Emulator, use:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:5000
```

Para um celular físico, use o IP do computador na rede local:

```bash
flutter run --dart-define=API_URL=http://192.168.0.10:5000
```

O endereço fica em `lib/services/api_service.dart` e pode ser configurado
sem alterar as telas.

### Navegação e visual

A primeira tela é o login. Quem ainda não tem conta toca em **Criar
conta**, preenche o cadastro e entra direto no app.

Depois do login, a barra de baixo tem cinco abas: **Início**,
**Programação** (do primeiro evento cadastrado), **Agenda**, **Avisos** e
**Perfil**. Os **Favoritos** ficam dentro do Perfil, junto com o
interruptor de **Modo escuro**. A escolha do tema é salva no próprio
aparelho com o pacote `shared_preferences` (não vai para o banco).

O visual segue a identidade do projeto (ver `CLAUDE.md`, na raiz do
repositório):

- cores, fontes e tema claro/escuro: `lib/theme/app_theme.dart`. As
  telas pegam as cores só pelo `Theme.of(context)`, nunca cores fixas,
  então todas acompanham o modo escuro;
- controle do tema (ler e salvar a escolha): `lib/theme/controle_tema.dart`;
- componentes usados em mais de uma tela: `lib/widgets/` (barra de
  navegação, marca-texto, rótulo de seção, selo, cabeçalho e o fundo das
  telas de login e cadastro);
- fontes (Bricolage Grotesque, Figtree e JetBrains Mono): arquivos em
  `assets/fonts/`, já incluídos no app, então não precisam de internet.

## 6. Explicação da arquitetura

### Controllers

Os Controllers estão em `backend/controllers/` e são classes. Eles:

1. recebem a requisição HTTP;
2. leem parâmetros e JSON;
3. chamam o Service;
4. transformam o resultado em JSON;
5. retornam o status HTTP.

Eles não controlam vagas nem fazem consultas complexas diretamente.

### Services

Os Services estão em `backend/services/` e contêm as regras:

- `AuthService`: procura o usuário e valida a senha;
- `EventoService`: lista eventos, programação e agenda;
- `PalestraService`: detalha e pesquisa palestras;
- `InscricaoService`: valida usuário, duplicidade, vagas e cancelamento;
- `FavoritoService`: valida e gerencia favoritos;
- `NotificacaoService`: ativa, desativa e lista lembretes.

### Models

Os Models representam as tabelas oficiais. Os nomes usam `id_usuario`,
`id_evento` e `id_palestra` para manter compatibilidade com o SQL fornecido.

### Repositories

Repositories só foram usados quando a consulta deixa de ser um CRUD simples:

- busca de palestras com filtros;
- agenda baseada em `participacao`;
- favoritos com a palestra relacionada;
- lembretes filtrados por usuário e palestra;
- avaliações de uma palestra com o nome de quem avaliou.

### Controle de vagas

O Flutter nunca decide se há vaga. Ao receber uma inscrição, o Service:

1. trava a palestra durante a transação;
2. confirma que usuário e palestra existem;
3. verifica inscrição duplicada;
4. verifica `vagas_disponiveis`;
5. cria `participacao`;
6. decrementa a vaga;
7. confirma a transação.

No cancelamento, a participação é removida e a vaga é devolvida até o limite
de `vagas_total`.

### Favoritos

O banco possui uma restrição única para `(id_usuario, id_palestra)`. Assim,
mesmo que dois pedidos cheguem ao backend, o banco não permite duplicação.

### Lembretes e notificações

Ativar lembrete cria um registro em `notificacao` com
`tipo_notificacao = 'lembrete'`. Desativar remove esse registro. Ao abrir
Avisos, o Flutter consulta a API; portanto o conteúdo não é uma lista fixa
dentro do aplicativo.

## 7. Rotas principais

### Autenticação (token)

Quase todas as rotas exigem login. No login, a API devolve um **token**:
um texto assinado com a `SECRET_KEY` que identifica o usuário. O app
guarda o token na memória e o envia em toda requisição, no cabeçalho
`Authorization: Bearer <token>`. É por ele, e nunca por um `id_usuario`
enviado no corpo ou na URL, que a API sabe quem fez o pedido.

- O token vale **8 horas**. Depois disso, ou ao fechar o app, é preciso
  fazer login de novo.
- Sem token, ou com token inválido ou vencido, a API responde **401**.
- Logado, mas sem permissão (ex.: participante tentando criar palestra,
  ou ver a agenda de outra pessoa), a API responde **403**.
- Todo cadastro cria um **participante**. Organizadores são criados
  direto no banco. A API confere a coluna `usuario.tipo_usuario`, e a
  tabela `organizador` guarda o nível de acesso. Os dois precisam ficar
  iguais:

  ```sql
  UPDATE usuario SET tipo_usuario = 'organizador' WHERE email = 'email@da.pessoa';
  INSERT INTO organizador (id_usuario, nivel_acesso)
  SELECT id_usuario, 'administrador' FROM usuario WHERE email = 'email@da.pessoa';
  ```

Testando com `curl`:

```bash
# 1. Login: copie o valor de "token" da resposta
curl -X POST http://127.0.0.1:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ana.silva@email.com","senha":"Senha@123"}'

# 2. Use o token nas outras rotas
curl http://127.0.0.1:5000/api/palestras -H "Authorization: Bearer <TOKEN>"
```

### Rotas

Acesso: **pública** (sem token), **login** (qualquer usuário logado),
**própria** (só a pessoa dona do `id` da URL), **organizador**.

| Método | Rota | Uso | Acesso |
|---|---|---|---|
| POST | `/api/auth/login` | Login (devolve o token) | pública |
| GET | `/api/auth/me` | Dados do usuário do token | login |
| POST | `/api/auth/logout` | Logout (o app apaga o token) | pública |
| POST | `/api/usuarios` | Cadastro (sempre como participante; nome preenchido, e-mail em formato válido e senha de 8 a 16 caracteres) | pública |
| GET | `/api/usuarios` | Lista usuários | organizador |
| GET, DELETE | `/api/usuarios/<id>` | Ver ou remover conta | própria ou organizador |
| PUT/PATCH | `/api/usuarios/<id>` | Alterar `nome`, `email` ou `senha` (outros campos são ignorados; mesmas regras do cadastro) | própria |
| GET | `/api/eventos` | Lista eventos | login |
| GET | `/api/eventos/<id>` | Detalhes do evento | login |
| POST | `/api/eventos` | Cria evento | organizador |
| PUT/PATCH, DELETE | `/api/eventos/<id>` | Altera ou remove evento | organizador |
| GET | `/api/eventos/<id>/programacao` | Programação do evento | login |
| GET | `/api/eventos/<id_usuario>/agenda` | Agenda personalizada | própria |
| GET | `/api/palestras?id_evento=&tema=` | Lista e pesquisa, com `media_estrelas` e `total_avaliacoes` | login |
| GET | `/api/palestras/<id>` | Detalhes, média das avaliações e status do usuário do token (`inscrito`, `favorita`, `lembrete_ativo`, `minha_avaliacao`, `pode_avaliar`) | login |
| POST | `/api/palestras` | Cria palestra | organizador |
| PUT/PATCH, DELETE | `/api/palestras/<id>` | Altera ou remove palestra | organizador |
| POST | `/api/inscricoes` | Inscrever (corpo: `id_palestra`) | login |
| DELETE | `/api/inscricoes` | Cancelar inscrição (corpo: `id_palestra`) | login |
| GET | `/api/favoritos/usuario/<id_usuario>` | Meus favoritos | própria |
| POST | `/api/favoritos` | Adicionar favorito (corpo: `id_palestra`) | login |
| DELETE | `/api/favoritos` | Remover favorito (corpo: `id_palestra`) | login |
| GET | `/api/notificacoes/usuario/<id_usuario>` | Avisos | própria |
| POST | `/api/lembretes` | Ativar lembrete (corpo: `id_palestra`) | login |
| DELETE | `/api/lembretes` | Desativar lembrete (corpo: `id_palestra`) | login |
| GET | `/api/avaliacoes/palestra/<id>` | Avaliações de uma palestra | login |
| POST | `/api/avaliacoes` | Avaliar palestra (1 a 5 estrelas e comentário opcional; só inscritos, depois do início da palestra) | login |
| PUT/PATCH | `/api/avaliacoes/<id>` | Alterar nota ou comentário | só o autor |
| DELETE | `/api/avaliacoes/<id>` | Remover avaliação | autor ou organizador |

Nas rotas de inscrição, favorito, lembrete e avaliação, o usuário é
sempre o do token: um `id_usuario` enviado no corpo é ignorado.

## 8. Fluxos para demonstrar ao professor

### Fluxo 1 — programação

```text
Login -> Início -> evento -> programação -> detalhes da palestra
```

### Fluxo 2 — inscrição

```text
Detalhes -> Inscrever-se -> InscricaoService -> participacao + vaga
```

### Fluxo 3 — cancelamento

```text
Detalhes -> Cancelar inscrição -> remove participacao -> devolve vaga
```

### Fluxo 4 — favorito

```text
Detalhes -> Favoritar -> tabela favorito -> Perfil -> Favoritos
```

### Fluxo 5 — agenda

```text
Inscrições do usuário -> consulta participacao -> palestras ordenadas
```

### Fluxo 6 — lembrete

```text
Detalhes -> Ativar lembrete -> notificacao -> aba Avisos
```

### Fluxo 7 — pesquisa

```text
Pesquisa de tema -> GET /api/palestras?tema=Tecnologia -> MySQL -> resultados
```

### Fluxo 8 — cadastro

```text
Login -> Criar conta -> POST /api/usuarios -> POST /api/auth/login -> Início
```

### Fluxo 9 — avaliação

```text
Detalhes (inscrito, palestra já começou) -> Avaliar -> POST /api/avaliacoes
  -> média nos Detalhes e na Programação
```

Para testar com os dados de exemplo, a palestra precisa já ter começado
(`horario_inicio` no passado) e a pessoa precisa estar inscrita nela.

## 9. Tratamento de erros

O backend retorna mensagens simples para:

- usuário ou palestra inexistente;
- inscrição duplicada;
- palestra lotada;
- inscrição inexistente;
- favorito duplicado ou inexistente;
- lembrete duplicado ou inexistente;
- servidor indisponível;
- requisição sem login ou com login vencido (401);
- usuário sem permissão para a ação (403).

O Flutter apresenta essas mensagens com `SnackBar` ou texto de estado da tela.

## 10. Checklist final de arquitetura

- [x] Frontend Flutter separado do backend.
- [x] Controllers implementados como classes.
- [x] Services concentram as regras de negócio.
- [x] Models compatíveis com o banco oficial.
- [x] Repositories usados para consultas específicas.
- [x] SQL oficial preservado e atualizado minimamente.
- [x] API configurável por `--dart-define`.
- [x] Dados reais vindos da API, sem listas fixas nas telas principais.
- [x] README com instalação, execução, rotas e fluxos.