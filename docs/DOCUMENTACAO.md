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
| `comentario.nota` | Campo de nota no comentário | Removido | A nota passou a ficar só na tabela `avaliacao` (RF16), para não ser guardada em dois lugares |
| `usuario.tema_preferido` | Campo no usuário | Não criado | A escolha entre modo claro e escuro (RF20) fica salva no próprio celular |
| `certificado.Atributo_1` | Campo sem nome | Não criado | O campo não tinha nome nem significado definido |
| `tipo_usuario = 'palestrante'` | Palestrante como tipo de usuário | Removido | O palestrante não usa o app (não faz login). Seus dados ficam na tabela `palestrante` |

### 1.3 Limitação conhecida

Garantir a vaga em uma palestra (inscrição) vale como confirmação de
presença para emitir o certificado. Por isso, quem se inscreveu e não
compareceu também recebe o certificado.
