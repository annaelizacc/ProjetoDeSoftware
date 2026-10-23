# Pendências do projeto

Controle central de **tudo** o que precisa ser feito no Fluxo Eventos.
Toda tarefa combinada entra aqui antes de começar e é marcada como
concluída ao final. O registro de como cada tarefa foi resolvida é
opcional e decidido no fim de cada uma.

O arquivo tem duas partes:

1. **Funcionalidades a desenvolver** (F01, F02...): o foco principal do
   trabalho.
2. **Problemas e melhorias** (P01, P02...): erros e ajustes encontrados
   no código existente.

Prioridade: 🔴 alta · 🟡 média · 🟢 baixa
Status: Pendente · Parcial · Em andamento · Concluído

Os caminhos citados nos itens (ex.: `backend/app.py`) partem da pasta
`sistema-eventos/`.

O registro de como cada tarefa foi resolvida (quando combinado) fica em
`DOCUMENTACAO.md`, nesta mesma pasta (`docs/`).

---

# 0. Plano até a entrega

**Entrega: sexta-feira, 23/10/2026**, com o código no GitHub e uma
gravação de tela do app rodando. Prioridades definidas em 20/10/2026,
seguindo as dependências entre as tarefas e o que a avaliação cobra
(os 20 RFs do relatório):

- 🔴 entra na entrega: base (P11 e P14 juntas, para o primeiro commit
  já sair limpo; depois F19, F20, P01, P02), as tarefas que completam os
  RFs e o README (P09);
- 🟡 e 🟢: só se sobrar tempo, na ordem da seção 0.2. O que não for
  feito fica documentado como "próximos passos".

Cada tarefa segue o passo a passo de `FLUXO_DE_TRABALHO.md` (testar,
commit, push, Pull Request, merge e testar de novo).

## 0.1 Cronograma

Duas pessoas. Cada uma faz a tarefa completa, do backend à tela, em uma
branch própria.

| Dia | Manuela (Pessoa A): base, visual e organizador | Bianca (Pessoa B): telas do participante |
|---|---|---|
| Ter 20/10 | **P11 (`.gitignore`)** → P14 (commit inicial) → **F19 (banco)** → **F20 parte 1 (base visual, com F11)** | F02 notificação local |
| Qua 21/10 | P01, P02, F08 | F01, F06 + F07 (uma tela só, "Avaliar") |
| Qui 22/10 | F14 (com upload de imagem), F09 | F05, F03, F04, F10 (telas de visualização, com dados no SQL) |
| Sex 23/10 | F20 parte 2 (telas restantes), S05 (dados de demonstração com datas futuras), P09 (README), revisão final | Folga para atrasos e itens da seção 0.2; gravação de tela no fim do dia |

- **Por que a P11 vem antes da P14:** a pasta nova ainda não tem
  nenhum commit, então os arquivos locais (`local.properties`,
  `ephemeral/` etc.) ainda não estão no Git. Criando o `.gitignore`
  antes do primeiro commit, eles nunca entram no repositório, e o
  projeto já começa com o padrão para todo mundo.
- **Sincronizações obrigatórias:**
  - **início de terça:** P11 e P14 no GitHub o quanto antes. A Bianca
    só consegue criar a branch da F02 a partir da `main` depois disso;
  - **fim de terça:** F19 e F20 parte 1 na `main`. Na quarta, a Bianca
    começa atualizando a branch a partir da `main`;
  - **quarta:** quando a P01 entrar na `main`, a Bianca atualiza a
    branch, e as rotas novas seguem o mesmo padrão de autenticação.
- **Mudanças da F19 que afetam a Bianca (20/10/2026):**
  - **recriar o banco local** com o script novo antes de começar a
    quarta (passo 1.4 do `FLUXO_DE_TRABALHO.md`);
  - **F06 e F07 viraram uma tela só ("Avaliar"):** a tabela `comentario`
    deixou de existir, e o comentário é agora um campo opcional da
    `avaliacao`, junto com as estrelas. A API `/api/comentarios` virou
    **`/api/avaliacoes`**, já pronta (criar, listar por palestra,
    atualizar e remover). Falta a tela e a média por palestra;
  - **palestrante, local, patrocinador:** as tabelas e Models já
    existem (F05, F04, F10). As tarefas criam as rotas e as telas;
  - a palestra continua devolvendo `sala` na API (agora vem da tabela
    `localizacao`), então as telas que já usam `sala` não mudam.
- **Mudança da P02 que afeta a Bianca (22/10/2026):** o login passou a
  recusar senhas sem hash, e os usuários de exemplo agora têm a senha
  `Senha@123`. Antes da próxima tarefa, **recriar o banco local** com o
  script novo (passo 1.4 do `FLUXO_DE_TRABALHO.md`); sem isso, o login
  com `hash123` deixa de funcionar.
- **Por que essa ordem:** a Pessoa A faz as tarefas que as outras usam
  como base (banco, visual, autenticação, área do organizador). A Pessoa
  B começa pelo que não depende de nada.
- **Por que a F11 foi para a Pessoa A:** a nova proposta visual já
  inclui o modo escuro, e as duas mexem no mesmo arquivo
  (`app_theme.dart`). Separadas, causariam conflito no Git. Com isso, a
  Bianca começa pela F02, que não depende do banco nem do tema e é a
  tarefa mais difícil da trilha dela, então ganha mais tempo.
- **Regra do visual:** depois da F20 parte 1, toda tela nova e toda tela
  existente que uma tarefa alterar já seguem o visual novo, usando o
  tema de `app_theme.dart` (nunca cores fixas). Na sexta, a Pessoa A
  passa as telas que ninguém alterou.
- **Telas do participante antes da F14:** F03, F04, F05 e F10 dependem
  da F14 só para o **cadastro** pelo organizador. As telas de
  visualização podem ser feitas antes, com dados colocados direto no SQL.
- **Atenção à carga:** a trilha da Pessoa A está mais cheia. Se atrasar,
  F09 e F10 são as primeiras a cair, e a Bianca pode assumir a F10 na
  sexta.
- **Antes da gravação:** a S05 precisa estar pronta. Sem eventos com
  datas futuras, nenhuma palestra aceita inscrição.
- 📌 **Lembrete para o fim (P09, README):** incluir no README o aviso de
  que o script `database/sistema_eventos_atualizado.sql` **apaga e
  recria** o banco inteiro (`DROP DATABASE`), inclusive dados reais, e
  por isso deve ser rodado **só na instalação**. Depois da entrega,
  mudanças no banco com dados reais devem ser feitas com scripts de
  migração (`ALTER TABLE`), sem recriar o banco.

## 0.2 Se sobrar tempo

Depois que todas as tarefas 🔴 estiverem na `main` e testadas, seguir
esta ordem. Primeiro as que melhoram a gravação e a avaliação, depois as
mais rápidas, por último as maiores.

| Ordem | Tarefa | Prioridade | Por que nessa posição |
|---|---|---|---|
| 1 | F16 Regras de inscrição (choque de horário e palestra iniciada) | 🟡 | Regra de negócio visível na gravação |
| 2 | F17 Logout e login lembrado | 🟡 | Melhora o uso do app na gravação |
| 3 | P04 Configuração de desenvolvimento exposta | 🟡 | Rápida e importante para a segurança |
| 4 | P03 Atualizações aceitam qualquer campo | 🟡 | Segurança no backend |
| 5 | P06 Fuso horário inconsistente | 🟡 | Horários corretos nos avisos e na agenda |
| 6 | P10 Comentário desatualizado na tela de favoritos | 🟢 | Poucos minutos |
| 7 | P07 Método obsoleto do SQLAlchemy | 🟢 | Poucos minutos |
| 8 | P05 Abas do app recarregam a cada troca | 🟢 | Pequena, no Flutter |
| 9 | P08 Tipo de notificação "atencao" | 🟢 | Pequena |
| 10 | F21 Marcar avisos como lidos (contador da barra) | 🟢 | Pequena; faz o contador de Avisos funcionar |
| 11 | F13 Restaurantes próximos | 🟢 | Tabela já existe |
| 12 | F12 Certificado de participação | 🟢 | Tabela criada na F19 |
| 13 | F15 Aviso de alteração de palestra | 🟢 | Depende da F14 |
| 14 | P12 Testes automatizados | 🟢 | Maior, mas protege as regras principais |
| 15 | F18 Entrar com Google | 🟢 | A mais trabalhosa (OAuth e Google Cloud) |
| 16 | F22 Perfil de administrador geral | 🟢 | Nenhum RF pede; tarefa de segurança, precisa de mais tempo |

A P13 não entra na lista: ela se resolve quando F03, F04, F08 e F13
forem feitas.

---

# 1. Funcionalidades a desenvolver

Fonte: `arq_ref/RELATÓRIO01_fluxo-3.pdf` (relatório de elicitação de
requisitos entregue ao professor). Comparação com o código feita em
19/10/2026.

## 1.1 Situação dos 20 requisitos funcionais (RF)

| RF | Requisito (resumo) | Situação | Tarefa |
|---|---|---|---|
| RF01 | Cadastro com e-mail e senha | Parcial: existe a rota `POST /api/usuarios`, mas não há tela | F01 |
| RF02 | Login | Concluído (com ressalvas de segurança: P01, P02) | — |
| RF03 | Programação geral do evento | Concluído | — |
| RF04 | Detalhes das palestras | Concluído | — |
| RF05 | Inscrição com controle automático de vagas | Concluído | — |
| RF06 | Cancelar inscrição | Concluído | — |
| RF07 | Favoritar palestras | Concluído | — |
| RF08 | Agenda personalizada | Concluído | — |
| RF09 | Notificações sobre o início das palestras | Parcial: o lembrete é só gravado, nada avisa o usuário | F02 |
| RF10 | Planta baixa do local | Parcial: só a tabela e a Model | F03 |
| RF11 | Rotas até salas e auditórios | Pendente: só a tabela `localizacao` (nome e descrição) | F04 |
| RF12 | Pesquisar palestras por tema | Concluído | — |
| RF13 | Pesquisar palestrantes pelo nome | Pendente: tabela `palestrante` criada na F19; faltam rota e tela | F05 |
| RF14 | Informações dos palestrantes | Pendente | F05 |
| RF15 | Comentários e feedbacks sobre palestras | Concluído | F06 |
| RF16 | Avaliar palestras por estrelas | Concluído | F07 |
| RF17 | Organizador gerencia inscrições | Concluído | F08 |
| RF18 | Organizador envia comunicados gerais | Pendente | F09 |
| RF19 | Patrocinadores do evento | Pendente: tabela `patrocinador` criada na F19; faltam rota e tela | F10 |
| RF20 | Modo claro e modo escuro | Pendente: o app só tem o tema claro | F11 |

**Resumo:** 11 concluídos, 3 parciais e 6 pendentes.

## 1.2 Tarefas

Cada tarefa tem um item **"Telas no canvas"** com os nomes das pranchas
que ela usa. O link abre o canvas inteiro (não é possível abrir direto
numa prancha): na página "Telas do projeto · opção 1 refinada", procure
o nome indicado, que aparece acima de cada tela.

| ID | RF | Prioridade | Funcionalidade | Status |
|---|---|---|---|---|
| F01 | RF01 | 🔴 | Tela de cadastro de usuário | Concluído |
| F02 | RF09 | 🔴 | Aviso real de início das palestras | Parcial |
| F03 | RF10 | 🔴 | Planta baixa do evento | Parcial |
| F04 | RF11 | 🔴 | Rotas até salas e auditórios | Pendente |
| F05 | RF13, RF14 | 🔴 | Palestrantes: busca e informações | Pendente |
| F06 | RF15 | 🔴 | Tela de comentários e feedbacks | Concluído |
| F07 | RF16 | 🔴 | Avaliação por estrelas | Concluído |
| F08 | RF17 | 🔴 | Área do organizador: gerenciar inscrições | Concluído |
| F09 | RF18 | 🔴 | Comunicados gerais do organizador | Pendente |
| F10 | RF19 | 🔴 | Patrocinadores do evento | Pendente |
| F11 | RF20 | 🔴 | Modo claro e escuro (feita dentro da F20) | Pendente |
| F12 | — (diagrama) | 🟢 | Certificado de participação | Pendente |
| F13 | — (Seção 1 e diagrama) | 🟢 | Restaurantes próximos (opcional para o organizador) | Pendente |
| F14 | — (S04) | 🔴 | Telas do organizador para cadastrar eventos e palestras | Pendente |
| F15 | RF09, RF18 | 🟢 | Aviso de alteração de palestra na aba Avisos | Pendente |
| F16 | — (S01, S02) | 🟡 | Regras de inscrição: choque de horário e palestra já iniciada | Pendente |
| F17 | — (S03) | 🟡 | Logout e login lembrado | Parcial |
| F18 | — (protótipo) | 🟢 | Entrar com Google | Pendente |
| F19 | — (D01) | 🔴 **primeira** | Atualizar o banco conforme a D01 | Concluído |
| F20 | RF20 (S06) | 🔴 **segunda** | Padronização da interface: aplicar a nova proposta visual (inclui a F11) | Em andamento |
| F21 | RF09, RF18 (S08) | 🟢 | Marcar avisos como lidos (contador da barra de navegação) | Pendente |
| F22 | — (sugestão na F08) | 🟢 | Perfil de administrador geral: promover organizadores pelo app | Pendente |

### F01 Tela de cadastro de usuário (RF01)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Cadastro (RF01)", "Login".
- **O que já existe:** a rota `POST /api/usuarios` cria o usuário com a
  senha protegida por hash.
- **O que falta:** a tela de cadastro no Flutter e um link para ela na
  tela de login.
- **Resolvido na P01 (21/10/2026):** o cadastro cria sempre um
  participante e ignora o `tipo_usuario` enviado. A tela não precisa
  (nem deve) mandar esse campo. A rota continua pública.
- **Concluído (21/10/2026):** tela "Criar conta" (link no login), com
  mostrar/ocultar nos dois campos de senha. Depois do cadastro, a pessoa
  já entra no app. O backend confere nome preenchido, e-mail em formato
  válido e senha de 8 a 16 caracteres, no cadastro e na
  atualização, com as regras num lugar só
  (`services/usuario/validacoes_usuario.py`). Registro em
  `DOCUMENTACAO.md`, seção 5.

### F02 Aviso real de início das palestras (RF09)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Notificação no celular (F02)", "Detalhes da palestra (RF04–RF07, RF11, RF15)", "Avisos (RF09, RF18, F15)".
- **O que já existe:** o botão "Ativar lembrete" grava um registro em
  `notificacao`, que aparece na aba Avisos.
- **O que falta:** avisar o usuário de fato quando a palestra estiver
  para começar. Hoje nada acontece no horário.
- **Decidido (20/10/2026):** notificação **local** na barra do celular
  (pacote `flutter_local_notifications`), aparecendo mesmo com o app
  fechado.
  - Só para quem ativou o lembrete, sempre 10 minutos antes do
    `horario_inicio`.
  - Ao ativar o lembrete, o app grava o registro no backend (como hoje)
    e agenda a notificação no celular. Ao desativar o lembrete ou
    cancelar a inscrição, cancela o agendamento.
  - Se faltarem menos de 10 minutos, o aviso aparece na hora ("começa em
    4 minutos"). Se a palestra já começou, o botão "Ativar lembrete" não
    aparece.
  - Se o horário da palestra mudar, o horário da notificação também
    muda: sempre que o app abre, confere os lembretes ativos e reagenda
    os que mudaram.
  - Ao tocar na notificação, o app abre os detalhes da palestra.
- **Descartado:** notificação push (Firebase Cloud Messaging). Exige
  conta no Firebase, guardar o identificador de cada celular e uma tarefa
  agendada no servidor, e nada do que foi pedido precisa que o servidor
  decida quando avisar.
- **Relacionado:** F15 (aviso de alteração na aba Avisos).

### F03 Planta baixa do evento (RF10)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Planta do local (RF10)", "Cadastro do evento e planta (F03, F14)".
- **O que já existe:** a tabela `planta_baixa` e a Model `PlantaBaixa`
  (imagem, descrição e evento).
- **O que falta:** a rota na API, a tela no app e a imagem real da planta.
- **Decidido (20/10/2026):** o organizador envia a imagem pelo app ao
  cadastrar o evento (o sistema serve para qualquer evento, sem mudar a
  interface). A imagem é salva em uma pasta do backend (`uploads/`) e o
  banco guarda só o nome do arquivo. O app escolhe a imagem com o pacote
  `image_picker`, envia em uma requisição multipart e exibe com
  `Image.network`. O backend valida o tipo e o tamanho do arquivo.
- **Mesma solução para:** a foto do palestrante (F05) e o logo do
  patrocinador (F10).
- **Depende de:** F14 (telas de cadastro do organizador).

### F04 Rotas até salas e auditórios (RF11)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Detalhes da palestra (RF04–RF07, RF11, RF15)", "Planta do local (RF10)", "Cadastro de local e rota (F04)".
- **O que já existe:** a tabela `localizacao` (nome do local, descrição e
  evento) e, desde a F19, `palestra.id_localizacao`. As antigas salas em
  texto viraram registros de `localizacao`, e a API continua devolvendo
  o nome do local no campo `sala`.
- **O que falta:** definir o que é uma "rota" no app, guardar esses dados,
  criar a API e a tela.
- **Decidido (D01):** `palestra` passa a apontar para `localizacao`
  (`id_localizacao`), como no diagrama. As salas hoje gravadas como texto
  em `palestra.sala` viram registros em `localizacao`.
- **Decidido (20/10/2026):** a rota é um passo a passo em texto, a
  partir da entrada do evento, escrito pelo organizador para cada local
  (campo `localizacao.descricao`, que já está no diagrama). Nos detalhes
  da palestra, o participante vê o local, o passo a passo e um botão
  "Ver planta" (F03).
- **Descartado:** caminho desenhado na planta (complexo demais) e link
  para mapas externos (não funciona dentro de prédios). Marcar as salas
  na planta pode virar melhoria futura.
- **Depende de:** F14 (telas de cadastro do organizador).

### F05 Palestrantes: busca e informações (RF13, RF14)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Palestrantes (RF13)", "Perfil do palestrante (RF14)", "Detalhes da palestra (RF04–RF07, RF11, RF15)", "Cadastro de palestrante (F05)".
- **O que já existe (F19):** a tabela `palestrante`, a Model e
  `palestra.id_palestrante`, com dois palestrantes de exemplo. O tipo
  `'palestrante'` saiu de `usuario`.
- **O que falta:** um lugar para guardar os dados do palestrante (bio,
  foto etc.), a ligação entre palestra e palestrante, a busca por nome,
  a tela de perfil e a exibição do palestrante nos detalhes da palestra.
- **Decidido (20/10/2026):** criar a tabela `palestrante` (`nome`,
  `foto`, `descricao`, `rede_social`), sem login. Cada palestra aponta
  para um palestrante (`palestra.id_palestrante`). No app, os dados
  aparecem em um modal a partir dos detalhes da palestra.
- **Justificativa para a documentação:** o diagrama não tem onde guardar
  os dados do palestrante pedidos pelos RF13 e RF14. Uma tabela própria
  evita repetir os dados quando a mesma pessoa dá mais de uma palestra.
- **Decidido:** um palestrante por palestra. Vários palestrantes só
  fariam sentido com outros tipos de atividade, como workshop (ver S07).
- **Decidido:** o valor `tipo_usuario = 'palestrante'` sai de `usuario`
  (ficam `participante` e `organizador`). A usuária de exemplo Carla
  Souza, hoje palestrante, precisa ser ajustada no SQL.
- **Decidido:** a foto é enviada pelo organizador e salva no backend,
  com a mesma solução da F03.

### F06 Tela de comentários e feedbacks (RF15)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Detalhes da palestra (RF04–RF07, RF11, RF15)", "Avaliar palestra (RF16)".
- **Decidido na F19 (20/10/2026):** a tabela `comentario` deixou de
  existir. O comentário é um campo opcional da `avaliacao`, enviado junto
  com as estrelas na tela "Avaliar". Por isso, **F06 e F07 são feitas
  juntas**.
- **O que já existe:** a API completa de avaliações (`/api/avaliacoes`):
  `POST /api/avaliacoes`, `GET /api/avaliacoes/palestra/<id>` (já com o
  nome do autor), `PATCH` e `DELETE /api/avaliacoes/<id>`.
- **O que falta:** mostrar os comentários na tela de detalhes da palestra
  e a tela "Avaliar".
- **Atenção:** relacionado a P01 (qualquer um pode editar ou apagar a
  avaliação de outra pessoa enquanto não houver autenticação).
- **Concluído (22/10/2026), junto com a F07:** os comentários aparecem
  nos Detalhes (autor, nota e data), e a tela "Avaliar" envia o
  comentário junto com as estrelas. A P01 resolveu o ponto de atenção:
  só o autor edita, e o autor ou um organizador remove.

### F07 Avaliação por estrelas (RF16)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Avaliar palestra (RF16)", "Detalhes da palestra (RF04–RF07, RF11, RF15)".
- **O que já existe (F19):** a tabela `avaliacao` (`nota_estrelas` de 1
  a 5, `comentario` opcional) e a API `/api/avaliacoes`. O backend recusa
  nota fora de 1 a 5 e uma segunda avaliação da mesma pessoa para a
  mesma palestra (para mudar a nota, usa-se o `PATCH`).
- **O que falta:** a média por palestra e a exibição no app (feita junto
  com a F06, na tela "Avaliar").
- **Decidido (22/10/2026):** só quem está inscrito avalia, e só a partir
  do `horario_inicio` da palestra (hora local do servidor). A regra fica
  no backend (`motivo_para_nao_avaliar`, em
  `criar_avaliacao_service.py`), e os detalhes devolvem `pode_avaliar`
  para o app esconder o botão. Se a pessoa cancelar a inscrição depois
  de avaliar, a avaliação continua. A média é calculada no SQL (`AVG`) e
  vem na listagem de palestras e nos detalhes.
- **Concluído (22/10/2026), junto com a F06:** tela "Avaliar" (criar,
  editar e excluir a própria avaliação), seção "Avaliações e
  comentários" nos Detalhes e média nos cards da Programação. As telas
  de Detalhes e o card da Programação passaram para o visual novo.

### F08 Área do organizador: gerenciar inscrições (RF17)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Perfil — organizador (F08)", "Área do organizador", "Inscrições (RF17)".
- **O que já existe:** a tabela `organizador` (com `nivel_acesso`) e um
  organizador de exemplo (Bruno Costa).
- **O que falta:** reconhecer o organizador no login, ver a lista de
  inscritos de cada palestra, gerenciar inscrições e criar as telas
  correspondentes.
- **Depende de:** P01 (autenticação), para que só organizadores acessem
  essas funções.
- **Decidido (20/10/2026):** a entrada "Área do organizador" fica no
  Perfil e aparece **só** para organizadores. Participantes não veem a
  opção.
- **Decidido (22/10/2026):**
  - o app reconhece o organizador pelo `tipo_usuario` que o login já
    devolve. Os organizadores continuam sendo criados pelo banco; criar
    pelo app virou a F22;
  - a "Área do organizador" é um painel do evento: palestras, inscrições,
    esgotadas, ocupação das vagas (%) e média das avaliações, mais o
    ranking das palestras (inscritos/vagas e média de cada uma);
  - gerenciar inscrições = ver os inscritos de cada palestra (com busca)
    e remover uma inscrição, com confirmação antes. A remoção usa o mesmo
    `CancelarInscricaoService` do participante (a vaga volta) e grava um
    aviso do tipo `atencao` para a pessoa removida;
  - **cada evento tem um só organizador responsável**
    (`evento.id_organizador`). O organizador vê e gerencia só os
    próprios eventos (painel, inscrições, evento, palestras e moderação
    de avaliações); o administrador (`nivel_acesso = 'administrador'`)
    vê e gerencia todos. Quem cria o evento (`POST /api/eventos`) vira o
    responsável, e o responsável não pode ser trocado pela API;
  - fluxo previsto: o administrador cria o organizador (F22; até lá, pelo
    banco) e o organizador cria o evento, que já fica ligado a ele (F14);
  - o painel mostra só os eventos da pessoa. Com mais de um, aparece o
    seletor "Trocar evento" do canvas.
- **Concluído (22/10/2026):** rotas `/api/organizador/...` (meus
  eventos, painel, inscritos e remover, só para organizadores e só nos
  próprios eventos) e as telas "Área do organizador" e "Inscrições". No
  painel, o comunicado (F09) e os cadastros (F14) aparecem como "Em
  breve". No banco, a coluna `evento.id_organizador` e a organizadora de
  exemplo Elisa Prado (evento 2). Junto, o botão **Sair** do Perfil
  (parte da F17), por decisão da Manuela de fazer na mesma branch.
  Ajustes da revisão: listar, ver e remover contas de outras pessoas
  ficou só para o administrador; quem é responsável por eventos não pode
  ser removido; a atualização de evento e de palestra aceita só uma
  lista de campos permitidos (avanço na P03).

### F09 Comunicados gerais do organizador (RF18)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Enviar comunicado (RF18)", "Avisos (RF09, RF18, F15)".
- **O que já existe:** a tabela `notificacao`, mas ela exige
  `id_palestra`. Um comunicado geral não pertence a uma palestra.
- **O que falta:** um lugar no banco para o comunicado, a rota para o
  organizador enviar e a exibição na aba Avisos.
- **Decidido (D01):** a tabela `mensagem` do diagrama não será criada.
  O comunicado usa a tabela `notificacao`, adaptada para aceitar
  notificações sem palestra (`id_palestra` opcional).
- **Depende de:** F08 e P01.

### F10 Patrocinadores do evento (RF19)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Patrocinadores (RF19)", "Cadastro de patrocinador (F10)".
- **O que já existe (F19):** a tabela `patrocinador` (nome da empresa,
  logo, site e descrição, ligada ao evento), a Model e um patrocinador
  de exemplo.
- **O que falta:** a API e a tela.
- **Decidido (D01):** criar a tabela `patrocinador` seguindo o diagrama.
- **Decidido:** o logo é enviado pelo organizador e salvo no backend,
  com a mesma solução da F03.

### F11 Modo claro e escuro (RF20)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Perfil — participante (RF20, F17)", "Início — modo escuro", "Detalhes — modo escuro".
- **O que já existe:** um tema claro centralizado em
  `frontend/Flutter/lib/theme/app_theme.dart`, o que facilita criar o
  tema escuro.
- **O que falta:** o tema escuro e um botão para alternar entre os dois.
- **Atenção:** algumas telas usam cores fixas fora do tema (por exemplo,
  a splash e a tela de detalhes), e elas precisarão ser revistas.
- **Decidido (D01):** sem o campo `tema_preferido` no banco. A escolha
  do tema fica guardada no próprio celular.

### F12 Certificado de participação (diagrama do relatório)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Certificados (F12)".
- **O que já existe (F19):** a tabela `certificado` (`id_usuario`,
  `id_evento`, `codigo_validacao` único, `data_emissao`, sem o campo sem
  nome `Atributo_1`) e a Model. Cada usuário tem no máximo um
  certificado por evento.
- **O que falta:** a API e a tela.
- **Decidido (D01):** o certificado é emitido para quem participou do
  evento. Garantir a vaga em uma palestra (inscrição) vale como
  confirmação de presença, então não há lista de presença separada.
- **Decisão necessária (ao planejar):** quando o certificado fica
  disponível (ao fim do evento?), como é entregue (tela no app, PDF) e
  como o código de validação é conferido.

### F13 Restaurantes próximos (Seção 1 e diagrama do relatório)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Onde comer (F13, opcional)". A tela de cadastro de restaurantes do organizador ainda não foi desenhada.
- **O que já existe:** as tabelas `restaurante` (nome, endereço,
  categoria, distância, avaliação) e `restaurante_evento`, e as Models.
  Não há API nem tela.
- **O que falta:** o organizador poder cadastrar restaurantes no evento
  e o participante poder vê-los no app.
- **Decidido:** a funcionalidade é opcional para o organizador. Se o
  evento não tiver restaurantes cadastrados, o app não mostra a seção.
- **Não é um dos 20 RFs:** registrar isso na documentação final.
- **Depende de:** F08 e P01 (área do organizador).

### F14 Telas do organizador para cadastrar eventos e palestras (S04)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Área do organizador", "Cadastro do evento e planta (F03, F14)", "Cadastro de palestra (F14)", "Cadastro de local e rota (F04)", "Cadastro de palestrante (F05)", "Cadastro de patrocinador (F10)", "Componente: formulário do organizador".
- **O que já existe:** a API de CRUD de eventos e palestras. Hoje um
  evento só pode ser criado direto no banco.
- **O que falta:** as telas no app para o organizador cadastrar e editar
  o evento (com a planta baixa, F03), os locais com o passo a passo da
  rota (F04), as palestras com o palestrante (F05) e os patrocinadores
  (F10).
- **Por que é necessária:** o sistema serve para qualquer evento sem
  mudar a interface, então tudo o que é do evento precisa ser cadastrado
  pelo organizador no app.
- **Já pronto na F08 (22/10/2026):** o evento criado por
  `POST /api/eventos` fica ligado a quem o criou, e só esse organizador
  (ou um administrador) altera o evento e as palestras dele. As rotas
  novas desta tarefa (locais, planta, palestrantes, patrocinadores)
  devem usar `verificar_dono_do_evento` (em
  `controllers/autenticacao.py`) do mesmo jeito.
- **Depende de:** P01 e F08.

### F15 Aviso de alteração de palestra na aba Avisos

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Avisos (RF09, RF18, F15)".
- **O que falta:** quando o organizador alterar o local, o horário ou
  outro dado de uma palestra, os inscritos recebem um aviso na aba
  Avisos do app.
- **Decidido (20/10/2026):** o aviso aparece só dentro do app, na aba
  Avisos (não na barra do celular). Fica para depois das tarefas
  principais.
- **Decisão necessária (ao planejar):** quem recebe (todos os inscritos
  ou só quem ativou o lembrete) e quais alterações geram aviso.
- **Depende de:** F14 (edição da palestra pelo organizador) e F09
  (`notificacao` adaptada).

### F16 Regras de inscrição: choque de horário e palestra já iniciada (S01, S02)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Aviso de choque de horário (F16)", "Detalhes da palestra (RF04–RF07, RF11, RF15)".
- **O que acontece hoje:** é possível se inscrever em duas palestras no
  mesmo horário e em palestras que já começaram ou terminaram.
- **Decidido (20/10/2026):**
  - **Choque de horário (S01):** a inscrição **não é bloqueada**. O app
    mostra um modal: "Você já tem inscrição em uma palestra nesse
    horário. Deseja mesmo se inscrever nesta?". Se a pessoa confirmar, a
    inscrição é feita. O texto é neutro para não presumir o gênero de
    quem usa o app (ajustado em 20/10/2026).
  - **Palestra já iniciada ou encerrada (S02):** a inscrição é
    bloqueada pelo backend, e o app não mostra o botão de inscrição.
- **Onde:** no Service que cria a inscrição (`CriarInscricaoService`) e
  na tela de detalhes da palestra.
- **Decisão necessária (ao planejar):** como o app informa ao backend
  que a pessoa já confirmou o choque de horário.

### F17 Logout e login lembrado (S03)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Login", "Perfil — participante (RF20, F17)".
- **O que acontece hoje:** o app não tem botão de sair e pede o login
  toda vez que é aberto.
- **O que falta:** um botão "Sair" e manter a pessoa conectada ao
  reabrir o app, até ela sair.
- **Relacionado:** P01 (autenticação). Desde a P01, o login devolve um
  token que vale 8 horas e fica só na memória (`ApiService.token`).
  Manter o login é guardar esse token no aparelho e, no "Sair", apagá-lo.
- **Decidido (21/10/2026):** quando a API responder 401 (token vencido
  ou inválido), o app deve voltar sozinho para a tela de login. Hoje a
  tela só mostra a mensagem "Sessão expirada ou inválida".
- **Parcial (22/10/2026, feito na branch da F08):** o botão **Sair** do
  Perfil apaga o token e volta para o login, sem deixar "voltar" com o
  botão do celular. Falta manter o login ao reabrir o app e a volta
  automática ao login no 401.

### F18 Entrar com Google

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Login", "Cadastro (RF01)".
- **Origem:** o protótipo do Figma tinha login social (Google, GitHub e
  Facebook). A equipe decidiu manter só o Google (20/10/2026).
- **O que acontece hoje:** só existe login com e-mail e senha.
- **O que falta:** o botão "Continuar com Google" no login, a
  configuração do projeto no Google Cloud (credenciais OAuth) e uma rota
  no backend que confirme a identidade enviada pelo Google e crie ou
  encontre o usuário correspondente.
- **Banco já preparado (F19, 20/10/2026):** `usuario.senha` aceita vazio
  (quem entra pelo Google não tem senha) e existe `usuario.google_id`
  (único). O login por e-mail e senha já recusa usuários sem senha. Se a
  F18 for feita, não precisa mexer no banco.
- **Ícones já no app (F01, 21/10/2026):** a fileira de ícones sociais
  saiu do login na F01, mas as imagens `faceIcon.png`, `googleIcon.png`
  e `gitIcon.png` continuam em `assets/images/`. Na F18, usar o
  `googleIcon.png` no botão "Continuar com Google" e apagar os outros
  dois, que não serão usados.
- **Atenção:** é a tarefa nova mais trabalhosa. Envolve configuração
  fora do código (Google Cloud) e um conceito novo, o OAuth, que precisa
  ser bem explicado. Com a entrega em 23/10/2026, a prioridade deve ser
  decidida pela equipe.
- **Relacionado:** P01 (autenticação) e F17 (login lembrado).

### F19 Atualizar o banco conforme a D01 (prioridade máxima)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** nenhuma. A tarefa mexe só no banco.
- **Por que existe:** as decisões da D01, F05 e F09 mudam várias tabelas
  do mesmo arquivo SQL e várias Models. Se cada pessoa mudasse o banco
  dentro da própria tarefa, as duas editariam os mesmos arquivos ao mesmo
  tempo e o Git acusaria conflito. Por isso, todas as mudanças são feitas
  de uma vez, por uma pessoa só (Pessoa A), antes das outras tarefas que
  usam o banco.
- **O que muda** (`database/sistema_eventos_atualizado.sql` e
  `backend/models/`):
  - criar `palestrante` (`nome`, `foto`, `descricao`, `rede_social`) e
    `palestra.id_palestrante` (F05);
  - criar `avaliacao` (`nota_estrelas`, `comentario`, `id_usuario`,
    `id_palestra`) e remover `comentario.nota` (F07);
  - criar `patrocinador` (`nome_empresa`, `logo`, `site`, `descricao`,
    `id_evento`) (F10);
  - criar `certificado` (`id_usuario`, `id_evento`, `codigo_validacao`,
    `data_emissao`), sem `Atributo_1`. Só a tabela e a Model: a
    funcionalidade (F12) fica para depois, mas o banco já fica fiel ao
    diagrama;
  - ligar `palestra` a `localizacao` (`palestra.id_localizacao`),
    transformando os textos de `palestra.sala` em registros de
    `localizacao` (F04);
  - deixar `notificacao.id_palestra` opcional (F09);
  - remover o valor `'palestrante'` de `tipo_usuario` e ajustar a
    usuária de exemplo Carla Souza (F05).
- **Decidido (20/10/2026):**
  - a tabela `comentario` deixa de existir: o comentário fica só em
    `avaliacao`, junto com as estrelas. A API de comentários foi adaptada
    para `/api/avaliacoes`, para a F06/F07 já começar com o backend
    pronto;
  - uma avaliação por pessoa e palestra (chave única), como em inscrição
    e favorito, para a média não ser distorcida;
  - o exemplo antigo (nota 9,5 de 10) virou 5 estrelas;
  - preparo para a F18, sem implementá-la: `usuario.senha` aceita vazio e
    existe `usuario.google_id`. O login por e-mail e senha recusa quem
    não tem senha.
- **Concluído (20/10/2026).** Quem já tinha o banco local precisa
  recriá-lo com o script novo.
- **Depende de:** P14 (commit da versão atual, para ter um ponto seguro
  antes de mexer no banco).

### F20 Aplicar a nova proposta visual (S06, inclui a F11)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** a página inteira "Telas do projeto ·
  opção 1 refinada", com destaque para "Identidade visual",
  "Componente: barra de navegação" e os modos escuros.
- **Origem:** a nova proposta visual (S06), definida pela Manuela em
  outra conversa, que corrige problemas do protótipo do Figma e já
  inclui o modo escuro (RF20).
- **Responsável:** Pessoa A (Manuela).
- **Referência visual:** a página "Telas do projeto · opção 1 refinada"
  do [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt), com
  todas as telas do projeto. O resumo da identidade (fontes, paleta,
  estilo e navegação) está no `CLAUDE.md`, seção "Identidade visual".
- **Parte 1 (terça, base):** cores, fontes, tema claro e tema escuro em
  `frontend/Flutter/lib/theme/app_theme.dart`, os componentes
  compartilhados em `lib/widgets/` e o botão para alternar o tema, com a
  escolha salva no celular (F11). Precisa estar na `main` até o fim de
  terça, porque as telas novas da Bianca já são feitas sobre ela.
- **Parte 2 (sexta, telas restantes):** aplicar o visual nas telas que
  nenhuma outra tarefa alterou (por exemplo, splash, home, programação,
  agenda e favoritos). As cores dessas telas já foram trocadas pelas do
  tema na parte 1 (o modo escuro funciona nelas); falta o layout.
- **Regra para as outras tarefas:** toda tela nova, ou tela existente
  alterada por uma tarefa, já segue o visual novo, usando o tema (nunca
  cores fixas).
- **Diferença em relação ao relatório:** o visual muda em relação ao
  protótipo do Figma entregue. Registrar o motivo em `DOCUMENTACAO.md`.

### F21 Marcar avisos como lidos (contador da barra)

- **Telas no [canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt):** "Componente: barra de navegação", "Avisos (RF09, RF18, F15)".
- **Origem:** sugestão S08, aprovada em 20/10/2026 durante a F20.
- **O que já existe:** a `BarraNavegacao` (F20 parte 1) já mostra um
  contador na aba Avisos quando recebe um número maior que zero.
- **O que falta:** a tabela `notificacao` não tem um campo que diga se o
  aviso já foi lido, então hoje não há como contar os avisos novos.
  Falta o campo no banco (com script de migração, sem recriar o banco),
  uma rota para marcar como lido (por exemplo, ao abrir a aba Avisos) e
  passar a contagem para a barra no `app_shell.dart`.

### F22 Perfil de administrador geral

- **Origem:** sugestão da Manuela durante o planejamento da F08, aprovada
  em 22/10/2026.
- **O que já existe:** os organizadores são criados direto no banco
  (decisão da P01, `DOCUMENTACAO.md` seção 4), e a tabela `organizador`
  já tem o campo `nivel_acesso` (o Bruno Costa está como
  `administrador`).
- **O que falta:** um administrador (`nivel_acesso = 'administrador'`)
  promover participantes a organizadores pelo app (e tirar a permissão),
  sem precisar abrir o MySQL. A promoção precisa atualizar os dois
  registros juntos: `usuario.tipo_usuario` e a tabela `organizador`.
- **Por que ficou para depois:** nenhum dos 20 RFs pede essa função, e a
  entrega é em 23/10/2026. É uma tarefa de segurança (quem pode dar
  permissão a quem), então precisa de `/security-review` e de mais tempo.
  Entra na documentação final como "próximos passos".
- **O que o administrador já faz (F08):** vê e gerencia todos os eventos
  (painel, inscrições, evento, palestras e avaliações), com o seletor
  "Trocar evento". O que for exclusivo dele fica nesta tarefa.
- **Sugestão (22/10/2026):** uma visão consolidada só para o
  administrador, com os números de todos os eventos somados (total de
  inscrições do sistema, eventos mais procurados).

## 1.3 Itens do relatório fora da lista de requisitos (decidir)

Estes itens aparecem na Seção 1 (tabela de observação), na análise das
respostas ou no diagrama do banco, mas **não** estão entre os 20
requisitos. A equipe precisa decidir se entram na entrega.

| Item | Onde aparece no relatório | O que existe hoje | Decisão |
|---|---|---|---|
| Lista de presença digital | Seção 1 e análise das respostas | Nada | Atendida pela inscrição (D01) |
| Sugestão de restaurantes próximos | Seção 1 | Tabelas `restaurante` e `restaurante_evento`, sem API nem tela | Entra como opcional para o organizador: F13 |
| Certificado (com código de validação) | Diagrama do banco | Nada | Entra: F12 (D01) |
| Tema preferido do usuário (`tema_preferido`) | Diagrama do banco | Nada | Não entra no banco (D01) |
| Recomendação de palestras | Seção 1 (atendida pela classificação por tema, RF12) | Busca por tema | Atendida pelo RF12; nada a fazer |

## 1.4 Decisões pendentes

Questões que precisam de uma decisão da equipe antes de virarem tarefa.

| ID | Decisão | Status |
|---|---|---|
| D01 | Banco atual × diagrama do relatório | Decidido (20/10/2026) |

### D01 Banco atual × diagrama do relatório

- **Contexto:** o banco atual (`database/sistema_eventos_atualizado.sql`)
  não segue exatamente o diagrama da Seção 5 do relatório. As diferenças
  tinham sido consideradas aprovadas, mas a questão foi reaberta para uma
  decisão formal.
- **Diferenças encontradas:**

| Diagrama do relatório | Banco atual |
|---|---|
| Tem `patrocinador` (nome da empresa, logo, site, descrição) | Não tem |
| Tem `avaliacao` (`nota_estrelas`, `comentario`) | Não tem; existe só `comentario.nota` |
| Tem `mensagem` (remetente, destinatário, conteúdo) | Não tem |
| Tem `certificado` (com um campo sem nome, `Atributo_1`) | Não tem |
| `usuario` tem `tema_preferido` | Não tem |
| Liga `palestra` a `localizacao` | Não liga; a sala é só texto |
| Não tem `favorito` | Tem `favorito` (criado para o RF07) |
| `palestra` sem controle de vagas | `palestra` tem `vagas_total` e `vagas_disponiveis` (RF05) |

- **Tarefas afetadas pela decisão:** F04 (rotas e localização), F07
  (avaliação), F09 (comunicados), F10 (patrocinadores) e os itens
  "certificado" e "tema preferido" da seção 1.3.
- **Por que importa:** o professor recebeu o diagrama. Se o banco entregue
  for diferente sem justificativa, isso pode ser questionado na avaliação.
- **Decisão (20/10/2026):** misto, item por item.

| Item | Decisão | Justificativa para a documentação final |
|---|---|---|
| `patrocinador` | Seguir o diagrama (criar) | Necessária para o RF19 (F10) |
| `avaliacao` | Seguir o diagrama (criar) e remover `comentario.nota` | Avaliação por estrelas do RF16 (F07), com a nota em um lugar só |
| `mensagem` | Não criar | Nenhum requisito pede troca de mensagens entre usuários. Os comunicados do RF18 usam `notificacao` (F09) |
| `certificado` | Seguir o diagrama (criar), sem `Atributo_1` | Certificado para quem participou do evento (F12) |
| `usuario.tema_preferido` | Não criar | A escolha do tema (RF20) fica salva no celular |
| `palestra` → `localizacao` | Seguir o diagrama (ligar) | Base para as rotas do RF11 (F04) |
| `favorito` | Manter o banco atual | Necessária para o RF07. Incluir no diagrama da documentação final |
| Vagas em `palestra` | Manter o banco atual | Necessárias para o RF05. Incluir no diagrama da documentação final |

- **O diagrama não muda:** ele já foi entregue e é a base da avaliação.
  As diferenças acima ficam registradas, com a justificativa de cada
  uma, na documentação final, em uma seção como "Ajustes na modelagem
  durante o desenvolvimento". Seguir o diagrama à risca não é possível:
  ele não tem `favorito` (RF07) nem os campos de vagas (RF05).
- **Restaurantes:** a tabela `restaurante` segue o diagrama e é mantida.
  Ver F13.

## 1.5 Observações

- **Banco × diagrama do relatório:** decidido na D01. O diagrama é a
  referência de modelagem para as tabelas que serão criadas
  (`patrocinador`, `avaliacao`, `certificado`).
- **Ordem de dependência:** algumas tarefas precisam de outras prontas
  antes.
  - P01 (autenticação) vem antes de F08 (organizador) e F09 (comunicados).
  - F08 vem antes de F09.
  - F05 (palestrantes) precisa ter a modelagem definida antes de
    programar, porque nem o banco nem o diagrama têm essa entidade.
  - F03 (planta baixa) e F04 (rotas) se complementam e podem ser
    pensadas juntas.
- **Protótipo no Figma:** o link do relatório não pode ser acessado pelo
  Claude Code. As telas devem ser exportadas para `arq_ref/` para servir
  de referência visual.

## 1.6 Sugestões aguardando aprovação

Ideias que **não estão no relatório**. Ficam aqui até serem aprovadas.
Uma sugestão aprovada vira uma tarefa F; uma recusada é marcada como tal.

| ID | Sugestão | Por que vale a pena | Situação |
|---|---|---|---|
| S01 | Bloquear inscrição em palestras com choque de horário | Hoje é possível se inscrever em duas palestras no mesmo horário. É uma regra simples no `CriarInscricaoService` e fácil de demonstrar | Aprovada com ajuste (avisar em vez de bloquear): virou F16 |
| S02 | Bloquear inscrição em palestra que já começou ou terminou | Mesma lógica da S01, no mesmo Service | Aprovada: virou F16 |
| S03 | Logout e login lembrado | O app não tem botão de sair e pede o login toda vez que é aberto | Aprovada: virou F17 |
| S04 | Telas para o organizador cadastrar eventos e palestras | A API já existe, mas hoje só dá para criar um evento direto no banco. Completa a área do organizador (F08) | Aprovada: virou F14 |
| S05 | Mais dados de demonstração no banco | Com só 2 palestras, a apresentação não mostra bem o controle de vagas, a busca e a agenda | Adiada: a equipe ajusta os dados depois (antes da apresentação, os eventos de exemplo precisam ter datas futuras) |
| S06 | Nova proposta visual para o app ([canvas](https://claude.ai/artifact/Eh68uUe4Q6xuAwYuT5UVvt)) | Corrige problemas do protótipo do Figma: contraste, fontes misturadas, menu duplicado, telas sem informações essenciais (vagas, botão de inscrição) e textos em inglês. Já inclui o modo escuro (RF20) | Aprovada: definida pela Manuela em outra conversa, aplicada na F20 |
| S07 | Outros tipos de atividade além de palestra (workshop, mesa-redonda), com mais de um palestrante por atividade | Amplia o uso do app para eventos variados. Fica fora desta entrega porque nenhum RF pede e o diagrama não prevê | Melhoria futura: só registrar na documentação final |
| S08 | Marcar avisos como lidos | Sem isso, o contador de avisos novos da barra de navegação (canvas) não tem o que contar | Aprovada: virou F21 |

---

# 2. Problemas e melhorias

Lista levantada na análise completa do projeto (backend, frontend e banco)
em 19/10/2026. Cada item diz **onde** está o problema, **o que** acontece e
**por que** isso importa. As soluções ainda serão discutidas antes de
qualquer alteração.

| ID | Prioridade | Tema | Status |
|---|---|---|---|
| P01 | 🔴 | Rotas da API sem autenticação | Concluído |
| P02 | 🔴 | Login aceita senha em texto puro | Concluído |
| P03 | 🟡 | Atualizações aceitam qualquer campo | Pendente |
| P04 | 🟡 | Configuração de desenvolvimento exposta | Pendente |
| P05 | 🟢 | Abas do app recarregam a cada troca | Pendente |
| P06 | 🟡 | Fuso horário inconsistente | Pendente |
| P07 | 🟢 | Uso de método obsoleto do SQLAlchemy | Pendente |
| P08 | 🟢 | Tipo de notificação "atencao" nunca é criado | Parcial |
| P09 | 🔴 | README desatualizado | Pendente |
| P10 | 🟢 | Comentário desatualizado na tela de favoritos | Pendente |
| P11 | 🔴 **antes da P14** | Arquivos locais versionados e falta de `.gitignore` | Concluído |
| P12 | 🟢 | Projeto sem testes automatizados | Pendente |
| P13 | 🟢 | Tabelas sem uso no app | Decidido: todas terão uso (F03, F04, F08, F13) |
| P14 | 🔴 | Versão antiga e nova sem commit | Concluído |
| P15 | 🟡 | Botão de inscrição não mostra o estado da inscrição | Concluído |
| P16 | 🟡 | Fim de linha diferente entre sistemas (falta `.gitattributes`) | Pendente |
| P17 | 🟡 | Versão do Flutter não definida (`pubspec.lock` muda em cada máquina) | Pendente |

---

## Segurança e regras de negócio

### P01 🔴 Rotas da API sem autenticação

- **Onde:** todos os controllers em `backend/controllers/`, e
  `backend/controllers/auth_controller.py`.
- **O que acontece:** o login grava `id_usuario` na sessão do Flask, mas
  nenhuma rota confere essa sessão. As rotas confiam no `id_usuario`
  enviado no corpo ou na URL da requisição. Também não há diferença entre
  participante e organizador.
- **Por que importa:** qualquer pessoa com acesso à API pode se passar por
  outro usuário, inscrever ou desinscrever outras pessoas, e até criar,
  editar ou apagar eventos, palestras e usuários.
- **Concluído (21/10/2026):** autenticação por **token** assinado com o
  `itsdangerous`, que já vem com o Flask (`services/auth/token_service.py`).
  O login devolve o token, que vale 8 horas, e o app o envia no
  cabeçalho `Authorization: Bearer <token>` (`ApiService.token`). Os
  decorators `@login_obrigatorio` e `@somente_organizador`
  (`controllers/autenticacao.py`) protegem as rotas. Só login, cadastro e
  logout são públicos. O usuário vem sempre do token, e um `id_usuario`
  no corpo é ignorado. Nas rotas com `<id_usuario>` na URL, só a própria
  pessoa tem acesso. Avaliação: editar, só o autor; remover, o autor ou
  um organizador. Ninguém escolhe o próprio perfil: o cadastro cria
  sempre participante, o `PUT` ignora `tipo_usuario`, e organizadores
  são criados direto no banco. A tabela de acesso está no README
  (seção 7).
- **Para a Bianca (e para toda rota nova):** colocar `@tratar_erros` e,
  logo abaixo, `@login_obrigatorio` (ou `@somente_organizador`). Usar
  `g.usuario.id_usuario`, nunca `dados.get("id_usuario")`. A tela de
  cadastro (F01) não manda `tipo_usuario`.
- **Limitação:** o logout só apaga o token no app. Um token copiado
  antes continua valendo até vencer (mesmo se a pessoa trocar a senha),
  porque a API não guarda uma lista de tokens. Fica como próximo passo.
- **Ajustes da revisão (`/code-review`):** a atualização de usuário
  aceita só `nome`, `email` e `senha` (lista de campos permitidos) e
  recusa senha vazia; só a própria pessoa altera a conta (um organizador
  não troca a senha de outra pessoa); `TIPO_ORGANIZADOR` e
  `TIPO_PARTICIPANTE` ficam na Model `Usuario`.

### P02 🔴 Login aceita senha em texto puro

- **Onde:** `backend/services/auth/autenticar_usuario_service.py`,
  dados de exemplo no SQL e `frontend/Flutter/lib/pages/login_page.dart`.
- **O que acontece:** se a senha guardada no banco não for um hash, o
  login compara o texto diretamente. Os usuários de exemplo têm senhas
  como `hash123` salvas em texto puro. A tela de login já abre com o email
  e a senha da Ana preenchidos.
- **Por que importa:** senha nunca deve ser guardada em texto puro. Se o
  banco vazar, todas as senhas ficam expostas. Credenciais preenchidas no
  app também não são aceitáveis numa versão final.

### P03 🟡 Atualizações aceitam qualquer campo

- **Onde:** `backend/services/usuario/atualizar_usuario_service.py`
  (e, em menor grau, os services de atualizar evento e palestra) e o
  método `atualizar` de `backend/models/crud_mixin.py`.
- **O que acontece:** o JSON recebido é repassado inteiro para a Model.
  Isso permite, por exemplo, mudar o `tipo_usuario` de alguém ou alterar
  `vagas_disponiveis` de uma palestra manualmente. Trocar o email por um
  que já existe gera erro 500 em vez de uma mensagem clara.
- **Já corrigido em um caso:** desde a F19, a atualização de avaliação
  aceita só `nota_estrelas` e `comentario` (não dá para trocar o autor).
- **Evento e palestra corrigidos na F08 (22/10/2026):** as duas
  atualizações aceitam só uma lista de campos permitidos. O evento não
  troca de responsável (`id_organizador`), e a palestra não aceita
  `vagas_total` nem `vagas_disponiveis` (mudar a capacidade fica para a
  F14, recalculando o saldo).
- **`tipo_usuario` corrigido na P01 (21/10/2026):** o cadastro e a
  atualização de usuário ignoram esse campo. O restante (como
  `vagas_disponiveis` da palestra e o erro 500 com email repetido)
  continua pendente.
- **Também encontrado na revisão da P01:** um corpo JSON que não é um
  objeto (ex.: `[1, 2]`) faz as rotas de inscrição, favorito, lembrete e
  avaliação responderem 500 em vez de 400.
- **Por que importa:** o backend deve decidir quais campos podem ser
  alterados. Hoje quem decide é quem envia a requisição.

### P04 🟡 Configuração de desenvolvimento exposta

- **Onde:** `backend/app.py` e `backend/config.py`.
- **O que acontece:** a API roda com `debug=True` em `0.0.0.0` (acessível
  por toda a rede), o CORS aceita qualquer origem com credenciais e a
  `SECRET_KEY` tem um valor padrão fixo no código.
- **Por que importa:** o modo debug mostra detalhes internos do servidor
  quando ocorre um erro, e a chave fixa permite falsificar a sessão.
- **Ficou mais grave com a P01 (21/10/2026):** a `SECRET_KEY` assina os
  tokens de login. Com o valor padrão do `config.py`, que está no
  repositório, qualquer pessoa consegue fabricar um token válido de
  qualquer usuário, inclusive de um organizador. Cada instalação precisa
  de uma `SECRET_KEY` própria no `.env`, e a API não deveria subir sem
  ela. O `backend/.env.example` também traz um valor de exemplo
  (`troque-esta-chave`) que não pode ser usado como chave real.
- **CORS (21/10/2026):** desde a P01 a API não usa mais cookie, então o
  `supports_credentials=True` do `app.py` ficou sem uso e pode sair.

## Bugs e inconsistências

### P05 🟢 Abas do app recarregam a cada troca

- **Onde:** `frontend/Flutter/lib/pages/app_shell.dart`,
  `agenda_page.dart` e `notificacoes_page.dart`.
- **O que acontece:** o comentário do `AppShell` diz que as telas mantêm
  o estado, mas `telas[aba]` recria a tela toda vez que a aba muda. A
  Agenda e os Avisos chamam a API dentro do `build()`, então qualquer
  redesenho da tela faz uma nova requisição.
- **Por que importa:** gera requisições desnecessárias, e o comentário
  ensina algo que o código não faz.

### P06 🟡 Fuso horário inconsistente

- **Onde:** `backend/models/favorito.py`, `notificacao.py` e
  `comentario.py` (com `datetime.utcnow`), comparados com o SQL
  (`CURRENT_TIMESTAMP`).
- **O que acontece:** registros criados pela API ficam com a hora em UTC.
  Os registros criados direto no banco usam a hora local (diferença de
  3 horas no Brasil).
- **Por que importa:** ordenações e horários exibidos ficam errados.
  `datetime.utcnow` também está obsoleto no Python 3.12.

### P07 🟢 Uso de método obsoleto do SQLAlchemy

- **Onde:** `backend/services/participacao/cancelar_inscricao_service.py`.
- **O que acontece:** usa `Palestra.query.with_for_update().get(...)`.
  O `Query.get()` está obsoleto no SQLAlchemy 2.
- **Por que importa:** gera aviso hoje e pode parar de funcionar numa
  atualização da biblioteca.

### P08 🟢 Tipo de notificação "atencao" nunca é criado

- **Onde:** `frontend/Flutter/lib/pages/notificacoes_page.dart` e
  `backend/services/notificacao/`.
- **O que acontece:** o app tem estilo visual para o tipo `atencao`, mas
  o backend só cria notificações do tipo `lembrete`. Também não existe
  envio real de lembrete: ativar um lembrete apenas cria um registro.
- **Por que importa:** é uma funcionalidade pela metade. Precisa ser
  implementada ou documentada como limitação.
- **Andamento (22/10/2026, F08):** o backend passou a criar avisos do
  tipo `atencao` quando o organizador remove uma inscrição. Falta o
  envio real do lembrete (F02).

## Documentação e organização

### P09 🔴 README desatualizado

- **Onde:** `README.md`.
- **O que acontece:**
  - ~~manda executar `cd sistema-eventos-final`, pasta que não existe~~
    (corrigido em 20/10/2026);
  - cita `AuthService`, `EventoService` etc., mas hoje existe uma classe
    por caso de uso (ex.: `CriarInscricaoService`);
  - diz que a programação usa `/api/eventos/<id>/programacao`, mas o app
    usa `/api/palestras?id_evento=`;
  - não lista as rotas de CRUD de usuários, eventos, palestras e
    comentários.
- **Por que importa:** o README é a primeira coisa que o professor ou
  avaliador vai ler e usar para rodar o projeto.

### P10 🟢 Comentário desatualizado na tela de favoritos

- **Onde:** `frontend/Flutter/lib/pages/favoritos_page.dart`.
- **O que acontece:** o comentário diz que os dados vêm em
  `item['palestra']`, mas a API devolve os campos sem esse aninhamento.
  O código está correto; só o comentário está errado.
- **Por que importa:** comentários errados confundem quem está aprendendo.

### P11 🔴 Arquivos locais versionados e falta de `.gitignore`

- **Onde:** `frontend/Flutter/android/local.properties`,
  `frontend/Flutter/ios/Flutter/ephemeral/`, `Generated.xcconfig`,
  `flutter_export_environment.sh`.
- **O que acontece:** são arquivos gerados automaticamente e específicos
  do computador de quem compilou (contêm caminhos locais). Não há
  `.gitignore` no projeto.
- **Por que importa:** atrapalham quem clona o projeto em outra máquina,
  e `.env`, `.venv`, `build/` etc. podem acabar no repositório por engano.
- **Feito (20/10/2026):** `.gitignore` mínimo na raiz, com `.env` (senha
  do MySQL) e `.venv/`.
- **Concluído (20/10/2026):** o commit `fc44e13` tinha levado 657
  arquivos gerados (`build/`, `.gradle/`, `.kotlin/`, `.dart_tool/`,
  `__pycache__/` e os arquivos locais do Flutter: `local.properties`,
  `ephemeral/`, `Generated.xcconfig`, `flutter_export_environment.sh`,
  `*.iml`). O `.gitignore` foi completado e eles saíram do Git com
  `git rm --cached` (continuam no computador de cada pessoa). Eles ainda
  existem no histórico, dentro do `fc44e13`; reescrever o histórico foi
  descartado por ser arriscado e sem ganho prático. Quem já tinha o
  projeto baixado segue "Atualizar a máquina depois da P11" no
  `FLUXO_DE_TRABALHO.md`.

### P12 🟢 Projeto sem testes automatizados

- **Onde:** backend e frontend.
- **O que acontece:** não existe nenhum teste. A única forma de verificar
  o sistema é testar tudo manualmente.
- **Por que importa:** a cada mudança não há como garantir que regras
  importantes (vagas, duplicidade de inscrição) continuam funcionando.

### P13 🟢 Tabelas sem uso no app

- **Onde:** `organizador`, `restaurante`, `restaurante_evento`,
  `localizacao` e `planta_baixa` (Models e SQL).
- **O que acontece:** as tabelas e as Models existem, mas não há rotas
  nem telas para elas. A rota `/api/eventos/<id>/programacao` e o CRUD
  de comentários também existem sem uso no app.
- **Por que importa:** é preciso decidir se entram no escopo da entrega
  ou se ficam documentadas como "preparadas para o futuro".

### P14 🔴 Versão antiga e nova sem commit

- **Onde:** repositório git.
- **O que acontece:** a pasta antiga `eventos_project/` e o
  `banco_eventos.sql` aparecem como apagados, e a nova
  `sistema-eventos-refatorado/` não está no controle de versão.
- **Por que importa:** se algo der errado, não há como voltar a um ponto
  seguro da versão nova. É bom fazer esse commit antes de começar as
  correções.
- **Concluído (20/10/2026):** a versão nova entrou no commit `fc44e13`
  (branch `regras-claude`) e chegou à `main` pelo Pull Request da P11,
  já com o `.gitignore` completo.

### P15 🟡 Botão de inscrição não mostra o estado da inscrição

- **Onde:** `frontend/Flutter/lib/pages/palestra_details_page.dart` e
  `frontend/Flutter/lib/models/palestra.dart`.
- **O que acontece:** na tela de detalhes, o botão mostra
  "Inscrever-se" mesmo quando a pessoa já está inscrita, e ao tocar nele
  o texto não muda para "Cancelar inscrição". A API responde certo: o
  `GET /api/palestras/<id>` devolve `inscrito: true` para a Ana nas
  palestras 1 e 2 (testado com `curl` em 21/10/2026). A suspeita é que a
  API recuse a nova inscrição ("Usuário já está inscrito nesta
  palestra") e a tela não reflita o estado devolvido. O problema já
  existia antes da P01.
- **Por que importa:** a inscrição é uma das funções principais do app
  (RF05 e RF06) e aparece na gravação de tela.
- **Decidido (21/10/2026):** resolver junto com as tarefas de interface
  (F20 parte 2), e não na P01.
- **Concluído (22/10/2026), na F06/F07:** a causa era o
  `setState(() => futuro = carregar())` da tela de detalhes. Com a seta,
  a função devolvia o `Future` atribuído, e o Flutter lançava o erro
  "setState() callback argument returned a Future". A ação dava certo
  no backend, mas a tela não recarregava e o botão ficava com o texto
  antigo; um segundo toque recebia "Inscrição não encontrada" ou "Usuário
  já está inscrito". Corrigido com chaves no `setState` (método
  `recarregar()`), também na Programação e no "puxar para atualizar" do
  Início. Testado no app pela Bianca.

### P16 🟡 Fim de linha diferente entre sistemas (falta `.gitattributes`)

- **Onde:** raiz do repositório (o arquivo `.gitattributes` não existe).
- **O que acontece:** cada sistema operacional marca o fim de linha de
  um jeito (Windows: CRLF; Linux e macOS: LF). No Windows, o Flutter
  regera os arquivos `GeneratedPluginRegistrant` (Android e iOS) com
  outro fim de linha a cada `flutter run` ou `flutter analyze`. O
  conteúdo é o mesmo, mas o Git mostra os arquivos inteiros como
  alterados (visto na F06/F07, em 22/10/2026).
- **Por que importa:** com um `git add .`, esses arquivos entram no
  commit sem ninguém perceber, poluem o histórico e podem gerar
  conflitos entre as pessoas da equipe.
- **Proposta (aprovada em 22/10/2026):** criar `.gitattributes` na raiz
  com `* text=auto eol=lf`, para o Git guardar todos os arquivos de
  texto com LF, em qualquer sistema. Depois de criar o arquivo, rodar
  uma vez `git add --renormalize .`, que aplica a regra nova aos
  arquivos que já estão no repositório, e conferir o resultado com
  `git status` antes do commit.

### P17 🟡 Versão do Flutter não definida (`pubspec.lock` muda em cada máquina)

- **Onde:** `README.md` (seção "Pré-requisitos", que hoje diz só
  "Flutter 3 ou mais recente") e `frontend/Flutter/pubspec.lock`.
- **O que acontece:** o `pubspec.lock` guarda a versão exata de cada
  pacote. Com versões diferentes do Flutter, o `flutter pub get` escolhe
  versões diferentes de pacotes e reescreve o arquivo. No Flutter 3.44.1
  da Bianca, ele voltou pacotes para versões mais antigas (ex.: `clock`
  1.1.3 → 1.1.2) e removeu outros (`code_assets`, `crypto`, `hooks`),
  em 22/10/2026.
- **Por que importa:** se o arquivo entrar num commit, as versões dos
  pacotes mudam para toda a equipe sem ninguém ter decidido. O app
  também pode se comportar diferente em cada máquina.
- **Proposta (aprovada em 22/10/2026):** registrar no `README.md` a
  versão exata do Flutter que a equipe usa (conferir com
  `flutter --version`) e todas as pessoas usarem essa versão.
- **Decidir com a Manuela:** qual versão usar (a 3.44.1 da Bianca ou a
  da Manuela, que gerou o `pubspec.lock` atual).
