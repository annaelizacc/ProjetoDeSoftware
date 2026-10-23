import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/marca_texto.dart';
import '../widgets/rotulo_secao.dart';
import 'palestra_details_page.dart';
import 'patrocinadores_page.dart';
import 'programacao_page.dart';

/// O que o Início carrega: os eventos e a agenda da pessoa, juntos.
typedef _DadosInicio = ({List<dynamic> eventos, List<dynamic> agenda});

/// Tela Início (F20 parte 2), como a prancha "Início" do canvas.
///
/// Mostra as informações principais de UM evento, de cima para baixo:
///
/// - a saudação, com o primeiro nome grifado (marca-texto);
/// - o card do evento: datas, nome, local e o botão "Ver programação";
/// - os atalhos do evento (mapa, palestrantes, onde comer, patrocínio).
///   Os que ainda não têm tela aparecem como "Em breve";
/// - a descrição do evento, quando houver;
/// - a próxima palestra da agenda da pessoa nesse evento.
///
/// O evento mostrado começa pelo próximo (o primeiro que ainda não
/// terminou). Com mais de um evento, a lista "Trocar evento" acima do
/// card troca o evento, como na área do organizador. A aba Programação
/// abre o mesmo evento.
///
/// Busca `GET /api/eventos` e a agenda da pessoa
/// (`GET /api/eventos/<id_usuario>/agenda`) ao mesmo tempo, com
/// `Future.wait`.
class HomePage extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;

  /// Abre a aba Agenda da barra de navegação ("Ver agenda"). Quem troca a
  /// aba é o `AppShell`.
  final VoidCallback aoVerAgenda;

  /// Evento escolhido em "Trocar evento" (`null`: o próximo evento). Fica
  /// guardado no `AppShell`, e não nesta tela, porque o `AppShell` monta a
  /// tela de novo a cada troca de aba e a escolha se perderia.
  final int? eventoId;
  final ValueChanged<int> aoTrocarEvento;

  const HomePage({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.aoVerAgenda,
    required this.eventoId,
    required this.aoTrocarEvento,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_DadosInicio> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  Future<_DadosInicio> carregar() async {
    final respostas = await Future.wait([
      ApiService.eventos(),
      // Se só a agenda falhar, o Início abre mesmo assim, sem a próxima
      // palestra.
      ApiService.agenda(widget.usuarioId).catchError((_) => <dynamic>[]),
    ]);
    return (eventos: respostas[0], agenda: respostas[1]);
  }

  /// Começa a busca, troca a variável num `setState` com chaves (com a
  /// seta, ele devolveria o `Future` e o Flutter daria erro) e devolve a
  /// busca, para o círculo de "atualizando" sumir só quando ela terminar.
  Future<void> recarregar() {
    final novaBusca = carregar();
    setState(() {
      futuro = novaBusca;
    });
    return novaBusca;
  }

  /// O evento mostrado: o escolhido em "Trocar evento" ou o próximo.
  Map<String, dynamic>? eventoMostrado(List<dynamic> eventos) =>
      escolherEvento(eventos, widget.eventoId);

  /// A próxima palestra da agenda neste evento (a primeira que ainda não
  /// terminou, então uma palestra acontecendo agora também conta), ou
  /// `null`.
  Palestra? proximaDaAgenda(List<dynamic> agenda, int idEvento) {
    final agora = DateTime.now();
    final proximas = [
      for (final json in agenda)
        if (json['id_evento'] == idEvento) Palestra.fromJson(Map<String, dynamic>.from(json)),
    ].where((p) {
      final fim = DateTime.tryParse(p.fim ?? p.inicio ?? '');
      return fim != null && fim.isAfter(agora);
    }).toList()
      ..sort((a, b) => a.inicio!.compareTo(b.inicio!));
    return proximas.isEmpty ? null : proximas.first;
  }

  /// Abre uma tela e, ao voltar, busca de novo: a pessoa pode ter se
  /// inscrito ou cancelado, e a "Próxima na agenda" muda.
  Future<void> abrir(Widget tela) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
    if (mounted) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_DadosInicio>(
        future: futuro,
        builder: (context, snapshot) {
          // Ao puxar para atualizar, o `FutureBuilder` guarda os dados
          // anteriores (`hasData`): a tela continua visível, com o círculo
          // do `RefreshIndicator`, em vez de virar um carregamento.
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                  TextButton(onPressed: recarregar, child: const Text('Tentar de novo')),
                ],
              ),
            );
          }

          final eventos = snapshot.data!.eventos;
          final evento = eventoMostrado(eventos);

          return RefreshIndicator(
            onRefresh: recarregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: [
                _Saudacao(nome: widget.nomeUsuario),
                const SizedBox(height: 20),
                if (evento == null)
                  const Text('Nenhum evento encontrado.')
                else ...[
                  if (eventos.length > 1) ...[
                    DropdownButtonFormField<int>(
                      initialValue: evento['id_evento'] as int,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Trocar evento'),
                      items: [
                        for (final e in eventos)
                          DropdownMenuItem(
                            value: e['id_evento'] as int,
                            child: Text(e['nome'] ?? '', overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (id) {
                        if (id != null) widget.aoTrocarEvento(id);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  _CardEvento(
                    evento: evento,
                    aoVerProgramacao: () => abrir(ProgramacaoPage(
                      eventoId: evento['id_evento'],
                      nomeEvento: evento['nome'] ?? '',
                      usuarioId: widget.usuarioId,
                    )),
                  ),
                  const SizedBox(height: 20),
                  _Atalhos(
                    aoAbrirPatrocinio: () => abrir(PatrocinadoresPage(
                      eventoId: evento['id_evento'],
                      nomeEvento: evento['nome'] ?? '',
                    )),
                  ),
                  if ((evento['descricao'] ?? '').toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const RotuloSecao('Sobre o evento'),
                    const SizedBox(height: 6),
                    Text(evento['descricao'], style: Theme.of(context).textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 22),
                  _ProximaNaAgenda(
                    palestra: proximaDaAgenda(snapshot.data!.agenda, evento['id_evento']),
                    aoVerAgenda: widget.aoVerAgenda,
                    aoAbrir: (p) => abrir(
                      PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: p.id),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Escolhe o evento que o Início e a aba Programação mostram: o de
/// `eventoId` (escolhido em "Trocar evento"), se ele existir; senão, o
/// próximo evento, o primeiro (por data de início) que ainda não
/// terminou; se todos já terminaram, o primeiro deles. `null` sem eventos.
Map<String, dynamic>? escolherEvento(List<dynamic> eventos, int? eventoId) {
  if (eventos.isEmpty) return null;
  for (final e in eventos) {
    if (e['id_evento'] == eventoId) return Map<String, dynamic>.from(e);
  }
  final hoje = DateUtils.dateOnly(DateTime.now());
  final ordenados = [...eventos]
    ..sort((a, b) => (a['data_inicio'] ?? '').compareTo(b['data_inicio'] ?? ''));
  final naoTerminados = ordenados.where((e) {
    final fim = DateTime.tryParse(e['data_fim'] ?? '');
    return fim == null || !fim.isBefore(hoje);
  });
  return Map<String, dynamic>.from(
      naoTerminados.isNotEmpty ? naoTerminados.first : ordenados.first);
}

/// Topo da tela: dia e hora em JetBrains Mono (`SEX 23 OUT · 08:30`) e
/// "Bom dia, Ana", com o primeiro nome grifado.
class _Saudacao extends StatelessWidget {
  final String nome;

  const _Saudacao({required this.nome});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final agora = DateTime.now();
    final hora = agora.hour;
    final saudacao = hora < 12 ? 'Bom dia' : (hora < 18 ? 'Boa tarde' : 'Boa noite');
    final primeiroNome = nome.trim().split(' ').first;
    final minutos = agora.minute.toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_diasSemana[agora.weekday - 1]} ${agora.day} ${_meses[agora.month - 1]} · '
          '${hora.toString().padLeft(2, '0')}:$minutos',
          style: textos.labelMedium,
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: '$saudacao, ',
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: MarcaTexto(primeiroNome, estilo: textos.headlineMedium),
              ),
            ],
          ),
          style: textos.headlineMedium,
        ),
      ],
    );
  }
}

const _diasSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
const _meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];

/// Período do evento como no canvas: `10—12 SET 2026` no mesmo mês,
/// `30 SET—02 OUT 2026` em meses diferentes e
/// `30 DEZ 2026—02 JAN 2027` em anos diferentes.
String _periodo(String? inicioTexto, String? fimTexto) {
  final inicio = DateTime.tryParse(inicioTexto ?? '');
  final fim = DateTime.tryParse(fimTexto ?? '');
  if (inicio == null) return 'DATA A DEFINIR';
  String dia(DateTime d) => d.day.toString().padLeft(2, '0');
  final mesInicio = _meses[inicio.month - 1];
  if (fim == null || DateUtils.isSameDay(inicio, fim)) {
    return '${dia(inicio)} $mesInicio ${inicio.year}';
  }
  final mesFim = _meses[fim.month - 1];
  final comeco = inicio.year != fim.year
      ? '${dia(inicio)} $mesInicio ${inicio.year}'
      : (inicio.month == fim.month ? dia(inicio) : '${dia(inicio)} $mesInicio');
  return '$comeco—${dia(fim)} $mesFim ${fim.year}';
}

/// Card do evento na cor principal, com a curva fina do rio ao fundo.
class _CardEvento extends StatelessWidget {
  final Map<String, dynamic> evento;
  final VoidCallback aoVerProgramacao;

  const _CardEvento({required this.evento, required this.aoVerProgramacao});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final corTexto = cores.onPrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: cores.primary,
        child: CustomPaint(
          painter: _RioDoCard(corTexto.withValues(alpha: 0.12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _periodo(evento['data_inicio'], evento['data_fim']),
                  style: textos.labelMedium?.copyWith(color: corTexto.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 48),
                Padding(
                  // Deixa espaço à direita para a curva do rio.
                  padding: const EdgeInsets.only(right: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento['nome'] ?? '',
                        style: textos.headlineSmall?.copyWith(color: corTexto, height: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evento['local'] ?? 'Local a definir',
                        style: textos.bodySmall?.copyWith(color: corTexto.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: aoVerProgramacao,
                  style: FilledButton.styleFrom(
                    backgroundColor: cores.surface,
                    foregroundColor: cores.onSurface,
                  ),
                  child: const Text('Ver programação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A curva do rio no canto direito do card, com o caminho copiado do
/// canvas (card de 350 × 214). Cada ponto é multiplicado pela proporção
/// entre o card real e o do canvas, como em `tela_acesso.dart`.
class _RioDoCard extends CustomPainter {
  final Color cor;

  _RioDoCard(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 350;
    final sy = size.height / 214;
    final caminho = Path()
      ..moveTo(276 * sx, -10 * sy)
      ..cubicTo(220 * sx, 40 * sy, 232 * sx, 96 * sy, 278 * sx, 124 * sy)
      ..cubicTo(322 * sx, 152 * sy, 316 * sx, 192 * sy, 278 * sx, 224 * sy);
    canvas.drawPath(
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RioDoCard antigo) => antigo.cor != cor;
}

/// Os quatro atalhos do evento, em duas colunas. Só o Patrocínio (F10) já
/// tem tela; os outros aparecem como "Em breve": o mapa é a F03, os
/// palestrantes a F05 e os restaurantes a F13.
class _Atalhos extends StatelessWidget {
  final VoidCallback aoAbrirPatrocinio;

  const _Atalhos({required this.aoAbrirPatrocinio});

  @override
  Widget build(BuildContext context) {
    final atalhos = <(String, VoidCallback?)>[
      ('Mapa do local', null),
      ('Palestrantes', null),
      ('Onde comer', null),
      ('Patrocínio', aoAbrirPatrocinio),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.9,
      children: [
        for (final (nome, aoTocar) in atalhos) _Atalho(nome: nome, aoTocar: aoTocar),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  final String nome;
  final VoidCallback? aoTocar;

  const _Atalho({required this.nome, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final ativo = aoTocar != null;

    return Material(
      color: cores.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ativo ? cores.primary : cores.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: textos.titleSmall, overflow: TextOverflow.ellipsis),
                    if (!ativo) Text('Em breve', style: textos.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Próxima na agenda": a próxima palestra em que a pessoa se inscreveu
/// neste evento, no formato de ingresso do canvas (horário e sala à
/// esquerda, picote, título e palestrante à direita).
class _ProximaNaAgenda extends StatelessWidget {
  final Palestra? palestra;
  final VoidCallback aoVerAgenda;
  final ValueChanged<Palestra> aoAbrir;

  const _ProximaNaAgenda({
    required this.palestra,
    required this.aoVerAgenda,
    required this.aoAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final p = palestra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: RotuloSecao('Próxima na agenda')),
            TextButton(onPressed: aoVerAgenda, child: const Text('Ver agenda')),
          ],
        ),
        if (p == null)
          Text('Nenhuma palestra agendada neste evento.', style: textos.bodySmall)
        else
          Material(
            color: cores.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: cores.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => aoAbrir(p),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 86,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: cores.primary,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.horario.split(' - ').first,
                            style: textos.labelMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cores.onPrimary,
                            ),
                          ),
                          if (p.sala != null)
                            Text(
                              p.sala!.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: textos.labelSmall?.copyWith(
                                fontFamily: AppFontes.mono,
                                color: cores.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.titulo, style: textos.titleSmall),
                            if (p.palestrante != null) ...[
                              const SizedBox(height: 4),
                              Text(p.palestrante!, style: textos.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
