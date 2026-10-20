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
  alterar ou apagar a avaliação de outra.
- O script do banco apaga e recria tudo (`DROP DATABASE`). Quem já tinha
  o banco local precisou recriá-lo, perdendo os dados locais.
