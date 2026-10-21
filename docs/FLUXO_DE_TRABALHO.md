# Fluxo de trabalho de cada tarefa

Passo a passo que **cada pessoa da equipe** segue em **toda tarefa** do
`PENDENCIAS.md`, do começo até a tarefa estar na `main`. O objetivo é
que duas pessoas trabalhem ao mesmo tempo sem uma quebrar o código da
outra, e que tudo o que chega na `main` esteja testado.

Resumo:

```
1. Preparar  →  2. Desenvolver  →  3. Testar  →  4. Revisar com o Claude e commit  →  5. Push
      ↓
6. Pull Request  →  7. Revisão  →  8. Atualizar com a main e testar de novo
      ↓
9. Merge  →  10. Testar na main  →  11. Avisar a outra pessoa  →  12. Fechar a tarefa
```

Os comandos partem da raiz do repositório (`ProjetoDeSoftware/`), a não
ser quando o passo diz para entrar em outra pasta.

**Primeira vez no projeto?** Antes da primeira tarefa, siga a seção
"0. Preparar o computador (uma vez só)". Para subir o sistema nos dias
seguintes, use a seção "Rodar o sistema no dia a dia".

---

## Conceitos usados aqui

- **Branch (ramo):** uma cópia paralela do código dentro do Git. Cada
  tarefa tem a sua, e o que você faz nela não afeta a `main` nem a
  branch da outra pessoa.
- **Commit:** um "ponto salvo" no histórico do Git, com uma mensagem
  dizendo o que mudou.
- **Push:** enviar os commits do seu computador para o GitHub.
- **Pull Request (PR):** um pedido, feito no GitHub, para juntar a sua
  branch na `main`. É onde a outra pessoa revisa antes de juntar.
- **Merge:** juntar o código de uma branch em outra.
- **Conflito:** quando as duas pessoas mudaram as mesmas linhas de um
  arquivo, o Git não sabe qual versão manter e pede que alguém decida.

---

## Ferramentas do Claude Code em cada etapa

O Claude Code tem, além da conversa normal, **modos** e **comandos**
prontos (chamados de *skills* e *agentes*) para etapas específicas. Um
comando é usado digitando `/` seguido do nome na caixa de mensagem (por
exemplo, `/code-review`).

| Etapa | O que usar | Para quê |
|---|---|---|
| Entrar no projeto (pessoa nova) | Conversa normal: "é minha primeira vez no projeto" | O Claude segue a apresentação do `CLAUDE.md`: resumo, arquivos para ler e cronograma |
| 1. Preparar | **Modo de planejamento** (*plan mode*) | O Claude analisa o código e monta o plano da tarefa (regra 1 do `CLAUDE.md`) **sem alterar nenhum arquivo**. Só depois que você aprova o plano é que ele começa a mexer no código. No VS Code, escolha o modo no seletor da caixa de mensagem. No terminal, use `Shift+Tab` |
| 1. Preparar (dúvida sobre o código) | Pedir na conversa: "procure onde..." | Para perguntas como "onde fica a regra de vagas?", o Claude usa um agente de busca (*Explore*) que lê vários arquivos e devolve só a resposta |
| 2. Desenvolver | Conversa normal | O Claude executa o plano aprovado, um passo de cada vez, explicando o que faz |
| 3. Testar | `/run` | Sobe o sistema e verifica se a mudança funciona de verdade. Os testes com `curl` e no app também podem ser pedidos na conversa |
| 4. Antes do commit | `/code-review` | Revisa as mudanças ainda não commitadas em busca de **erros** (bugs, casos esquecidos). Corrija o que fizer sentido e teste de novo |
| 4. Antes do commit (tarefas de segurança) | `/security-review` | Revisão focada em segurança. Usar nas tarefas que mexem com login, permissões, senhas ou upload: P01, P02, P03, P04, F14 e F18 |
| 4. Antes do commit (opcional) | `/simplify` | Procura código repetido ou mais complicado do que precisa e simplifica. **Não procura erros.** Use se sobrar tempo |
| 7. Revisão do Pull Request | `/code-review <número do PR>` | Quem revisa pede ao Claude uma revisão do PR da outra pessoa. Com `--comment`, os apontamentos viram comentários no próprio PR do GitHub |

### Qual modelo usar em cada etapa

O Claude tem modelos com níveis diferentes de capacidade. Quanto mais
capaz, mais ele gasta do limite de uso da conta:

- **Opus:** o mais capaz, para problemas difíceis, de arquitetura e de
  segurança. Gasto alto.
- **Sonnet:** equilibrado, muito bom para programar no dia a dia. Gasto
  médio.
- **Haiku:** rápido e simples, para tarefas pequenas. Gasto baixo.

| Etapa | Modelo | Por quê |
|---|---|---|
| 1. Planejar (modo de planejamento) | **Opus** | É onde se decide a arquitetura. Um erro aqui se espalha pela tarefa toda |
| 2. Desenvolver tarefas estruturais: F19, P01, P02, F14, F02 | **Opus** | Segurança, conceitos novos ou base para outras tarefas |
| 2. Desenvolver as demais tarefas (telas e funcionalidades que seguem padrões existentes) | **Sonnet** | Com o plano pronto, é seguir o padrão |
| 3. Testar (`/run`, `curl`) | **Sonnet** | É executar e conferir |
| 4. `/code-review` e `/security-review` | **Opus** | Achar erros escondidos exige o melhor raciocínio |
| Coisas pequenas (corrigir um comentário, dúvida rápida, ajuste de texto) | **Haiku** | Não precisa de mais |

**Regra prática:** planejar e revisar com Opus, executar com Sonnet. Nas
tarefas estruturais, Opus do começo ao fim.

**Como trocar:** digite `/model` na caixa de mensagem, ou use o seletor
de modelo do VS Code. A troca vale para a conversa atual: dá para
planejar com Opus e trocar para Sonnet antes de executar.

Cuidados:

- **Os comandos não substituem o teste nem a revisão humana.** Eles
  ajudam a encontrar problemas, mas quem decide e testa é a equipe.
- **A conta do Claude é compartilhada,** e com ela o limite de uso.
  Cada revisão gasta parte desse limite. Use `/code-review` **uma vez
  por tarefa** (passo 4) e `/security-review` só nas tarefas de
  segurança. Mais dicas na seção "Como economizar o limite de uso".
- **Não usar `/code-review ultra`.** É uma revisão na nuvem, cobrada à
  parte, e desnecessária para o projeto.
- Conforme o modo de permissão escolhido, o Claude pede aprovação antes
  de rodar comandos ou alterar arquivos. Leia o que ele vai fazer antes
  de aprovar, principalmente os comandos que enviam algo ao GitHub
  (`git push`). Como é a primeira vez de vocês, prefira o modo em que
  ele pergunta antes de agir.

---

## Como economizar o limite de uso sem perder qualidade

A conta do Claude é compartilhada, e o limite precisa durar até sexta.
Um **token** é um pedaço de texto (mais ou menos uma sílaba ou palavra
curta), e o limite é contado em tokens. A cada mensagem, o Claude
**relê a conversa inteira** desde o começo, então uma conversa longa
fica cada vez mais cara.

1. **Uma conversa por tarefa.** Terminou uma tarefa, comece uma
   conversa nova (`/clear` ou nova conversa no VS Code). Nada se perde:
   o que importa está nos arquivos do projeto. Se uma tarefa ficar
   longa demais, `/compact` resume a conversa e continua.
2. **Pedidos curtos e diretos.** "Vamos fazer a F07" basta: o Claude lê
   a tarefa e as decisões no `PENDENCIAS.md`. Evite "analise o projeto
   inteiro", não explique de novo decisões já registradas e não peça
   para reler o relatório em PDF (o essencial está no `PENDENCIAS.md`).
   Junte as perguntas em uma mensagem só.
3. **Acertar o plano.** Refazer uma tarefa custa o dobro. Leia o plano
   com calma antes de aprovar e corrija ali, quando ainda é barato.
4. **Não usar o Claude para o que vocês já sabem.** Os comandos do Git
   estão neste arquivo. Testes no app são feitos à mão. Para dúvidas
   rápidas, use o Haiku.
5. **Acompanhar o gasto e guardar reserva.** O `/usage` mostra quanto
   do limite já foi usado: olhe no começo e no fim do dia. O limite
   semanal é o que pode acabar antes de sexta. Guarde reserva para
   sexta (README, dados de demonstração, gravação e imprevistos). Se
   estiver acabando, as tarefas 🔴 vêm antes de qualquer revisão
   opcional.
6. **Onde não economizar.** A qualidade vem do processo: plano
   aprovado, testes, revisão e Pull Request. Não pule o `/code-review`
   nem o `/security-review` nas tarefas em que são obrigatórios. Um erro
   que passa custa muito mais caro para corrigir depois.

### Duas pessoas na mesma conta

O total de tokens depende do trabalho, não de quantas pessoas trabalham.
O que muda é a **velocidade**: o limite é contado em janelas de algumas
horas, e duas pessoas usando ao mesmo tempo esgotam a janela na metade
do tempo. Se isso acontecer, **as duas ficam paradas**. Para evitar:

1. **Alternar o trabalho pesado.** As tarefas com Opus da Manuela (F19,
   P01, P02, F14, F02) e as revisões (`/code-review`, `/security-review`)
   não devem cair no mesmo horário em que a Bianca está usando muito o
   Claude. Avise no grupo antes de começar uma etapa pesada.
2. **Bianca usa o Sonnet como padrão.** As tarefas dela são telas que
   seguem padrões já criados. O Opus fica só para a revisão.
3. **Fazer sem o Claude o que já souber.** Ajustes de layout, copiar o
   padrão de outra tela e pequenas correções podem ser feitos à mão.
4. **Conferir o `/usage` juntas** no começo da tarde. Se o limite
   estiver acabando, quem está com a tarefa menos crítica pausa (veja a
   prioridade no `PENDENCIAS.md`).

---

## 0. Preparar o computador (uma vez só)

O sistema tem três partes, e cada uma roda de um jeito:

```
App Flutter (Chrome ou celular)  →  API Flask (Python, porta 5000)  →  Banco MySQL (porta 3306)
```

- **Porta:** um número que identifica um programa dentro do computador.
  O app chama a API em `127.0.0.1:5000`, e a API conversa com o MySQL na
  porta `3306`. `127.0.0.1` (ou `localhost`) significa "este próprio
  computador".

Cada comando que muda de um sistema para o outro está marcado com
**Linux:** (Ubuntu) ou **Windows:**. Siga só o do seu sistema. Os blocos
sem marcação valem para os dois. No Linux, comandos com `sudo` pedem a
senha do seu usuário do computador (ao digitar, nada aparece na tela; é
normal).

### 0.1 Instalar as ferramentas do sistema

**Linux:**

```bash
sudo apt update
sudo apt install git python3-venv mysql-server
```

- **`python3-venv`:** permite criar o ambiente virtual do Python (passo
  0.5). Sem ele, aparece o erro "ensurepip is not available".
- **`mysql-server`:** o banco de dados. Depois de instalado, ele já fica
  ligado e liga sozinho junto com o computador. Para conferir:
  `systemctl status mysql` (deve aparecer `active (running)`; aperte `q`
  para sair).

**Windows:** instalar o [Python](https://www.python.org/downloads/)
(marcar "Add python.exe to PATH" na instalação), o
[Git](https://git-scm.com/download/win) e o
[MySQL Installer](https://dev.mysql.com/downloads/installer/). Anote a
senha do `root` escolhida na instalação do MySQL.

### 0.2 Criar o usuário do projeto no MySQL

No Ubuntu, o usuário `root` do MySQL só entra com `sudo`, sem senha (o
MySQL confia em quem é administrador do computador). O backend não
consegue entrar assim, então criamos um usuário só para o projeto, com
senha.

Entrar no MySQL como administrador:

**Linux:**

```bash
sudo mysql
```

O terminal muda para `mysql>`. Digitar um comando por vez:

```sql
CREATE USER 'fluxo'@'localhost' IDENTIFIED BY 'fluxo123';
GRANT ALL PRIVILEGES ON sistema_eventos.* TO 'fluxo'@'localhost';
EXIT;
```

- `CREATE USER` cria o usuário `fluxo` com a senha `fluxo123`, que só
  pode entrar a partir deste computador (`localhost`).
- `GRANT` dá a ele permissão total **só** no banco `sistema_eventos`,
  e não nos outros bancos do MySQL.
- A senha `fluxo123` é só para desenvolvimento, no seu computador. Ela
  vai para o `.env`, que o `.gitignore` impede de ir para o GitHub.

**Windows:** pular este passo e usar o `root` com a senha escolhida na
instalação.

### 0.3 Instalar o Flutter

**Linux:**

```bash
sudo snap install flutter --classic
flutter doctor
```

- **`snap`:** a loja de programas do Ubuntu. Ela já coloca o comando
  `flutter` no terminal.
- **`flutter doctor`:** confere o que está instalado. Na primeira vez,
  ele baixa o restante do Flutter (demora alguns minutos). Para rodar no
  Chrome, basta aparecer `[✓] Chrome`. Os avisos de Android Studio e
  Linux toolchain podem ser ignorados por enquanto.

**Windows:** seguir o guia oficial
(<https://docs.flutter.dev/get-started/install/windows>) e rodar
`flutter doctor` no final.

### 0.4 Baixar o projeto

Só para quem ainda não tem a pasta no computador:

```bash
git clone https://github.com/annaelizacc/ProjetoDeSoftware.git
cd ProjetoDeSoftware
```

Configurar o Git com o **seu** nome e e-mail (para o histórico mostrar
quem fez cada parte):

```bash
git config user.name "Seu Nome"
git config user.email "seu@email.com"
```

### 0.5 Preparar o backend

**Linux:**

```bash
cd sistema-eventos
python3 -m venv .venv
source .venv/bin/activate
pip install -r backend/requirements.txt
```

- **Ambiente virtual (`.venv`):** uma pasta com um Python separado só
  para este projeto. As bibliotecas (Flask, SQLAlchemy etc.) são
  instaladas nela, e não no computador inteiro. Assim, projetos
  diferentes não brigam por versões diferentes da mesma biblioteca.
- **`source .venv/bin/activate`:** liga o ambiente virtual neste
  terminal. O começo da linha passa a mostrar `(.venv)`. É preciso
  ativar **em todo terminal novo** antes de rodar o backend.
- **`pip install -r`:** instala todas as bibliotecas listadas em
  `requirements.txt`.

**Windows:** `python -m venv .venv` e `.venv\Scripts\activate`.

Criar o arquivo de configuração `.env` a partir do modelo:

**Linux:**

```bash
cp backend/.env.example backend/.env
```

**Windows:** `copy backend\.env.example backend\.env`

Abrir `backend/.env` no VS Code e deixar assim:

```
SECRET_KEY=qualquer-texto-longo-e-dificil
DATABASE_URL=mysql+pymysql://fluxo:fluxo123@localhost:3306/sistema_eventos
```

- **`.env`:** guarda configurações que mudam de computador para
  computador, como a senha do banco. O `config.py` lê este arquivo. Ele
  **nunca** vai para o GitHub (está no `.gitignore`). Para conferir:
  `git check-ignore -v backend/.env` deve mostrar uma linha citando o
  `.gitignore`.
- **`DATABASE_URL`:** o endereço do banco, no formato
  `mysql+pymysql://usuario:senha@computador:porta/banco`.

**Windows:** usar `root` e a senha da instalação:
`mysql+pymysql://root:SUA_SENHA@localhost:3306/sistema_eventos`.

### 0.6 Criar o banco

Ainda dentro de `sistema-eventos/`:

**Linux:**

```bash
mysql -u fluxo -p < database/sistema_eventos_atualizado.sql
```

Digitar a senha `fluxo123` quando pedir. Se não aparecer nenhuma
mensagem, deu certo.

- O `<` manda o conteúdo do arquivo `.sql` para o MySQL, como se você
  digitasse cada comando.
- ⚠️ O script **apaga e recria** o banco `sistema_eventos`. Rodar só na
  instalação e quando uma tarefa mudar o banco (passo 1.4).

**Windows:** `mysql -u root -p < database/sistema_eventos_atualizado.sql`
(no PowerShell, se o `<` der erro, abrir o arquivo no MySQL Workbench e
executar por lá).

### 0.7 Primeiro teste

Seguir a seção "Rodar o sistema no dia a dia" logo abaixo. Se o
`curl` responder `{"status": "ok"}` e o login da Ana funcionar no app, o
computador está pronto.

---

## Rodar o sistema no dia a dia

São **dois terminais abertos ao mesmo tempo**: um para a API e outro para
o app. No VS Code, abra um terminal novo com `` Ctrl+` `` e outro no
botão `+` do painel de terminais.

O MySQL não precisa ser ligado: ele já fica ligado sozinho.

**Terminal 1: API (backend)**

**Linux:**

```bash
cd sistema-eventos
source .venv/bin/activate
python -m backend.app
```

**Windows:** trocar a segunda linha por `.venv\Scripts\activate`.

- Com o ambiente virtual ativo, `python` já aponta para o Python do
  `.venv` (fora dele, no Linux, o comando é `python3`).
- O `-m backend.app` roda o arquivo `backend/app.py` como parte do
  pacote `backend`. Por isso o comando é dado de dentro de
  `sistema-eventos/`, e não de dentro de `backend/`.
- Deu certo quando aparece `Running on http://127.0.0.1:5000`. O
  terminal fica "preso" mostrando as requisições: isso é normal. Para
  desligar a API, `Ctrl+C`.
- A API reinicia sozinha quando um arquivo `.py` é salvo (modo debug).

Para conferir, num terceiro terminal (ou no navegador, abrindo o
endereço):

```bash
curl http://127.0.0.1:5000/api/health
```

Resposta esperada: `{"status": "ok"}`.

**Terminal 2: app (Flutter)**

```bash
cd sistema-eventos/frontend/Flutter
flutter pub get
flutter run -d chrome
```

- **`flutter pub get`:** baixa os pacotes do app listados em
  `pubspec.yaml` (parecido com o `pip install`). Rodar sempre que
  alguém mudar o `pubspec.yaml`.
- **`-d chrome`:** escolhe o Chrome como dispositivo. O app abre numa
  janela do Chrome.
- Com o app rodando, no terminal: `r` aplica as mudanças salvas sem
  perder a tela atual (*hot reload*), `R` reinicia o app do zero e `q`
  fecha.
- Login de teste: `ana.silva@email.com`, senha `hash123`.

**No emulador Android:** o **emulador** é um celular Android "de mentira"
que roda numa janela do computador. Cada celular virtual criado no
Android Studio se chama **AVD** (*Android Virtual Device*). Quem ainda
não tem um, cria no Android Studio em *Device Manager* → *Create device*.

1. Ver o nome dos AVDs criados:

   ```bash
   ~/Android/Sdk/emulator/emulator -list-avds
   ```

2. Ligar o emulador (no exemplo, o AVD `Pixel_Fluxo`), num terminal
   próprio:

   ```bash
   ~/Android/Sdk/emulator/emulator -avd Pixel_Fluxo -gpu swiftshader_indirect
   ```

   - **`-gpu swiftshader_indirect`:** faz o emulador desenhar a tela com
     o processador, em vez da placa de vídeo. Em alguns computadores a
     placa de vídeo não é aceita pelo emulador, e ele fecha sozinho no
     meio do `flutter run` (erro `device 'emulator-5554' not found`).
     Com essa opção ele fica um pouco mais lento, mas não cai.
   - Por isso o emulador é ligado por esse comando, e não pelo
     `flutter emulators --launch`, que não aceita essa opção.
   - O terminal fica "preso" enquanto o emulador estiver ligado.
     Esperar a tela inicial do Android aparecer (cerca de 1 minuto).

3. No terminal 2, conferir se o emulador aparece (algo como
   `sdk gphone64 x86 64 • emulator-5554`):

   ```bash
   flutter devices
   ```

4. Rodar o app no emulador:

   ```bash
   cd sistema-eventos/frontend/Flutter
   flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:5000
   ```

   - **`10.0.2.2`:** dentro do emulador, `127.0.0.1` é o próprio
     emulador, e não o computador. O endereço `10.0.2.2` é o "atalho"
     do emulador para chegar no computador, onde a API está rodando.
   - **`--dart-define=API_URL=...`:** passa o endereço da API para o app
     na hora de rodar, sem mudar o código (ver
     `lib/services/api_service.dart`).
   - A primeira vez demora alguns minutos (o app é compilado para
     Android). As teclas `r`, `R` e `q` funcionam como no Chrome.

**Windows:** o emulador fica em
`%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe` (mesmas opções).

**No celular Android (para a gravação e para a F02):** ativar as
"Opções do desenvolvedor" e a "Depuração USB" no celular, conectar no
computador pelo cabo e rodar `flutter devices` para ver se ele aparece.
O celular não enxerga o `127.0.0.1` do computador, então é preciso
passar o IP do computador na rede (descobrir com `hostname -I`):

```bash
flutter run --dart-define=API_URL=http://IP_DO_COMPUTADOR:5000
```

O celular e o computador precisam estar no mesmo Wi-Fi.

### Erros comuns

| Erro | Causa | Solução |
|---|---|---|
| `python: command not found` | Ambiente virtual desligado (no Linux, fora dele é `python3`) | Dentro de `sistema-eventos/`: **Linux:** `source .venv/bin/activate` · **Windows:** `.venv\Scripts\activate` |
| `ModuleNotFoundError: No module named 'flask'` | Ambiente virtual desligado ou bibliotecas não instaladas | Ativar o `.venv` e rodar `pip install -r backend/requirements.txt` |
| `ModuleNotFoundError: No module named 'backend'` | Comando rodado dentro de `backend/` | Voltar para `sistema-eventos/` (`cd ..`) |
| `Access denied for user` | Usuário ou senha errados no `.env` | Conferir o `DATABASE_URL` com o usuário criado no passo 0.2 |
| `Unknown database 'sistema_eventos'` | O banco não foi criado | Rodar o passo 0.6 |
| `Can't connect to MySQL server` | MySQL desligado | **Linux:** `sudo systemctl start mysql` · **Windows:** abrir "Serviços" e iniciar o serviço `MySQL` |
| `Address already in use` (porta 5000) | Já existe uma API rodando em outro terminal | Fechar a outra com `Ctrl+C`, ou procurar o terminal esquecido |
| App mostra "servidor indisponível" | A API não está rodando ou o endereço está errado | Conferir o terminal 1 e o `curl` do health |
| `adb: device 'emulator-5554' not found` | O emulador fechou durante o `flutter run` (a placa de vídeo não foi aceita) | Ligar de novo com `-gpu swiftshader_indirect` (ver "No emulador Android") |
| App no emulador mostra "servidor indisponível" | Rodado sem o `--dart-define`, então o app procura a API em `127.0.0.1`, que é o próprio emulador | Rodar com `--dart-define=API_URL=http://10.0.2.2:5000` |
| `flutter: command not found` logo depois de instalar | O terminal foi aberto antes da instalação | Fechar e abrir o terminal |

---

## 1. Preparar

1. Abrir a tarefa no `PENDENCIAS.md` e ler: o que existe, o que falta e
   as decisões já tomadas.
2. Mudar o status da tarefa para **Em andamento** no `PENDENCIAS.md`.
3. Atualizar a `main` e criar a branch da tarefa:

   ```bash
   git checkout main
   git pull
   git checkout -b f07-avaliacao-estrelas
   ```

   O nome da branch é `<id>-<descricao-curta>`, em minúsculas e sem
   acentos (ex.: `p01-autenticacao`, `f20-visual-base`).

4. Se a `main` recebeu mudanças no banco desde a última vez (por exemplo,
   a F19), recriar o banco local:

   ```bash
   cd sistema-eventos
   mysql -u fluxo -p < database/sistema_eventos_atualizado.sql
   ```

   **Linux:** o comando acima. **Windows:** `-u root` no lugar de
   `-u fluxo` (ver o passo 0.6).

   ⚠️ O script **apaga e recria** o banco `sistema_eventos`. Tudo o que
   você cadastrou para teste some.

## 2. Desenvolver

- Seguir as regras do `CLAUDE.md`: plano antes de executar, nomes em
  português, docstrings explicando a camada, arquitetura
  Controller → Service → Model/Repository.
- **Visual:** telas novas ou alteradas usam o tema de `app_theme.dart`.
  Nunca usar cores fixas.
- **Mexer só no que a tarefa pede.** Se encontrar outro problema, anotar
  e combinar antes. Não resolver junto: isso aumenta o risco de conflito
  com a outra pessoa.
- **Arquivos que as duas pessoas podem alterar** (`README.md`,
  `PENDENCIAS.md`, o arquivo SQL, `routes.py`): mudar só o trecho
  necessário, para facilitar a junção.
- Se a tarefa mudar como instalar, rodar ou usar o sistema (rotas,
  telas, configuração), atualizar o `README.md` na mesma branch.

## 3. Testar (antes do commit)

Rodar **o sistema inteiro**, e não só a parte nova, como na seção
"Rodar o sistema no dia a dia".

**Backend:** com a API rodando e o `curl` do health respondendo
`{"status": "ok"}`, testar as rotas da tarefa com `curl`, incluindo os
**casos de erro** (dados faltando, usuário sem permissão, registro que
não existe).

**Flutter:** antes de abrir o app, conferir o código:

```bash
cd sistema-eventos/frontend/Flutter
flutter analyze
```

- O `flutter analyze` procura erros e avisos no código Dart sem rodar o
  app. Ele precisa terminar **sem erros**.
- No app, testar a funcionalidade nova **como o usuário usaria**, no
  modo claro e no modo escuro.

**Teste rápido do que já funcionava** (para garantir que nada quebrou):

- [ ] login com o usuário de teste;
- [ ] programação do evento abre e a busca por tema funciona;
- [ ] detalhes de uma palestra abrem;
- [ ] inscrever e cancelar inscrição em uma palestra;
- [ ] favoritar e desfavoritar;
- [ ] agenda e avisos abrem.

Se algo falhar, corrigir antes de seguir.

## 4. Revisar com o Claude e fazer o commit

**Revisão obrigatória** (com o modelo Opus), antes de qualquer commit:

- **Toda tarefa:** rodar `/code-review`. Ele revisa as mudanças ainda
  não commitadas em busca de erros.
- **Tarefas de segurança** (P01, P02, P03, P04, F14, F18): rodar também
  `/security-review`.
- Corrigir o que fizer sentido. Se algum apontamento não fizer sentido,
  anotar o motivo na descrição do Pull Request.
- Se houve correção, **repetir o passo 3 (testar)**.

Depois, o commit:

1. Ver o que mudou:

   ```bash
   git status
   git diff
   ```

   Conferir se não há arquivos que não deveriam ir para o repositório
   (`.env`, `.venv/`, `build/`, arquivos de configuração local).

2. Adicionar os arquivos da tarefa:

   ```bash
   git add .
   git status
   ```

   O `.gitignore` (P11) já impede que arquivos locais e senhas (`.env`,
   `.venv/`, `build/`) sejam adicionados. Mas o `git add .` pega
   **qualquer** mudança da pasta, inclusive as que não são da tarefa (um
   `print` esquecido, um arquivo de teste). Por isso, **sempre conferir
   o `git status`** antes do commit. Se apareceu algo que não é da
   tarefa, tirar com:

   ```bash
   git restore --staged caminho/do/arquivo
   ```

3. Fazer o commit com uma mensagem que comece pelo id da tarefa:

   ```bash
   git commit -m "F07: cria a avaliação por estrelas e a média por palestra"
   ```

   Uma tarefa pode ter vários commits. Fazer um a cada parte que
   funciona (por exemplo: "F07: cria a rota de avaliação" e depois
   "F07: cria as estrelas na tela de detalhes").

## 5. Push

```bash
git push -u origin f07-avaliacao-estrelas
```

O `-u` só é necessário no primeiro push da branch. Depois, basta
`git push`.

## 6. Pull Request

No GitHub, abrir um Pull Request da branch da tarefa para a `main`:

- **Título:** o id e o nome da tarefa (ex.: `F07 Avaliação por estrelas`).
- **Descrição:**
  - o que foi feito;
  - quais revisões foram rodadas (`/code-review`, `/security-review`) e
    o que foi corrigido ou deixado de lado (com o motivo);
  - como testar (os `curl` e o passo a passo no app);
  - se o banco mudou e é preciso recriá-lo;
  - se o README foi atualizado.

## 7. Revisão

**A outra pessoa** revisa o Pull Request antes do merge. Se ela estiver
ocupada demais com o prazo, quem fez a tarefa revisa o próprio PR com o
checklist, olhando arquivo por arquivo na aba "Files changed".

Checklist da revisão:

- [ ] o `/code-review` foi rodado (e o `/security-review`, se for
      tarefa de segurança), e os apontamentos foram tratados;
- [ ] faz só o que a tarefa pede;
- [ ] segue o estilo do projeto (nomes em português, docstrings,
      Controller → Service → Model/Repository);
- [ ] o backend decide as regras, e não o app (ex.: vagas, permissões);
- [ ] sem cores fixas nas telas;
- [ ] sem senhas, `.env` ou arquivos locais no PR;
- [ ] README atualizado, se necessário;
- [ ] quem revisou baixou a branch e testou pelo passo a passo da
      descrição.

## 8. Atualizar com a main e testar de novo

Enquanto você trabalhava, a outra pessoa pode ter colocado coisas na
`main`. Antes do merge, trazer essas mudanças para a sua branch. Na sua
branch, com tudo já commitado:

```bash
git pull origin main
```

Esse comando busca a `main` mais recente no GitHub e junta na branch em
que você está.

- **Se aparecer conflito:** o Git marca os trechos nos arquivos com
  `<<<<<<<`, `=======` e `>>>>>>>`. Abrir cada arquivo, decidir qual
  versão fica (muitas vezes, as duas partes juntas), apagar as marcas e
  depois rodar:

  ```bash
  git add arquivo-resolvido
  git commit
  ```

  Em caso de dúvida, chamar a outra pessoa. O código dela também está
  ali.

- **Repetir o passo 3 (testar)**, porque agora o seu código está junto
  com o da outra pessoa. Se o banco mudou, recriar.
- Enviar: `git push`.

## 9. Merge

No GitHub, no Pull Request, clicar em **"Merge pull request"** →
**"Create a merge commit"**. Depois, clicar em **"Delete branch"** (a
branch já cumpriu o papel dela).

## 10. Testar na main

```bash
git checkout main
git pull
```

Rodar o **passo 3 de novo**, agora na `main`. É a garantia final de que
o que está na `main` funciona. Se algo quebrou, avisar a outra pessoa e
corrigir em uma branch nova (ex.: `f07-correcao`) antes de começar outra
tarefa.

## 11. Avisar a outra pessoa

Mandar uma mensagem dizendo:

- qual tarefa entrou na `main`;
- se o banco mudou (é preciso recriar);
- se há algo novo que ela deve usar (por exemplo, o padrão de
  autenticação da P01 ou os componentes visuais da F20).

A outra pessoa faz um commit do que estiver fazendo e traz as mudanças
para a branch em que estiver trabalhando:

```bash
git pull origin main
```

Se o banco mudou, ela também recria o banco local (passo 1.4).

## 12. Fechar a tarefa

1. No `PENDENCIAS.md`, marcar a tarefa como **Concluído**.
2. Decidir se a resolução deve ser registrada no `DOCUMENTACAO.md`. Nem
   tudo precisa: registrar o que for útil para a documentação final
   (decisões, motivos, como funciona).
3. Fazer essas mudanças de documentação em uma branch curta
   (ex.: `f07-docs`) ou, de preferência, já dentro da branch da tarefa,
   antes do passo 6.

---

## Sincronizar no começo de cada dia

Mesmo sem aviso, cada pessoa começa o dia trazendo o que entrou na
`main`. Na branch em que estiver trabalhando, com tudo commitado:

```bash
git pull origin main
```

Depois, rodar o backend e o app para conferir que tudo continua
funcionando. Quanto mais cedo as mudanças da outra pessoa chegam, menores
são os conflitos.

> **`git pull` sozinho ou `git pull origin main`?** O `git pull`
> sozinho atualiza a branch em que você está com a versão **dela mesma**
> no GitHub. Na `main`, isso traz o que foi juntado. Na branch da sua
> tarefa, traz só o que você mesmo enviou, e não o trabalho da outra
> pessoa. Para trazer a `main` para dentro da sua branch, use
> `git pull origin main`.

## Atualizar a máquina depois da P11

Vale **uma vez só**, para quem clonou o projeto antes da P11 entrar na
`main` (20/10/2026). Quem clonar depois não precisa fazer nada.

**O que mudou:** os arquivos gerados pelas ferramentas (`build/`,
`.gradle/`, `.dart_tool/`, `__pycache__/` e os arquivos locais do
Flutter) saíram do Git e agora estão no `.gitignore`.

**Por que é preciso um passo a mais:** ao rodar o app, esses arquivos
mudaram no seu computador. Como até agora o Git cuidava deles, ele
recusa o `git pull` com a mensagem *"your local changes would be
overwritten"*. A solução é descartar essas mudanças, que não valem nada
porque são recriadas pelas ferramentas.

1. Fazer commit do que for **seu** (código da tarefa), se houver, e
   conferir que o `git status` mostra só arquivos gerados.
2. Descartar as mudanças **só** nos arquivos gerados (a partir da raiz
   do repositório):

   ```bash
   git restore -- 'sistema-eventos/frontend/Flutter/build' 'sistema-eventos/frontend/Flutter/.dart_tool' 'sistema-eventos/frontend/Flutter/android/.gradle' 'sistema-eventos/frontend/Flutter/android/.kotlin' 'sistema-eventos/frontend/Flutter/android/local.properties' 'sistema-eventos/frontend/Flutter/ios/Flutter' '*__pycache__*'
   ```

   Se o Git disser que algum caminho não existe (`did not match any
   file`), tirar esse caminho do comando e rodar de novo.
3. Trazer a `main` atualizada:

   ```bash
   git checkout main
   git pull
   ```

   O Git apaga da pasta os arquivos que deixaram de ser versionados.
   É esperado.
4. Recriar os arquivos gerados (agora ignorados pelo Git):

   ```bash
   cd sistema-eventos/frontend/Flutter
   flutter pub get
   ```

   O resto (`build/`, `.gradle/`, `__pycache__/`) volta sozinho na
   próxima vez que o app e o backend rodarem.
5. Conferir: rodar o app e depois `git status`. Não deve aparecer nenhum
   arquivo de `build/`, `.gradle/` ou `__pycache__/`.

## Regras que valem sempre

- Nada é commitado direto na `main`. A única exceção é o commit inicial
  da P14, que já inclui o `.gitignore` da P11.
- Uma tarefa por branch. Duas tarefas na mesma branch dificultam a
  revisão e a correção.
- Fazer merge com frequência. Branches que ficam dias sem atualizar com
  a `main` acumulam conflitos maiores.
- Na dúvida, perguntar antes de juntar.
