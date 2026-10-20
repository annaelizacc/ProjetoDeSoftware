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

Os dados de teste do banco são:

```text
Email: ana.silva@email.com
Senha: hash123
```

O backend aceita esse formato legado para facilitar a demonstração. Usuários
novos cadastrados devem usar senha protegida por hash.

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

| Método | Rota | Uso |
|---|---|---|
| POST | `/api/auth/login` | Login |
| GET | `/api/eventos` | Lista eventos |
| GET | `/api/eventos/<id>/programacao` | Programação do evento |
| GET | `/api/palestras?id_evento=&tema=` | Lista e pesquisa |
| GET | `/api/palestras/<id>?id_usuario=` | Detalhes e status |
| POST | `/api/inscricoes` | Inscrever |
| DELETE | `/api/inscricoes` | Cancelar inscrição |
| GET | `/api/eventos/<usuario_id>/agenda` | Agenda personalizada |
| GET | `/api/favoritos/usuario/<id>` | Meus favoritos |
| POST | `/api/favoritos` | Adicionar favorito |
| DELETE | `/api/favoritos` | Remover favorito |
| GET | `/api/notificacoes/usuario/<id>` | Avisos |
| POST | `/api/lembretes` | Ativar lembrete |
| DELETE | `/api/lembretes` | Desativar lembrete |
| GET | `/api/avaliacoes/palestra/<id>` | Avaliações de uma palestra |
| POST | `/api/avaliacoes` | Avaliar palestra (1 a 5 estrelas e comentário opcional) |
| PUT/PATCH | `/api/avaliacoes/<id>` | Alterar nota ou comentário |
| DELETE | `/api/avaliacoes/<id>` | Remover avaliação |

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
Detalhes -> Favoritar -> tabela favorito -> aba Meus favoritos
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

## 9. Tratamento de erros

O backend retorna mensagens simples para:

- usuário ou palestra inexistente;
- inscrição duplicada;
- palestra lotada;
- inscrição inexistente;
- favorito duplicado ou inexistente;
- lembrete duplicado ou inexistente;
- servidor indisponível.

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