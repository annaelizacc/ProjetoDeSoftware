import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../utils/datas.dart';
import '../widgets/aviso_vazio.dart';
import '../widgets/cabecalho_aba.dart';
import '../widgets/selo.dart';
import 'palestra_details_page.dart';

/// Tela de agenda pessoal (aba Agenda), no visual da prancha "Minha
/// agenda" do canvas.
///
/// Lista as palestras em que o usuário está inscrito, obtidas em
/// `GET /api/eventos/<id_usuario>/agenda` (`ApiService.agenda`), que no
/// backend é resolvida pelo `ObterAgendaUsuarioService` com uma consulta
/// SQL explícita (JOIN entre participação, palestra e evento).
///
/// A tela mostra um dia por vez, como uma linha do tempo: a hora à
/// esquerda, a linha do rio com um ponto no meio e o card à direita. As
/// setas do cabeçalho pulam entre os dias que têm inscrição. Entre duas
/// palestras aparece a pausa ("Intervalo livre de 30 min" ou "Almoço").
///
/// Destaque (fundo na cor principal): só no dia de hoje, vai para a
/// palestra que está acontecendo ou, se nenhuma estiver, para a próxima.
/// As que já terminaram ficam acinzentadas, como na Programação.
class AgendaPage extends StatefulWidget {
  final int usuarioId;

  const AgendaPage({super.key, required this.usuarioId});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late Future<List<Palestra>> futuro;

  /// Dia mostrado (`null` = escolher o dia inicial ao carregar).
  DateTime? diaEscolhido;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca a agenda e ordena pelo início. Palestras sem horário ficam de
  /// fora: sem data, não há em que dia da linha do tempo colocá-las.
  Future<List<Palestra>> carregar() async {
    final lista = [
      for (final json in await ApiService.agenda(widget.usuarioId)) Palestra.fromJson(Map<String, dynamic>.from(json)),
    ].where((p) => p.dataInicio != null).toList();
    lista.sort((a, b) => a.dataInicio!.compareTo(b.dataInicio!));
    return lista;
  }

  Future<void> abrirDetalhes(Palestra palestra) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: palestra.id),
      ),
    );
    // Ao voltar, recarrega: a pessoa pode ter cancelado a inscrição.
    if (mounted) {
      setState(() {
        futuro = carregar();
      });
    }
  }

  /// Dia inicial: hoje, se tiver inscrição; se não, o próximo dia com
  /// inscrição; se todos já passaram, o último.
  DateTime _diaInicial(List<DateTime> dias) {
    final hoje = DateUtils.dateOnly(DateTime.now());
    return dias.firstWhere((dia) => !dia.isBefore(hoje), orElse: () => dias.last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Palestra>>(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(children: [
              CabecalhoAba(rotulo: 'Suas inscrições', titulo: 'Minha agenda'),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ]);
          }
          if (snapshot.hasError) {
            return Column(children: [
              const CabecalhoAba(rotulo: 'Suas inscrições', titulo: 'Minha agenda'),
              Expanded(child: Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')))),
            ]);
          }
          return _corpo(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _corpo(BuildContext context, List<Palestra> palestras) {
    // Dias com inscrição, sem repetir e em ordem (a lista já vem ordenada).
    final dias = <DateTime>[];
    for (final p in palestras) {
      final dia = DateUtils.dateOnly(p.dataInicio!);
      if (dias.isEmpty || !DateUtils.isSameDay(dias.last, dia)) dias.add(dia);
    }

    if (dias.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabecalhoAba(rotulo: 'Suas inscrições', titulo: 'Minha agenda'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AvisoVazio('Você ainda não tem inscrições. Inscreva-se pela Programação.'),
          ),
        ],
      );
    }

    // Se o dia escolhido sumiu (ex.: cancelou a única palestra dele),
    // volta para o dia inicial.
    final dia = dias.firstWhere(
      (d) => diaEscolhido != null && DateUtils.isSameDay(d, diaEscolhido),
      orElse: () => _diaInicial(dias),
    );
    final indice = dias.indexOf(dia);
    final doDia = palestras.where((p) => DateUtils.isSameDay(p.dataInicio, dia)).toList();
    final quantidade = '${doDia.length} ${doDia.length == 1 ? 'palestra' : 'palestras'}';

    final agora = DateTime.now();
    final destaque = DateUtils.isSameDay(dia, agora) ? _escolherDestaque(doDia, agora) : null;

    // Monta a linha do tempo: cada palestra e, quando sobra tempo antes da
    // próxima, a pausa. `ocupadoAte` guarda o maior fim visto até ali: com
    // palestras sobrepostas (ex.: de eventos diferentes), uma mais longa
    // ainda pode estar acontecendo, e aí não há intervalo livre.
    final paradas = <Widget>[];
    DateTime? ocupadoAte;
    for (var i = 0; i < doDia.length; i++) {
      final p = doDia[i];
      paradas.add(_ParadaPalestra(
        palestra: p,
        destaque: identical(p, destaque),
        passada: p.encerradaEm(agora),
        agora: agora,
        aoTocar: () => abrirDetalhes(p),
      ));
      final fim = p.fimOuInicio!;
      if (ocupadoAte == null || fim.isAfter(ocupadoAte)) ocupadoAte = fim;
      if (i < doDia.length - 1 && doDia[i + 1].dataInicio!.isAfter(ocupadoAte)) {
        paradas.add(_ParadaPausa(inicio: ocupadoAte, fim: doDia[i + 1].dataInicio!));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabecalhoAba(
          rotulo: 'Suas inscrições · $quantidade',
          titulo: 'Minha agenda',
          acoes: [
            BotaoCabecalho(
              icone: Icons.chevron_left,
              dica: 'Dia anterior',
              aoTocar: indice > 0 ? () => setState(() => diaEscolhido = dias[indice - 1]) : null,
            ),
            BotaoCabecalho(
              icone: Icons.chevron_right,
              dica: 'Próximo dia',
              aoTocar: indice < dias.length - 1 ? () => setState(() => diaEscolhido = dias[indice + 1]) : null,
            ),
          ],
        ),
        _DataDoDia(dia: dia, hoje: DateUtils.isSameDay(dia, agora)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: paradas,
          ),
        ),
      ],
    );
  }

  /// A palestra acontecendo agora ou, se nenhuma estiver, a próxima do dia.
  Palestra? _escolherDestaque(List<Palestra> doDia, DateTime agora) {
    for (final p in doDia) {
      if (p.emAndamentoEm(agora)) return p;
    }
    for (final p in doDia) {
      if (p.dataInicio!.isAfter(agora)) return p;
    }
    return null;
  }
}

/// Data do dia mostrado, em destaque logo abaixo do cabeçalho (ex.:
/// `SÁB 24 OUT`), com o selo `HOJE` quando é o dia atual.
class _DataDoDia extends StatelessWidget {
  final DateTime dia;
  final bool hoje;

  const _DataDoDia({required this.dia, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Text(
          '${diaCurto(dia)} ${meses[dia.month - 1]}',
          style: tema.textTheme.labelMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: tema.colorScheme.primary,
          ),
        ),
        if (hoje) ...[const SizedBox(width: 10), const Selo('Hoje', tipo: TipoSelo.destaque)],
      ]),
    );
  }
}

/// Duração no formato dos rótulos: `30 min`, `2 h`, `1 h 30 min`.
String _duracao(Duration d) {
  final horas = d.inHours;
  final minutos = d.inMinutes % 60;
  if (horas == 0) return '$minutos min';
  return minutos == 0 ? '$horas h' : '$horas h $minutos min';
}

/// Uma palestra na linha do tempo: hora, ponto cheio e card.
class _ParadaPalestra extends StatelessWidget {
  final Palestra palestra;
  final bool destaque;
  final bool passada;
  final DateTime agora;
  final VoidCallback aoTocar;

  const _ParadaPalestra({
    required this.palestra,
    required this.destaque,
    required this.passada,
    required this.agora,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final textos = tema.textTheme;
    final p = palestra;

    final corTexto = destaque ? cores.onPrimary : cores.onSurface;
    final corSecundaria = destaque ? cores.onPrimary.withValues(alpha: 0.75) : cores.onSurfaceVariant;
    // A agenda junta palestras de todos os eventos em que a pessoa se
    // inscreveu, então a linha começa pelo evento: EVENTO · SALA · ATÉ.
    final detalhe = [
      if (p.nomeEvento != null && p.nomeEvento!.isNotEmpty) p.nomeEvento!.toUpperCase(),
      if (p.sala != null && p.sala!.isNotEmpty) p.sala!.toUpperCase(),
      if (p.horaFim.isNotEmpty) 'ATÉ ${p.horaFim}',
    ].join(' · ');
    final emAndamento = !p.dataInicio!.isAfter(agora);
    final aviso = emAndamento
        ? 'AGORA · ATÉ ${p.horaFim}'
        : 'PRÓXIMA · EM ${_duracao(p.dataInicio!.difference(agora)).toUpperCase()}';

    final card = Material(
      color: destaque ? cores.primary : cores.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: destaque ? cores.primary : cores.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          // O destaque é maior que os outros cards (mais espaço interno e
          // título maior); os demais ficam mais compactos.
          padding: destaque
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 30)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (destaque) ...[
                Text(aviso, style: textos.labelSmall?.copyWith(color: cores.tertiary)),
                const SizedBox(height: 10),
              ],
              Text(
                p.titulo,
                style: textos.titleSmall?.copyWith(color: corTexto, height: 1.3, fontSize: destaque ? 22 : 14),
              ),
              if (detalhe.isNotEmpty) ...[
                SizedBox(height: destaque ? 8 : 4),
                Text(detalhe, style: textos.labelMedium?.copyWith(color: corSecundaria, fontSize: destaque ? 13 : 11)),
              ],
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: passada && !destaque ? 0.45 : 1,
      child: _LinhaDoTempo(
        hora: Padding(
          padding: EdgeInsets.only(top: destaque ? 30 : 10),
          child: Text(
            p.horaInicio,
            textAlign: TextAlign.right,
            style: textos.labelMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: cores.primary),
          ),
        ),
        trilho: _Trilho(
          corLinha: cores.secondary,
          tracejada: false,
          tamanhoPonto: 18,
          topoPonto: destaque ? 30 : 10,
          corPonto: destaque ? cores.primary : cores.surface,
          corBorda: cores.primary,
        ),
        conteudo: Padding(padding: const EdgeInsets.only(bottom: 12), child: card),
      ),
    );
  }
}

/// Uma pausa entre duas palestras: linha tracejada e ponto pequeno.
///
/// Se a pausa passa pelo horário do almoço (entre 12:00 e 13:00) e tem
/// pelo menos 30 min, ganha o link "ver onde comer"; se tem até 3 h, o
/// texto é "Almoço", e se é maior continua "Intervalo livre de 8 h", para
/// não esconder que a pessoa tem o dia livre. O link leva aos
/// restaurantes da F13 e, até lá, só avisa "Em breve".
class _ParadaPausa extends StatelessWidget {
  final DateTime inicio;
  final DateTime fim;

  const _ParadaPausa({required this.inicio, required this.fim});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final textos = tema.textTheme;

    final meioDia = DateTime(inicio.year, inicio.month, inicio.day, 12);
    final duracao = fim.difference(inicio);
    final passaPeloAlmoco = inicio.isBefore(meioDia.add(const Duration(hours: 1))) &&
        fim.isAfter(meioDia) &&
        duracao.inMinutes >= 30;
    final texto = passaPeloAlmoco && duracao.inMinutes <= 180 ? 'Almoço' : 'Intervalo livre de ${_duracao(duracao)}';
    final estilo = textos.bodySmall?.copyWith(fontSize: 14);

    return _LinhaDoTempo(
      hora: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          horaCurta(inicio),
          textAlign: TextAlign.right,
          style: textos.labelMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
      ),
      trilho: _Trilho(
        corLinha: cores.secondary,
        tracejada: true,
        tamanhoPonto: 10,
        topoPonto: 7,
        corPonto: tema.scaffoldBackgroundColor,
        corBorda: cores.secondary,
      ),
      conteudo: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 22),
        child: passaPeloAlmoco
            ? Wrap(children: [
                Text('$texto · ', style: estilo),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Em breve: onde comer perto do evento.'))),
                  child: Text(
                    'ver onde comer',
                    style: estilo?.copyWith(fontWeight: FontWeight.w600, color: cores.primary),
                  ),
                ),
              ])
            : Text(texto, style: estilo),
      ),
    );
  }
}

/// As três colunas de cada parada: hora (48px), trilho (18px) e conteúdo.
/// O `IntrinsicHeight` faz o trilho ter a altura do conteúdo, para a
/// linha do rio seguir sem falhas de uma parada para a outra.
class _LinhaDoTempo extends StatelessWidget {
  final Widget hora;
  final _Trilho trilho;
  final Widget conteudo;

  const _LinhaDoTempo({required this.hora, required this.trilho, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 48, child: hora),
          const SizedBox(width: 12),
          SizedBox(width: 18, child: CustomPaint(painter: trilho)),
          const SizedBox(width: 12),
          Expanded(child: conteudo),
        ],
      ),
    );
  }
}

/// Desenha a linha vertical do rio (contínua nas palestras, tracejada nas
/// pausas) e o ponto com borda por cima dela.
class _Trilho extends CustomPainter {
  final Color corLinha;
  final bool tracejada;
  final double tamanhoPonto;
  final double topoPonto;
  final Color corPonto;
  final Color corBorda;

  _Trilho({
    required this.corLinha,
    required this.tracejada,
    required this.tamanhoPonto,
    required this.topoPonto,
    required this.corPonto,
    required this.corBorda,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final linha = Paint()
      ..color = corLinha
      ..strokeWidth = 2;
    if (tracejada) {
      // Traços de 4px com 4px de espaço.
      for (var y = 0.0; y < size.height; y += 8) {
        canvas.drawLine(Offset(x, y), Offset(x, (y + 4).clamp(0, size.height)), linha);
      }
    } else {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linha);
    }

    final centro = Offset(x, topoPonto + tamanhoPonto / 2);
    final raio = tamanhoPonto / 2;
    canvas.drawCircle(centro, raio, Paint()..color = corPonto);
    // A borda de 3px fica por dentro do ponto, como no `box-sizing` do canvas.
    canvas.drawCircle(
      centro,
      raio - 1.5,
      Paint()
        ..color = corBorda
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_Trilho antigo) =>
      antigo.corLinha != corLinha ||
      antigo.tracejada != tracejada ||
      antigo.topoPonto != topoPonto ||
      antigo.corPonto != corPonto ||
      antigo.corBorda != corBorda;
}
