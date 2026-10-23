import 'package:flutter/material.dart';

import '../models/avaliacao.dart';
import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/estrelas.dart';
import '../widgets/perfil_palestrante.dart';
import '../widgets/rotulo_secao.dart';
import 'avaliar_page.dart';

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
/// Visual da prancha "Detalhes da palestra" do canvas (F20): cabeçalho
/// com o título, linhas de informação (quando, onde e palestrante),
/// cartão de vagas, avaliações e uma barra fixa embaixo com favoritar,
/// lembrete e inscrição. Tocar no palestrante ("Ver perfil") abre o
/// perfil dele (`abrirPerfilPalestrante`).
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CabecalhoTela(titulo: p.titulo, secao: p.tema ?? 'Palestra'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  children: [
                    _LinhaInfo(rotulo: 'Quando', valor: p.horario, mono: true),
                    _LinhaInfo(rotulo: 'Onde', valor: p.sala ?? 'Local a definir'),
                    if (p.palestrante != null)
                      _LinhaInfo(
                        rotulo: 'Palestrante',
                        valor: p.palestrante!,
                        textoAcao: 'Ver perfil',
                        aoTocar: p.idPalestrante == null || p.idEvento == null ? null : () => abrirPerfil(p),
                      ),
                    const SizedBox(height: 18),
                    const RotuloSecao('Sobre'),
                    const SizedBox(height: 6),
                    Text(p.resumo ?? 'Resumo não informado.', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 18),
                    _CartaoVagas(palestra: p),
                    const SizedBox(height: 22),
                    _SecaoAvaliacoes(
                      palestra: p,
                      avaliacoes: snapshot.data!.avaliacoes,
                      aoAvaliar: () => abrirAvaliar(p),
                    ),
                  ],
                ),
              ),
              _BarraAcoes(
                palestra: p,
                aoInscrever: () => executar(() => p.inscrito
                    ? ApiService.cancelarInscricao(widget.usuarioId, p.id)
                    : ApiService.inscrever(widget.usuarioId, p.id)),
                aoFavoritar: () => executar(() => ApiService.alterarFavorito(widget.usuarioId, p.id, !p.favorita)),
                aoLembrar: () => executar(() => ApiService.alterarLembrete(widget.usuarioId, p.id, !p.lembreteAtivo)),
              ),
            ],
          );
        },
      ),
    );
  }
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
          Text('${p.vagas}/${p.total} VAGAS', style: rotulo?.copyWith(fontWeight: FontWeight.w700, color: cores.onSurface)),
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
          Flexible(child: Text(a.nomeUsuario ?? 'Participante', style: tema.textTheme.titleSmall?.copyWith(fontSize: 14))),
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

/// Barra fixa embaixo: favoritar, lembrete e o botão principal de inscrição.
class _BarraAcoes extends StatelessWidget {
  final Palestra palestra;
  final VoidCallback aoInscrever;
  final VoidCallback aoFavoritar;
  final VoidCallback aoLembrar;

  const _BarraAcoes({
    required this.palestra,
    required this.aoInscrever,
    required this.aoFavoritar,
    required this.aoLembrar,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: cores.outline))),
      child: SafeArea(
        top: false,
        child: Row(children: [
          botaoIcone(
            ligado: p.favorita,
            icone: Icons.star_border_rounded,
            iconeLigado: Icons.star_rounded,
            dica: p.favorita ? 'Remover dos favoritos' : 'Favoritar',
            aoTocar: aoFavoritar,
          ),
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
        ]),
      ),
    );
  }
}
