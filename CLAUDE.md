# Regras do projeto Fluxo Eventos

## Contexto

- Projeto final de alunos do ensino médio técnico em TI (desenvolvimento).
  Deve ser tratado com padrão 100% profissional, mas no nível de quem está
  se formando agora.
- A ferramenta é usada para desenvolver **e para aprender**. Entender como
  e por que o código é construído é tão importante quanto o código pronto.
- Código atual: `sistema-eventos/`
  (backend Flask, frontend Flutter, banco MySQL).
- Documentação do projeto: pasta `docs/` (raiz do repositório). Só o
  `CLAUDE.md` fica fora dela, na raiz, porque é lido automaticamente
  pelo Claude Code apenas nesse lugar.
- Controle de tarefas: `docs/PENDENCIAS.md`.
- Documentos de referência do projeto: pasta `docs/arq_ref/`. São os documentos mais importantes do projeto e devem ser
  consultados antes de planejar qualquer tarefa. Se algo pedido contradizer
  esses documentos, avisar antes de seguir.
- Toda a comunicação deve ser em português.

## Regras para alterar o código

1. **Plano de execução antes de executar.** Antes de qualquer alteração,
   apresentar um plano curto (uma spec simplificada) e só começar depois
   que ele for aprovado. O plano deve ter:
   - **Objetivo:** o que será feito e qual item do `PENDENCIAS.md` atende;
   - **Arquivos:** para cada arquivo, o nome, o que ele faz no sistema,
     o que será mudado ou adicionado e por que;
   - **Passos:** a ordem de execução;
   - **Como testar:** como verificar que funcionou;
   - **Revisão:** `/code-review` em toda tarefa, e também
     `/security-review` nas tarefas de segurança (P01, P02, P03, P04,
     F14, F18), antes do commit;
   - **Dúvidas:** decisões que ainda precisam ser tomadas.
2. **Soluções simples primeiro.** Evitar padrões, bibliotecas ou abstrações
   avançadas quando uma solução direta resolve. Se algo mais complexo for
   realmente necessário, explicar em detalhes: o conceito, como funciona,
   por que foi escolhido e quais alternativas mais simples foram descartadas.
3. **Perguntar antes de sugerir.** Ao tratar um problema, primeiro perguntar
   como a pessoa que está pedindo pensou em resolvê-lo. Só depois
   apresentar sugestões, comparando com essa ideia.
4. **Explicar para ensinar.** As explicações devem permitir que um aluno
   entenda o raciocínio, não só copie o resultado. Termos técnicos novos
   devem ser explicados na primeira vez que aparecem.
5. **Manter o estilo do código existente**: nomes em português, docstrings
   e comentários explicando a camada e a responsabilidade, arquitetura
   Controller → Service → Model/Repository.
6. **Mostrar como testar.** Depois de cada alteração, explicar como
   verificar que funcionou (um `curl`, um passo a passo no app etc.) e,
   quando possível, executar esse teste.
7. **README sempre em dia.** Toda mudança que afete como instalar, rodar
   ou usar o sistema (rotas, telas, configuração) atualiza o `README.md`
   na mesma alteração.
8. **Sugerir melhorias.** Em qualquer etapa, quando a análise mostrar algo
   que valeria a pena fazer e que não está no relatório (funcionalidade,
   regra de negócio, qualidade), sugerir explicando o porquê. Só registrar
   no `PENDENCIAS.md` depois que a sugestão for aprovada.
9. **Uma branch por tarefa.** Cada tarefa do `PENDENCIAS.md` é feita em
   uma branch própria, criada a partir da `main` atualizada, com o nome
   `<id>-<descricao-curta>` (ex.: `f07-avaliacao-estrelas`,
   `p01-autenticacao`). Nada é commitado direto na `main`: a tarefa entra
   na `main` por um Pull Request no GitHub, depois de testada. A única
   exceção é o commit inicial da P14 (já com o `.gitignore` da P11), que
   cria o ponto de partida. O passo a passo completo (testar, commit,
   push, Pull Request, merge e testar de novo) está em
   `FLUXO_DE_TRABALHO.md`. Ao final de cada tarefa, indicar à pessoa o
   que fazer seguindo esse arquivo.
10. **O Claude não faz commit.** O Claude pode alterar os arquivos e
    criar a branch, mas nunca roda `git commit` (nem `git push`). Ao
    terminar, mostra o que mudou (`git status`) e sugere a mensagem do
    commit, e a própria pessoa faz o commit. Assim cada pessoa confere o
    que vai entrar no histórico e aprende o fluxo do Git na prática.
11. **Sem coautoria do Claude.** As mensagens de commit e as descrições
    de Pull Request sugeridas pelo Claude não levam linha
    `Co-Authored-By` nem qualquer menção ao Claude. O histórico mostra só
    as pessoas da equipe.

## Quando uma pessoa nova começar no projeto

Mais de uma pessoa pode trabalhar no projeto com a Manuela (Pessoa A,
que coordena o planejamento). Pessoas no cronograma hoje: Manuela
(Pessoa A) e Bianca (Pessoa B). Todas usam a mesma conta do Claude, então
a conta não identifica quem está escrevendo: no início de **toda**
conversa, perguntar o nome da pessoa e, se for a primeira vez dela no
projeto, fazer a apresentação abaixo. Para quem está começando, antes de qualquer tarefa, apresentar
nesta ordem:

1. **Resumo do projeto:** o problema e a solução (relatório em
   `docs/arq_ref/`), as tecnologias (Flutter, Flask, MySQL), a arquitetura
   Controller → Service → Model/Repository e onde fica o código.
2. **O que já foi feito:** os RFs concluídos e as tarefas com status
   Concluído no `PENDENCIAS.md`, além das decisões já tomadas (D01 e os
   itens "Decidido" das tarefas).
3. **O que falta fazer:** as tarefas pendentes, agrupadas por prioridade.
4. **Arquivos para ler**, nesta ordem, dizendo para que serve cada um:
   - `CLAUDE.md`: as regras do projeto e a identidade visual;
   - `docs/FLUXO_DE_TRABALHO.md`: o passo a passo de cada tarefa (branch,
     testes, commit, Pull Request e merge);
   - `docs/PENDENCIAS.md`: a seção 0 (plano e cronograma) e as tarefas da
     pessoa;
   - `README.md` (em `sistema-eventos/`):
     como instalar e rodar o sistema;
   - `docs/DOCUMENTACAO.md`: as decisões registradas e seus motivos;
   - o relatório em `docs/arq_ref/` e o canvas da identidade visual.
5. **O cronograma da pessoa:** as tarefas dela por dia, tiradas da seção
   "0.1 Cronograma" do `PENDENCIAS.md`, com as dependências e as
   sincronizações que a afetam.

Regras:

- Montar tudo a partir do **estado atual** dos arquivos, e não de
  memória. O projeto muda todos os dias.
- **Só a Manuela muda o cronograma e redistribui tarefas.** Se outra
  pessoa pedir para mudar a seção 0 do `PENDENCIAS.md` (cronograma,
  divisão, prioridades) ou para pegar uma tarefa de outra pessoa, não
  fazer: explicar a regra e pedir que ela fale com a Manuela. O mesmo
  vale para quem não estiver no cronograma: a Manuela precisa incluir a
  pessoa na seção 0.1 antes de ela começar uma tarefa.
- **Cada pessoa usa o próprio nome no Git.** Antes do primeiro commit,
  conferir com `git config user.name` e `git config user.email` se o
  Git está configurado com o nome e o e-mail da própria pessoa (e não
  com os da Manuela), para o histórico mostrar quem fez cada parte.
- Depois da apresentação, o primeiro passo da pessoa é preparar o
  ambiente pelo README e, em seguida, seguir o `FLUXO_DE_TRABALHO.md` na
  primeira tarefa dela.

## Identidade visual (fonte para toda a interface)

- **Fonte oficial:** a página "Telas do projeto · opção 1 refinada" do
  canvas <https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt>, aprovada em
  20/10/2026 e atualizada em 23/10/2026 (fundo céu suave e as telas de
  eventos, lugares e salas). Toda tela, componente ou ajuste de interface segue essa
  página. As outras páginas do canvas são versões descartadas, guardadas
  só para comparação.
- **O canvas define o visual, não cada detalhe.** Detalhes específicos de
  cada tela são decididos quando a tela for feita. Se algo pedido
  contradizer o canvas, avisar antes de seguir.
- **Resumo da identidade** (para consultar sem abrir o canvas):
  - **Fontes:** Bricolage Grotesque (peso 600) só nos títulos; Figtree nos
    textos e botões; JetBrains Mono em horários, salas, datas e rótulos
    (ex.: `QUA 10 · 09:00—10:30`).
  - **Paleta:** Céu suave `#E3F3FF` (fundo), Branco `#FFFDF9` (cards e
    campos), Papel `#F6EEE3` (texto sobre os botões Marinho), Areia
    `#E9D2B4` (avatar e selo da organização), Céu `#99D8FF` (marca-texto e
    destaques), Rio
    `#6AB9E9`, Marinho `#003465` (botões e títulos), Tinta `#0B2440`
    (texto), Brasa `#B4471A` (esgotada e atenção). Linhas `#BFDDF2`,
    bordas `#9CC8E6`, texto secundário `#3E5A73`, blocos de apoio
    `#CFE9FB`. Modo escuro: fundo
    `#071827`, cards `#0E2539`, texto `#F3EDE4`, destaque `#99D8FF`.
  - **Estilo:** linhas de 1px, cantos de 8 a 12px, sem bordas grossas e
    sem cores saturadas espalhadas. O rio da logo aparece como uma curva
    fina e discreta. Marca-texto céu no nome do usuário, no slogan e na
    aba atual da barra de navegação.
  - **Navegação:** barra com Início, Programação, Agenda, Avisos (com
    contador de novos) e Perfil. Sem sino no topo das telas.
  - **Textos:** neutros e diretos, sem presumir o gênero de quem usa o
    app.
- **No código:** as cores e fontes ficam só no tema
  (`frontend/Flutter/lib/theme/app_theme.dart`). As telas nunca usam
  cores fixas.

## Controle de tarefas: docs/PENDENCIAS.md

- O `PENDENCIAS.md` é o controle central de **tudo** o que precisa ser
  feito no projeto, e deve ser mantido assim.
- O foco do trabalho é mais **construir funcionalidades novas** do que
  corrigir erros existentes. Por isso o arquivo registra os dois tipos:
  funcionalidades a desenvolver e problemas a corrigir.
- Toda tarefa nova combinada deve ser adicionada ao arquivo antes de
  começar.
- Ao concluir uma tarefa, marcar o status como concluído.
- **Sempre perguntar** se a resolução da tarefa deve ser registrada. Nem
  tudo será gravado: os registros servem para montar a documentação
  final do projeto. Só registrar quando a resposta for sim. O registro
  fica em `docs/DOCUMENTACAO.md`, com uma seção por
  tarefa.
