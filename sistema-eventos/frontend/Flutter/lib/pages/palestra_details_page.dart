import 'package:flutter/material.dart';

import '../models/avaliacao.dart';
import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aviso_choque_horario.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/estrelas.dart';
import '../widgets/perfil_palestrante.dart';
import '../widgets/picote.dart';
import '../widgets/rotulo_secao.dart';
import '../widgets/selo.dart';
import 'avaliar_page.dart';
import 'planta_page.dart';

/// O que a tela carrega: a palestra e a lista de avaliações. É um
/// "record" do Dart, um par de valores com nome, sem precisar criar uma
/// classe só para isso.
typedef _DadosDetalhes = ({Palestra palestra, List<Avaliacao> avaliacoes});

/// Tela de detalhes da palestra.
///
/// Busca os dados completos de uma palestra, já com as flags do usuário
/// logado (`inscrito`, `favorita`, `lembreteAtivo`, `podeAvaliar`), em
/// `GET /api/palestras/<id>` (`ApiService.palestra`, usuário vindo do
/// token), e as avaliações em `GET /api/avaliacoes/palestra/<id>`. A
/// partir daqui o usuário pode:
/// - se inscrever ou cancelar a inscrição (`/api/inscricoes`);
/// - favoritar ou remover dos favoritos (`/api/favoritos`);
/// - ativar ou desativar o lembrete da palestra (`/api/lembretes`);
/// - avaliar, editar ou excluir a própria avaliação, na tela Avaliar
///   (F06 e F07), quando já está inscrito e a palestra começou.
///
/// Depois de qualquer ação, a tela recarrega os dados (`carregar()`) para
/// refletir o novo estado vindo do backend, em vez de tentar adivinhar o
/// resultado no próprio Flutter.
///
/// Visual da prancha "Detalhes da palestra" do canvas (F20): topo Céu com
/// o rio, o selo do tema e o título grande (`_TopoDetalhes`), linhas de
/// informação (quando, onde e palestrante), cartão de vagas, avaliações e
/// uma barra fixa embaixo, separada pelo picote, com favoritar, lembrete e
/// inscrição. Tocar no palestrante ("Ver perfil") abre o perfil dele
/// (`abrirPerfilPalestrante`).
///
/// Palestra que já começou (em andamento ou encerrada) não aceita mais
/// inscrição nem cancelamento (F16, bloqueado também no backend). Por
/// isso o cartão de vagas e o lembrete somem; quem estava inscrito vê só
/// favoritar e Avaliar (ou Editar avaliação), e quem não estava não vê a
/// barra.
///
/// Rotas (F04, RF11): a linha "Onde" tem o botão "Ver planta", que abre a
/// planta do evento (`PlantaPage`, F03), e a seção "Como chegar" mostra o
/// passo a passo da entrada até a sala (`como_chegar` no JSON).
class PalestraDetailsPage extends StatefulWidget {
  final int usuarioId;
  final int palestraId;

  const PalestraDetailsPage({super.key, required this.usuarioId, required this.palestraId});

  @override
  State<PalestraDetailsPage> createState() => _PalestraDetailsPageState();
}

class _PalestraDetailsPageState extends State<PalestraDetailsPage> {
  /// A palestra e a lista de avaliações chegam juntas: o `Future.wait`
  /// faz as duas requisições ao mesmo tempo e espera as duas terminarem.
  late Future<_DadosDetalhes> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  Future<_DadosDetalhes> carregar() async {
    final respostas = await Future.wait([
      ApiService.palestra(widget.palestraId, widget.usuarioId),
      // Se só a lista de avaliações falhar, a tela abre mesmo assim (sem
      // os comentários), para a inscrição e os outros botões continuarem
      // funcionando.
      ApiService.avaliacoes(widget.palestraId).catchError((_) => <dynamic>[]),
    ]);
    return (
      palestra: Palestra.fromJson(respostas[0] as Map<String, dynamic>),
      avaliacoes: [
        for (final item in respostas[1] as List<dynamic>) Avaliacao.fromJson(Map<String, dynamic>.from(item)),
      ],
    );
  }

  /// Busca os dados de novo e redesenha a tela com o `FutureBuilder`.
  ///
  /// O `setState` usa chaves de propósito. Com a seta
  /// (`setState(() => futuro = carregar())`), a função devolveria o valor
  /// da atribuição, que é um `Future`, e o Flutter recusa isso com o erro
  /// "setState() callback argument returned a Future". Aqui o `setState`
  /// só troca a variável (síncrono); quem espera a resposta é o
  /// `FutureBuilder`.
  void recarregar() {
    if (!mounted) return;
    setState(() {
      futuro = carregar();
    });
  }

  /// Executa uma ação da API (inscrever, favoritar, etc.) e recarrega os
  /// dados da tela; erros de negócio vindos do backend (ex.: "sem vagas")
  /// aparecem como um SnackBar, sem quebrar a tela.
  Future<void> executar(Future<void> Function() acao) async {
    try {
      await acao();
      recarregar();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  /// Abre o perfil do palestrante. Tocar numa palestra do perfil fecha a
  /// janela e, se for outra palestra, abre os detalhes dela.
  void abrirPerfil(Palestra p) {
    abrirPerfilPalestrante(
      context,
      idPalestrante: p.idPalestrante!,
      idEvento: p.idEvento!,
      aoAbrirPalestra: (outra) {
        Navigator.pop(context);
        if (outra.id == p.id) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: outra.id),
          ),
        );
      },
    );
  }

  /// Inscreve na palestra (F16). Se a API avisar que a pessoa já tem
  /// inscrição em outra palestra no mesmo horário, mostra o aviso de
  /// choque e só inscreve se a pessoa tocar em "Inscrever mesmo assim".
  Future<void> inscreverComAvisoDeChoque(Palestra p) async {
    try {
      await ApiService.inscrever(widget.usuarioId, p.id);
    } on ChoqueDeHorarioException catch (aviso) {
      if (!mounted) return;
      final confirmou = await mostrarAvisoDeChoque(
        context,
        jaInscrita: Palestra.fromJson(aviso.palestraConflitante),
        nova: p,
      );
      if (confirmou) {
        await ApiService.inscrever(widget.usuarioId, p.id, confirmarChoque: true);
      }
    }
  }

  /// Abre a planta do evento (F03) a partir da linha "Onde" (F04).
  void abrirPlanta(Palestra p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantaPage(eventoId: p.idEvento!, nomeEvento: p.nomeEvento ?? ''),
      ),
    );
  }

  /// Abre a tela Avaliar e, se algo mudou (ela devolve `true`), recarrega
  /// a média e os comentários.
  Future<void> abrirAvaliar(Palestra p) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AvaliarPage(palestra: p)),
    );
    if (mudou == true) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_DadosDetalhes>(
        future: futuro,
        builder: (context, snapshot) {
          // Carregando: o cabeçalho continua na tela, com o botão de voltar.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(children: [
              CabecalhoTela(titulo: 'Palestra'),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ]);
          }
          if (snapshot.hasError) {
            return Column(children: [
              const CabecalhoTela(titulo: 'Palestra'),
              Expanded(child: Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')))),
            ]);
          }
          final p = snapshot.data!.palestra;
          final agora = DateTime.now();
          final comecou = p.emAndamentoEm(agora) || p.encerradaEm(agora);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                // O topo fica dentro da lista e rola junto com o conteúdo;
                // só a barra de ações fica fixa embaixo.
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _TopoDetalhes(palestra: p),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LinhaInfo(rotulo: 'Quando', valor: p.horario, mono: true),
                          _LinhaInfo(
                            rotulo: 'Onde',
                            valor: p.sala ?? 'Local a definir',
                            textoAcao: 'Ver planta',
                            aoTocar: p.idEvento == null ? null : () => abrirPlanta(p),
                          ),
                          if (p.palestrante != null)
                            _LinhaInfo(
                              rotulo: 'Palestrante',
                              valor: p.palestrante!,
                              textoAcao: 'Ver perfil',
                              aoTocar: p.idPalestrante == null || p.idEvento == null ? null : () => abrirPerfil(p),
                            ),
                          if (passosDaRota(p.comoChegar).isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _ComoChegar(passos: passosDaRota(p.comoChegar)),
                          ],
                          const SizedBox(height: 18),
                          const RotuloSecao('Sobre'),
                          const SizedBox(height: 6),
                          Text(p.resumo ?? 'Resumo não informado.', style: Theme.of(context).textTheme.bodyLarge),
                          // Depois que a palestra começa, as vagas não importam
                          // mais: ninguém entra nem sai.
                          if (!comecou) ...[
                            const SizedBox(height: 18),
                            _CartaoVagas(palestra: p),
                          ],
                          const SizedBox(height: 22),
                          _SecaoAvaliacoes(
                            palestra: p,
                            avaliacoes: snapshot.data!.avaliacoes,
                            aoAvaliar: () => abrirAvaliar(p),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Quem não estava inscrito numa palestra que já começou não
              // tem o que fazer na barra, então ela não aparece.
              if (!comecou || p.inscrito)
                _BarraAcoes(
                  palestra: p,
                  comecou: comecou,
                  aoInscrever: () => executar(() =>
                      p.inscrito ? ApiService.cancelarInscricao(widget.usuarioId, p.id) : inscreverComAvisoDeChoque(p)),
                  aoFavoritar: () => executar(() => ApiService.alterarFavorito(widget.usuarioId, p.id, !p.favorita)),
                  aoLembrar: () => executar(() => ApiService.alterarLembrete(widget.usuarioId, p.id, !p.lembreteAtivo)),
                  aoAvaliar: () => abrirAvaliar(p),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Topo da prancha "Detalhes da palestra": fundo Céu, o rio descendo pela
/// direita, o botão de voltar, o selo do tema e o título grande.
///
/// No modo escuro a prancha usa outro fundo (`surfaceContainer`) e o
/// texto claro (`onSurface`). O selo é o `Selo` de destaque, que já troca
/// sozinho (Marinho no claro, Céu no escuro).
class _TopoDetalhes extends StatelessWidget {
  final Palestra palestra;

  const _TopoDetalhes({required this.palestra});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final escuro = tema.brightness == Brightness.dark;
    final fundo = escuro ? cores.surfaceContainer : cores.tertiary;
    final corTexto = escuro ? cores.onSurface : cores.onTertiary;
    final tag = palestra.tema;

    return Container(
      color: fundo,
      // `minHeight`: os 230px da prancha; um título longo faz o topo
      // crescer em vez de cortar o texto.
      constraints: const BoxConstraints(minHeight: 230),
      child: CustomPaint(
        painter: _RioDoTopo(escuro ? AppColors.rioTopoEscuro : AppColors.rioTopo),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Voltar',
                  color: corTexto,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 56),
                Padding(
                  // 290px de largura, como na prancha: o título não passa
                  // por cima do rio.
                  padding: const EdgeInsets.only(left: 10, right: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tag != null && tag.isNotEmpty) ...[
                        Selo(tag, tipo: TipoSelo.destaque),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        palestra.titulo,
                        style: tema.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          height: 1.12,
                          letterSpacing: -0.3,
                          color: corTexto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Desenha o rio do topo: a mesma curva da prancha (390px de largura),
/// presa à borda direita e com espessura fixa de 18px. Em telas largas o
/// rio não estica, só fica mais longe do título.
class _RioDoTopo extends CustomPainter {
  final Color cor;

  _RioDoTopo(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    // Desloca a curva para que a borda direita da prancha (x = 390) fique
    // na borda direita da tela.
    final dx = size.width - 390;
    final caminho = Path()
      ..moveTo(334 + dx, -10)
      ..cubicTo(282 + dx, 40, 292 + dx, 96, 336 + dx, 128)
      ..cubicTo(378 + dx, 160, 370 + dx, 206, 330 + dx, size.height + 20);
    canvas.drawPath(
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RioDoTopo antigo) => antigo.cor != cor;
}

/// Uma linha "rótulo · valor" com linha fina embaixo (ex.: QUANDO 09:00).
///
/// Com `aoTocar`, a linha toda pode ser tocada e mostra `textoAcao` à
/// direita (ex.: PALESTRANTE Carla Souza · Ver perfil).
class _LinhaInfo extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool mono;
  final String? textoAcao;
  final VoidCallback? aoTocar;

  const _LinhaInfo({
    required this.rotulo,
    required this.valor,
    this.mono = false,
    this.textoAcao,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final linha = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cores.outlineVariant)),
      ),
      child: Row(children: [
        SizedBox(width: 112, child: Text(rotulo.toUpperCase(), style: textos.labelMedium)),
        Expanded(
          child: Text(
            valor,
            style: mono
                ? textos.labelMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: cores.onSurface)
                : textos.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        if (aoTocar != null && textoAcao != null)
          Text(textoAcao!, style: textos.labelLarge?.copyWith(fontSize: 13, color: cores.primary)),
      ]),
    );
    return aoTocar == null ? linha : InkWell(onTap: aoTocar, child: linha);
  }
}

/// Separa o "como chegar" em passos: o organizador escreve um passo por
/// linha (ex.: "1. Entre pelo hall principal."). Linhas vazias são
/// ignoradas, e a numeração digitada ("1.", "2)", "3 -") sai, porque a
/// tela desenha o próprio número.
List<String> passosDaRota(String? texto) {
  if (texto == null) return [];
  return [
    for (final linha in texto.split('\n'))
      if (linha.trim().isNotEmpty) linha.trim().replaceFirst(RegExp(r'^\d+\s*[.)-]\s*'), ''),
  ];
}

/// Seção "Como chegar · a partir da entrada" (F04, RF11), como na prancha
/// "Detalhes da palestra" do canvas: cada passo com o número num
/// quadradinho Marinho.
class _ComoChegar extends StatelessWidget {
  final List<String> passos;

  const _ComoChegar({required this.passos});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RotuloSecao('Como chegar · a partir da entrada'),
        const SizedBox(height: 10),
        for (var i = 0; i < passos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cores.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: textos.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cores.onPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(passos[i], style: textos.bodyLarge?.copyWith(height: 1.4))),
              ],
            ),
          ),
      ],
    );
  }
}

/// Cartão com as vagas livres e uma barra de ocupação. Palestra lotada
/// aparece na cor `error` (Brasa), a cor de "esgotada e atenção".
class _CartaoVagas extends StatelessWidget {
  final Palestra palestra;

  const _CartaoVagas({required this.palestra});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final rotulo = Theme.of(context).textTheme.labelMedium;
    final p = palestra;
    final lotada = p.vagas <= 0;
    final ocupacao = p.total == 0 ? 0.0 : (p.total - p.vagas) / p.total;
    final nota = p.inscrito
        ? 'SUA VAGA ESTÁ GARANTIDA'
        : lotada
            ? 'ESGOTADA'
            : 'DISPONÍVEIS';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cores.outlineVariant),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${p.vagas}/${p.total} VAGAS',
              style: rotulo?.copyWith(fontWeight: FontWeight.w700, color: cores.onSurface)),
          Text(nota, style: lotada && !p.inscrito ? rotulo?.copyWith(color: cores.error) : rotulo),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ocupacao,
            minHeight: 6,
            color: lotada ? cores.error : cores.primary,
            backgroundColor: cores.secondaryContainer,
          ),
        ),
      ]),
    );
  }
}

/// Seção "Avaliações e comentários" (F06 e F07): média, total, o botão
/// para avaliar e a lista de comentários.
class _SecaoAvaliacoes extends StatelessWidget {
  final Palestra palestra;
  final List<Avaliacao> avaliacoes;
  final VoidCallback aoAvaliar;

  const _SecaoAvaliacoes({required this.palestra, required this.avaliacoes, required this.aoAvaliar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final p = palestra;

    // Quem já avaliou sempre pode editar ou excluir. Quem ainda não
    // avaliou só vê "Avaliar" quando o backend diz que pode criar.
    final jaAvaliou = p.minhaAvaliacao != null;

    // Explica por que o botão não aparece. Não inscrito vem primeiro,
    // na mesma ordem em que o backend confere as regras.
    final String? aviso = jaAvaliou || p.podeAvaliar
        ? null
        : !p.inscrito
            ? 'Só quem está inscrito pode avaliar.'
            : 'A avaliação abre quando a palestra começar.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const RotuloSecao('Avaliações e comentários'),
          if (jaAvaliou || p.podeAvaliar)
            TextButton(
              onPressed: aoAvaliar,
              child: Text(jaAvaliou ? 'Editar avaliação' : 'Avaliar'),
            ),
        ]),
        const SizedBox(height: 8),
        if (p.totalAvaliacoes == 0)
          Text('Ainda sem avaliações.', style: tema.textTheme.bodySmall)
        else
          Row(children: [
            Text(p.mediaTexto, style: tema.textTheme.headlineMedium?.copyWith(fontSize: 36)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Estrelas(nota: p.mediaEstrelas ?? 0),
              const SizedBox(height: 4),
              Text(
                p.totalAvaliacoes == 1 ? '1 AVALIAÇÃO' : '${p.totalAvaliacoes} AVALIAÇÕES',
                style: tema.textTheme.labelSmall,
              ),
            ]),
          ]),
        if (aviso != null) ...[
          const SizedBox(height: 8),
          Text(aviso, style: tema.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        for (final a in avaliacoes) _Comentario(avaliacao: a),
      ],
    );
  }
}

/// Um comentário da lista: autor, nota, data e o texto (se houver).
class _Comentario extends StatelessWidget {
  final Avaliacao avaliacao;

  const _Comentario({required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final a = avaliacao;
    final temTexto = a.comentario != null && a.comentario!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: tema.colorScheme.outlineVariant))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Text(a.nomeUsuario ?? 'Participante', style: tema.textTheme.titleSmall?.copyWith(fontSize: 14))),
          Text('${a.nota} ★ · ${a.dataCurta}', style: tema.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
        ]),
        if (temTexto) ...[
          const SizedBox(height: 4),
          Text(a.comentario!, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        ],
      ]),
    );
  }
}

/// Barra fixa embaixo, separada do conteúdo pelo picote.
///
/// Antes de a palestra começar: favoritar, lembrete e o botão principal de
/// inscrição. Depois (`comecou`), para quem estava inscrito: só favoritar
/// e Avaliar (ou Editar avaliação), quando o backend permite.
class _BarraAcoes extends StatelessWidget {
  final Palestra palestra;
  final bool comecou;
  final VoidCallback aoInscrever;
  final VoidCallback aoFavoritar;
  final VoidCallback aoLembrar;
  final VoidCallback aoAvaliar;

  const _BarraAcoes({
    required this.palestra,
    required this.comecou,
    required this.aoInscrever,
    required this.aoFavoritar,
    required this.aoLembrar,
    required this.aoAvaliar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final p = palestra;

    // Botão quadrado de 52px; quando ligado, fica com fundo céu
    // (`tertiary`), o destaque da identidade visual.
    Widget botaoIcone({
      required bool ligado,
      required IconData icone,
      required IconData iconeLigado,
      required String dica,
      required VoidCallback aoTocar,
    }) {
      return IconButton(
        tooltip: dica,
        isSelected: ligado,
        onPressed: aoTocar,
        icon: Icon(icone),
        selectedIcon: Icon(iconeLigado),
        style: IconButton.styleFrom(
          fixedSize: const Size(52, 52),
          foregroundColor: cores.onSurface,
          backgroundColor: ligado ? cores.tertiary : Colors.transparent,
          side: BorderSide(color: cores.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    final favoritar = botaoIcone(
      ligado: p.favorita,
      icone: Icons.star_border_rounded,
      iconeLigado: Icons.star_rounded,
      dica: p.favorita ? 'Remover dos favoritos' : 'Favoritar',
      aoTocar: aoFavoritar,
    );

    // A mesma regra da seção de avaliações: quem já avaliou edita; quem
    // ainda não avaliou só vê o botão quando o backend deixa criar.
    final jaAvaliou = p.minhaAvaliacao != null;

    final List<Widget> botoes = comecou
        ? [
            favoritar,
            if (jaAvaliou || p.podeAvaliar) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: aoAvaliar,
                  child: Text(jaAvaliou ? 'Editar avaliação' : 'Avaliar'),
                ),
              ),
            ],
          ]
        : [
            favoritar,
            const SizedBox(width: 10),
            botaoIcone(
              ligado: p.lembreteAtivo,
              icone: Icons.notifications_none,
              iconeLigado: Icons.notifications_active,
              dica: p.lembreteAtivo ? 'Desativar lembrete' : 'Ativar lembrete',
              aoTocar: aoLembrar,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: p.inscrito
                  ? OutlinedButton(onPressed: aoInscrever, child: const Text('Cancelar inscrição'))
                  : FilledButton(
                      onPressed: p.vagas > 0 ? aoInscrever : null,
                      child: Text(p.vagas > 0 ? 'Garantir vaga' : 'Palestra lotada'),
                    ),
            ),
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Picote(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: SafeArea(top: false, child: Row(children: botoes)),
        ),
      ],
    );
  }
}
