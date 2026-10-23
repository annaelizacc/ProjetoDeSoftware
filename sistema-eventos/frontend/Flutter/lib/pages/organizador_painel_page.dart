import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/rotulo_secao.dart';
import '../widgets/selo.dart';
import 'organizador_evento_page.dart';
import 'organizador_inscricoes_page.dart';
import 'organizador_locais_page.dart';
import 'organizador_palestrantes_page.dart';
import 'organizador_palestras_page.dart';
import 'organizador_patrocinadores_page.dart';

/// Tela "Área do organizador" (F08, RF17): o painel do evento.
///
/// Aberta pelo Perfil, só para organizadores. Segue a prancha "Área do
/// organizador" do canvas:
///
/// - uma faixa com os números do evento (palestras, inscrições, esgotadas,
///   ocupação e média das avaliações);
/// - o ranking das palestras, das mais procuradas para as menos procuradas.
///   Tocar numa palestra abre as inscrições dela;
/// - o menu da área: "Inscrições" e os cadastros do evento (F14). O
///   comunicado (F09) aparece como "Em breve" até ser feito.
///
/// "Novo evento" (e, para quem ainda não tem evento, "Criar meu primeiro
/// evento") abre o formulário do evento (F14). Ao voltar, o painel busca
/// de novo a lista de eventos e mostra o evento criado.
///
/// Mostra só os eventos que a pessoa gerencia (`GET /api/organizador/eventos`):
/// os ligados a ela, ou todos, para o administrador. Começa pelo primeiro;
/// com mais de um, aparece um seletor no topo para trocar de evento (o
/// "trocar evento" do canvas). Os números vêm de
/// `GET /api/organizador/eventos/<id>/painel` (`ApiService.painelOrganizador`).
class OrganizadorPainelPage extends StatefulWidget {
  const OrganizadorPainelPage({super.key});

  @override
  State<OrganizadorPainelPage> createState() => _OrganizadorPainelPageState();
}

class _OrganizadorPainelPageState extends State<OrganizadorPainelPage> {
  late Future<Map<String, dynamic>?> futuro;

  /// Eventos da pessoa e o escolhido, guardados depois da primeira busca:
  /// ao recarregar ou trocar de evento, o app pede só o painel.
  List<dynamic>? meusEventos;
  int? eventoId;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca os eventos da pessoa (só na primeira vez) e o painel do evento
  /// escolhido. Devolve `null` se ela ainda não tiver nenhum evento.
  Future<Map<String, dynamic>?> carregar() async {
    if (meusEventos == null) {
      final eventos = await ApiService.meusEventos();
      meusEventos = eventos;
      // Mantém o evento escolhido (ex.: o que acabou de ser criado), a não
      // ser que ele não exista mais (ex.: acabou de ser excluído).
      final aindaExiste = eventos.any((e) => e['id_evento'] == eventoId);
      if (!aindaExiste) eventoId = eventos.isEmpty ? null : eventos.first['id_evento'];
    }
    if (eventoId == null) return null;
    return ApiService.painelOrganizador(eventoId!);
  }

  void trocarEvento(int? id) {
    if (id == null || id == eventoId) return;
    eventoId = id;
    recarregar();
  }

  /// Recarrega o painel (puxar a tela para baixo ou voltar das inscrições,
  /// que podem ter mudado os números).
  Future<void> recarregar() async {
    setState(() => futuro = carregar());
    await futuro;
  }

  Future<void> abrirInscricoes(List<dynamic> palestras, int palestraId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizadorInscricoesPage(
          palestras: palestras,
          palestraInicialId: palestraId,
        ),
      ),
    );
    if (mounted) recarregar();
  }

  /// Abre o formulário do evento: sem `evento`, para criar um novo; com
  /// ele, para editar. Se algo mudou, busca de novo a lista de eventos
  /// (o nome pode ter mudado, ou o evento pode ter sido criado ou
  /// excluído).
  Future<void> abrirEvento({Map<String, dynamic>? evento}) async {
    final resultado = await Navigator.push<ResultadoEvento>(
      context,
      MaterialPageRoute(builder: (_) => OrganizadorEventoPage(evento: evento)),
    );
    if (resultado == null || !mounted) return;
    meusEventos = null;
    if (resultado == ResultadoEvento.removido) eventoId = null;
    recarregar();
  }

  /// Abre a lista de um cadastro do evento (locais, palestras etc.) e
  /// recarrega o painel ao voltar, porque os números podem ter mudado.
  Future<void> abrirCadastro(Widget tela) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
    if (mounted) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              children: [
                CabecalhoTela(titulo: 'Área do organizador'),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Column(
              children: [
                const CabecalhoTela(titulo: 'Área do organizador'),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.hasError
                              ? snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', '')
                              : 'Você ainda não tem eventos.',
                        ),
                        // Sem isso, depois de um erro (ex.: a rede caiu)
                        // a única saída seria fechar e abrir a área de novo.
                        if (snapshot.hasError)
                          TextButton(
                            onPressed: recarregar,
                            child: const Text('Tentar de novo'),
                          )
                        else ...[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => abrirEvento(),
                            child: const Text('Criar meu primeiro evento'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final painel = snapshot.data!;
          final evento = Map<String, dynamic>.from(painel['evento']);
          final resumo = Map<String, dynamic>.from(painel['resumo']);
          final palestras = List<dynamic>.from(painel['palestras']);

          return Column(
            children: [
              CabecalhoTela(
                  titulo: evento['nome'] ?? '', secao: 'Área do organizador'),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: recarregar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      if ((meusEventos?.length ?? 0) > 1) ...[
                        DropdownButtonFormField<int>(
                          initialValue: eventoId,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Trocar evento'),
                          items: [
                            for (final e in meusEventos!)
                              DropdownMenuItem(
                                value: e['id_evento'] as int,
                                child: Text(e['nome'] ?? '',
                                    overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: trocarEvento,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _FaixaNumeros(resumo: resumo),
                      const SizedBox(height: 24),
                      const RotuloSecao('Palestras mais procuradas'),
                      const SizedBox(height: 4),
                      if (palestras.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Nenhuma palestra cadastrada.'),
                        ),
                      for (final json in palestras)
                        _ItemRanking(
                          dados: Map<String, dynamic>.from(json),
                          aoTocar: () =>
                              abrirInscricoes(palestras, json['id_palestra']),
                        ),
                      const SizedBox(height: 24),
                      const RotuloSecao('Participantes'),
                      const SizedBox(height: 4),
                      _ItemMenu(
                        nome: 'Inscrições',
                        descricao: 'Ver e gerenciar quem se inscreveu',
                        aoTocar: palestras.isEmpty
                            ? null
                            : () => abrirInscricoes(
                                palestras, palestras.first['id_palestra']),
                      ),
                      const _ItemMenu(
                        nome: 'Enviar comunicado',
                        descricao: 'Aviso para todos os participantes',
                      ),
                      const SizedBox(height: 24),
                      const RotuloSecao('Cadastros do evento'),
                      const SizedBox(height: 4),
                      _ItemMenu(
                        nome: 'Evento e planta',
                        descricao: 'Nome, datas, local e imagem da planta',
                        aoTocar: () => abrirEvento(evento: evento),
                      ),
                      // Locais e palestrantes vêm antes das palestras: a
                      // palestra escolhe um local e um palestrante já
                      // cadastrados.
                      _ItemMenu(
                        nome: 'Locais e rotas',
                        descricao: 'Salas com o passo a passo de como chegar',
                        aoTocar: () => abrirCadastro(OrganizadorLocaisPage(eventoId: eventoId!)),
                      ),
                      _ItemMenu(
                        nome: 'Palestrantes',
                        descricao: 'Nome, foto, descrição e rede social',
                        aoTocar: () =>
                            abrirCadastro(OrganizadorPalestrantesPage(eventoId: eventoId!)),
                      ),
                      _ItemMenu(
                        nome: 'Palestras',
                        descricao: 'Horário, local, palestrante e vagas',
                        aoTocar: () => abrirCadastro(OrganizadorPalestrasPage(eventoId: eventoId!)),
                      ),
                      _ItemMenu(
                        nome: 'Patrocinadores',
                        descricao: 'Empresa, logo e site',
                        aoTocar: () =>
                            abrirCadastro(OrganizadorPatrocinadoresPage(eventoId: eventoId!)),
                      ),
                      _ItemMenu(
                        nome: 'Novo evento',
                        descricao: 'Cadastrar outro evento',
                        aoTocar: () => abrirEvento(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Faixa na cor principal com os números do evento, em duas linhas:
/// palestras, inscrições e esgotadas; depois ocupação e média.
class _FaixaNumeros extends StatelessWidget {
  final Map<String, dynamic> resumo;

  const _FaixaNumeros({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final media = resumo['media_avaliacoes'];
    final totalAvaliacoes = resumo['total_avaliacoes'] ?? 0;
    final linha = Divider(color: cores.onPrimary.withValues(alpha: 0.2));

    return Container(
      decoration: BoxDecoration(
        color: cores.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Numero(
                  valor: '${resumo['total_palestras']}', rotulo: 'palestras'),
              _Numero(
                  valor: '${resumo['total_inscricoes']}', rotulo: 'inscrições'),
              _Numero(
                  valor: '${resumo['palestras_esgotadas']}',
                  rotulo: 'esgotadas'),
            ],
          ),
          linha,
          Row(
            children: [
              _Numero(
                  valor: '${resumo['ocupacao_percentual']}%',
                  rotulo: 'das vagas ocupadas'),
              _Numero(
                // Sem nenhuma avaliação, mostra um traço em vez de "0,0".
                valor: media == null ? '—' : '★ ${_decimal(media)}',
                rotulo: totalAvaliacoes == 1
                    ? '1 avaliação'
                    : '$totalAvaliacoes avaliações',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Um número da faixa, com o rótulo embaixo. Divide a linha igualmente
/// com os outros (`Expanded`).
class _Numero extends StatelessWidget {
  final String valor;
  final String rotulo;

  const _Numero({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: TextStyle(
                fontFamily: AppFontes.mono,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cores.onPrimary,
              ),
            ),
            Text(
              rotulo,
              style: TextStyle(
                  fontSize: 12, color: cores.onPrimary.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma palestra do ranking: título, horário e sala, inscritos/vagas e a
/// média das avaliações. Mostra o selo "Esgotada" quando não há vagas.
class _ItemRanking extends StatelessWidget {
  final Map<String, dynamic> dados;
  final VoidCallback aoTocar;

  const _ItemRanking({required this.dados, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final palestra = Palestra.fromJson(dados);
    final media = dados['media_avaliacoes'];
    final detalhes = [
      '${dados['total_inscritos']}/${palestra.total} inscritos',
      if (media != null) '★ ${_decimal(media)}',
    ].join(' · ');

    return InkWell(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: tema.colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${palestra.horario} · ${palestra.sala ?? 'Local a definir'}'
                        .toUpperCase(),
                    style: tema.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(palestra.titulo, style: tema.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(detalhes, style: tema.textTheme.bodySmall),
                ],
              ),
            ),
            if (palestra.vagas == 0) ...[
              const SizedBox(width: 8),
              const Selo('Esgotada', tipo: TipoSelo.alerta),
            ],
            Icon(Icons.chevron_right, color: tema.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Um item do menu da área do organizador. Sem `aoTocar`, aparece
/// desativado com "Em breve" (funções das próximas tarefas).
class _ItemMenu extends StatelessWidget {
  final String nome;
  final String descricao;
  final VoidCallback? aoTocar;

  const _ItemMenu({required this.nome, required this.descricao, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final ativo = aoTocar != null;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cores.outlineVariant)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        enabled: ativo,
        title: Text(nome),
        subtitle: Text(ativo ? descricao : '$descricao · Em breve'),
        trailing: ativo
            ? Icon(Icons.chevron_right, color: cores.onSurfaceVariant)
            : null,
        onTap: aoTocar,
      ),
    );
  }
}

/// Número com uma casa decimal e vírgula, como se escreve no Brasil
/// (4.5 → "4,5").
String _decimal(num valor) => valor.toStringAsFixed(1).replaceAll('.', ',');
