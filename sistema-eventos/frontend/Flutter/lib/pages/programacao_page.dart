import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../utils/datas.dart';
import '../widgets/aviso_vazio.dart';
import '../widgets/cabecalho_aba.dart';
import '../widgets/estrelas.dart';
import '../widgets/rotulo_secao.dart';
import '../widgets/selo.dart';
import 'palestra_details_page.dart';
import 'patrocinadores_page.dart';

/// Tela de programação de um evento.
///
/// Segue a prancha "Programação (RF03, RF12)" do canvas:
/// - cabeçalho com o nome do evento, o título e dois botões: a lupa, que
///   abre o campo de busca por tema (`ApiService.programacao(eventoId,
///   tema: ...)`, filtrado no backend pelo `PalestraRepository`), e os
///   Patrocinadores do evento (F10, RF19);
/// - abas com todos os dias do evento (`QUA 10`, `QUI 11`), só quando o
///   evento tem mais de um dia. Os dias que já passaram continuam
///   clicáveis, mas ficam acinzentados;
/// - filtros por tema ("Todos" e os temas das palestras do dia);
/// - a lista agrupada em MANHÃ, TARDE e NOITE. Palestras que já
///   terminaram também ficam acinzentadas (e continuam abrindo os
///   detalhes, para ver o resumo e as avaliações).
///
/// Dia e tema são filtrados no próprio app, sobre a lista que já chegou da
/// API: não precisa de uma chamada nova a cada toque.
///
/// O selo `INSCRITA` usa a agenda da pessoa (`ApiService.agenda`, a mesma
/// rota da aba Agenda): as duas listas são buscadas juntas e a palestra
/// que está na agenda ganha o selo. Assim a rota da programação continua
/// igual para todo mundo, sem precisar saber quem está vendo.
class ProgramacaoPage extends StatefulWidget {
  final int eventoId;
  final int usuarioId;
  final String nomeEvento;

  /// Datas de início e fim do evento (`data_inicio` e `data_fim` da API),
  /// usadas para mostrar todos os dias nas abas, até os sem palestra. Sem
  /// elas, as abas mostram só os dias que têm palestra.
  final String? inicioEvento;
  final String? fimEvento;

  const ProgramacaoPage({
    super.key,
    required this.eventoId,
    required this.usuarioId,
    required this.nomeEvento,
    this.inicioEvento,
    this.fimEvento,
  });

  @override
  State<ProgramacaoPage> createState() => _ProgramacaoPageState();
}

/// O que a tela precisa: as palestras do evento e os ids das palestras em
/// que a pessoa está inscrita.
typedef _DadosProgramacao = ({List<Palestra> palestras, Set<int> inscritas});

class _ProgramacaoPageState extends State<ProgramacaoPage> {
  final busca = TextEditingController();
  late Future<_DadosProgramacao> futuro;

  /// Último termo pesquisado. Ao voltar dos detalhes, a lista recarrega
  /// com ele, e não com um texto digitado e ainda não enviado.
  String temaAtual = '';

  /// Se o campo de busca está aberto (aberto e fechado pela lupa).
  bool buscaAberta = false;

  /// Dia escolhido nas abas e tema escolhido nos filtros (`null` = todos).
  DateTime? diaEscolhido;
  String? temaEscolhido;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca a programação e a agenda ao mesmo tempo (`Future.wait` espera
  /// as duas). Se a agenda falhar, a tela abre mesmo assim, só sem o selo
  /// `INSCRITA`: a programação é o que importa aqui.
  Future<_DadosProgramacao> carregar() async {
    final respostas = await Future.wait([
      ApiService.programacao(widget.eventoId, tema: temaAtual),
      ApiService.agenda(widget.usuarioId).catchError((_) => <dynamic>[]),
    ]);
    return (
      palestras: [for (final json in respostas[0]) Palestra.fromJson(Map<String, dynamic>.from(json))],
      inscritas: {for (final json in respostas[1]) json['id_palestra'] as int},
    );
  }

  /// Chaves no `setState`, e não seta: com a seta, a função devolveria o
  /// `Future` atribuído, e o Flutter recusa um `setState` que devolve um
  /// `Future` (ver `recarregar` em `palestra_details_page.dart`).
  void recarregar() {
    setState(() {
      futuro = carregar();
    });
  }

  void pesquisar() {
    temaAtual = busca.text.trim();
    recarregar();
  }

  /// Abre ou fecha o campo de busca. Ao fechar com uma busca feita, limpa
  /// a busca e volta a lista completa.
  void alternarBusca() {
    setState(() => buscaAberta = !buscaAberta);
    if (!buscaAberta && temaAtual.isNotEmpty) {
      busca.clear();
      pesquisar();
    }
  }

  Future<void> abrirDetalhes(Palestra palestra) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: palestra.id),
      ),
    );
    // Ao voltar dos detalhes, recarrega: a pessoa pode ter se inscrito
    // (selo e vagas mudam) ou avaliado (média nova).
    if (mounted) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabecalhoAba(
            rotulo: widget.nomeEvento,
            titulo: 'Programação',
            acoes: [
              BotaoCabecalho(
                icone: Icons.handshake_outlined,
                dica: 'Patrocinadores',
                aoTocar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatrocinadoresPage(eventoId: widget.eventoId, nomeEvento: widget.nomeEvento),
                  ),
                ),
              ),
              BotaoCabecalho(
                icone: buscaAberta ? Icons.close : Icons.search,
                dica: buscaAberta ? 'Fechar busca' : 'Buscar',
                ligado: buscaAberta,
                aoTocar: alternarBusca,
              ),
            ],
          ),
          if (buscaAberta)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: busca,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => pesquisar(),
                decoration: InputDecoration(
                  hintText: 'Pesquisar por tema',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Pesquisar',
                    onPressed: pesquisar,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<_DadosProgramacao>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                return _corpo(context, snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Abas de dia, filtros de tema e a lista agrupada por período.
  Widget _corpo(BuildContext context, _DadosProgramacao dados) {
    final dias = _diasDoEvento(dados.palestras);

    // Dia mostrado: o escolhido; sem escolha, hoje (se for um dia do
    // evento) ou o primeiro dia.
    final hoje = DateUtils.dateOnly(DateTime.now());
    final dia = dias.contains(diaEscolhido) ? diaEscolhido : (dias.contains(hoje) ? hoje : dias.firstOrNull);

    final doDia = [
      for (final p in dados.palestras)
        if (dia == null || (p.dataInicio != null && DateUtils.isSameDay(p.dataInicio, dia))) p,
    ];
    final temas = _temas(doDia);
    // As cores vêm dos temas do evento inteiro (e não só do dia), para
    // cada tema ter sempre a mesma cor em todos os dias.
    final temasDoEvento = _temas(dados.palestras);
    final agora = DateTime.now();
    final tema = temas.contains(temaEscolhido) ? temaEscolhido : null;
    final lista = [for (final p in doDia) if (tema == null || p.tema == tema) p];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        if (dias.length > 1) ...[
          _AbasDias(
            dias: dias,
            escolhido: dia!,
            aoEscolher: (d) => setState(() => diaEscolhido = d),
          ),
          const SizedBox(height: 14),
        ],
        if (temas.isNotEmpty) ...[
          _FiltroTemas(
            temas: temas,
            escolhido: tema,
            aoEscolher: (t) => setState(() => temaEscolhido = t),
          ),
          const SizedBox(height: 4),
        ],
        // Lista vazia: a busca não achou nada, o evento ainda não tem
        // palestra cadastrada, ou só este dia está sem palestra.
        if (lista.isEmpty)
          AvisoVazio(
            temaAtual.isNotEmpty
                ? 'Nenhuma palestra encontrada para "$temaAtual" neste dia.'
                : dados.palestras.isEmpty
                    ? 'Nenhuma palestra cadastrada neste evento ainda.'
                    : 'Nenhuma palestra neste dia.',
          ),
        for (var i = 0; i < lista.length; i++) ...[
          // Abre um grupo quando o período muda (MANHÃ → TARDE).
          if (i == 0 || _periodo(lista[i - 1]) != _periodo(lista[i])) _TituloPeriodo(_periodo(lista[i])),
          _ItemPalestra(
            palestra: lista[i],
            inscrita: dados.inscritas.contains(lista[i].id),
            corTema: _corDoTema(context, temasDoEvento, lista[i].tema),
            encerrada: lista[i].encerradaEm(agora),
            emAndamento: lista[i].emAndamentoEm(agora),
            aoTocar: () => abrirDetalhes(lista[i]),
          ),
        ],
      ],
    );
  }

  /// Todos os dias do evento, do início ao fim, mais qualquer dia que
  /// tenha palestra fora dessas datas (o backend não impede esse
  /// cadastro, e sem a aba a palestra sumiria da tela). O `Set` evita dia
  /// repetido; `DateUtils.dateOnly` tira a hora, para comparar só o dia.
  List<DateTime> _diasDoEvento(List<Palestra> palestras) {
    final dias = <DateTime>{
      for (final p in palestras)
        if (p.dataInicio != null) DateUtils.dateOnly(p.dataInicio!),
    };
    final inicio = DateTime.tryParse(widget.inicioEvento ?? '');
    final fim = DateTime.tryParse(widget.fimEvento ?? '') ?? inicio;
    if (inicio != null && fim != null) {
      // `DateTime(ano, mes, dia + 1)` avança um dia certinho, mesmo na
      // virada do mês.
      for (var d = DateUtils.dateOnly(inicio); !d.isAfter(fim); d = DateTime(d.year, d.month, d.day + 1)) {
        dias.add(d);
      }
    }
    return dias.toList()..sort();
  }

  /// Temas das palestras, sem repetir e em ordem alfabética.
  List<String> _temas(List<Palestra> palestras) =>
      {for (final p in palestras) if (p.tema != null && p.tema!.trim().isNotEmpty) p.tema!}.toList()..sort();

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }
}

/// Período do dia da palestra, usado nos títulos dos grupos.
String _periodo(Palestra p) {
  final hora = p.dataInicio?.hour;
  if (hora == null) return 'Horário a definir';
  if (hora < 12) return 'Manhã';
  if (hora < 18) return 'Tarde';
  return 'Noite';
}

/// Cor do quadradinho de cada tema. Os temas vêm do banco (não dá para
/// fixar uma cor por nome, como o canvas faz com três temas de exemplo),
/// então cada tema recebe uma cor do tema do app pela posição na lista.
Color _corDoTema(BuildContext context, List<String> temas, String? tema) {
  final cores = Theme.of(context).colorScheme;
  final paleta = [cores.secondary, cores.secondaryContainer, cores.primary, cores.tertiary];
  final posicao = tema == null ? -1 : temas.indexOf(tema);
  return posicao < 0 ? cores.outline : paleta[posicao % paleta.length];
}

/// Abas de dia: um bloco com fundo de apoio e o dia escolhido na cor
/// principal, em JetBrains Mono (ex.: `QUA 10`). Dias que já passaram
/// ficam acinzentados (`Opacity`), mas continuam clicáveis.
///
/// Até 4 dias, as abas dividem a largura (`Expanded`); com mais, cada aba
/// tem largura fixa e a faixa rola para o lado, para não espremer o texto.
class _AbasDias extends StatelessWidget {
  final List<DateTime> dias;
  final DateTime escolhido;
  final ValueChanged<DateTime> aoEscolher;

  const _AbasDias({required this.dias, required this.escolhido, required this.aoEscolher});

  static const _maximoSemRolar = 4;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final cabem = dias.length <= _maximoSemRolar;
    final abas = [
      for (final d in dias)
        cabem ? Expanded(child: _aba(context, d)) : SizedBox(width: 82, child: _aba(context, d)),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: cores.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: cabem
          ? Row(children: abas)
          : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: abas)),
    );
  }

  Widget _aba(BuildContext context, DateTime d) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final ligada = DateUtils.isSameDay(d, escolhido);
    final passou = d.isBefore(DateUtils.dateOnly(DateTime.now()));

    return Opacity(
      opacity: passou ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: ligada ? cores.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () => aoEscolher(d),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  diaCurto(d),
                  style: tema.textTheme.labelMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: ligada ? FontWeight.w700 : FontWeight.w500,
                    color: ligada ? cores.onPrimary : cores.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filtros de tema: "Todos" e um botão por tema, numa linha que rola para
/// o lado quando os temas não cabem na tela.
class _FiltroTemas extends StatelessWidget {
  final List<String> temas;
  final String? escolhido;
  final ValueChanged<String?> aoEscolher;

  const _FiltroTemas({required this.temas, required this.escolhido, required this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    Widget botao(String nome, String? valor) {
      final ligado = escolhido == valor;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: OutlinedButton(
          onPressed: () => aoEscolher(valor),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: ligado ? cores.onSurface : Colors.transparent,
            foregroundColor: ligado ? Theme.of(context).scaffoldBackgroundColor : cores.onSurface,
            side: BorderSide(color: ligado ? cores.onSurface : cores.outline),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: TextStyle(fontSize: 13, fontWeight: ligado ? FontWeight.w600 : FontWeight.w500),
          ),
          child: Text(nome),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        botao('Todos', null),
        for (final t in temas) botao(t, t),
      ]),
    );
  }
}

/// Título de um grupo (MANHÃ, TARDE, NOITE) com a ondinha do rio na cor
/// Rio (`secondary`), como no canvas.
class _TituloPeriodo extends StatelessWidget {
  final String texto;

  const _TituloPeriodo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(children: [
        CustomPaint(size: const Size(22, 8), painter: _Ondinha(Theme.of(context).colorScheme.secondary)),
        const SizedBox(width: 8),
        RotuloSecao(texto),
      ]),
    );
  }
}

/// Desenha a ondinha de 22 × 8 do canvas (uma curva para cima e outra
/// para baixo).
class _Ondinha extends CustomPainter {
  final Color cor;

  _Ondinha(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final caminho = Path()
      ..moveTo(1, 4)
      ..cubicTo(4, 0, 7, 0, 11, 4)
      ..cubicTo(15, 8, 18, 8, 21, 4);
    canvas.drawPath(
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Ondinha antigo) => antigo.cor != cor;
}

/// Um item da lista, como na prancha: horário à esquerda em JetBrains
/// Mono; à direita, título, "sala · palestrante", o tema com o quadradinho
/// de cor e o selo de situação; e, desde a F07, a média de estrelas quando
/// a palestra já tem avaliações.
///
/// Palestra `encerrada` (já terminou) aparece acinzentada, com o mesmo
/// layout, e continua abrindo os detalhes.
class _ItemPalestra extends StatelessWidget {
  final Palestra palestra;
  final bool inscrita;
  final Color corTema;
  final bool encerrada;
  final bool emAndamento;
  final VoidCallback aoTocar;

  const _ItemPalestra({
    required this.palestra,
    required this.inscrita,
    required this.corTema,
    required this.encerrada,
    required this.emAndamento,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final p = palestra;
    final local = [p.sala ?? 'Local a definir', if (p.palestrante != null) p.palestrante!].join(' · ');

    // Um selo só, pela ordem: encerrada, em andamento, inscrita, esgotada
    // e vagas. A situação no tempo vem primeiro porque, depois que a
    // palestra começa, vagas e inscrição deixam de ser a informação
    // principal. Inscrita vem antes de esgotada: quem já tem vaga não
    // precisa saber se esgotou.
    final Selo selo = encerrada
        ? const Selo('Encerrada', tipo: TipoSelo.alerta)
        : emAndamento
            ? const Selo('Em andamento')
            : inscrita
                ? const Selo('Inscrita', tipo: TipoSelo.destaque)
                : p.vagas <= 0
                    ? const Selo('Esgotada', tipo: TipoSelo.alerta)
                    : Selo('${p.vagas.toString().padLeft(2, '0')} ${p.vagas == 1 ? 'vaga' : 'vagas'}');

    return InkWell(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.outlineVariant))),
        // A linha de baixo fica fora do `Opacity`, para as divisórias da
        // lista continuarem iguais.
        child: Opacity(
          opacity: encerrada ? 0.45 : 1,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 54,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  p.horaInicio,
                  style: tema.textTheme.labelMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: cores.primary),
                ),
                const SizedBox(height: 3),
                Text(p.horaFim, style: tema.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.titulo, style: tema.textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(local, style: tema.textTheme.bodySmall),
                const SizedBox(height: 5),
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: corTema, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.tema ?? 'Sem tema',
                      style: tema.textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  selo,
                ]),
                if (p.totalAvaliacoes > 0) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Estrelas(nota: p.mediaEstrelas ?? 0, tamanho: 14),
                    const SizedBox(width: 6),
                    Text('${p.mediaTexto} · ${p.totalAvaliacoes}', style: tema.textTheme.labelMedium),
                  ]),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
