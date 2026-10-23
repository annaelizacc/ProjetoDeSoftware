import 'package:flutter/material.dart';

/// Componente compartilhado: cabeçalho das abas da barra de navegação.
///
/// Nas pranchas de Programação, Agenda e Avisos o topo é diferente das
/// telas internas (`CabecalhoTela`): um rótulo em JetBrains Mono (ex.:
/// `SEMANA DE TECNOLOGIA`, `QUA 10 OUT · 3 PALESTRAS`), o título grande em
/// Bricolage (`headlineMedium`, 30px) e, à direita, botões quadrados de
/// 44px (busca, setas de dia...), sem linha embaixo.
///
/// Quando a tela foi aberta por cima de outra (ex.: a Programação aberta
/// pelo "Ver programação" do Início), aparece também o botão de voltar.
class CabecalhoAba extends StatelessWidget {
  final String rotulo;
  final String titulo;

  /// Botões à direita do título. Use `BotaoCabecalho` para o visual do
  /// canvas.
  final List<Widget> acoes;

  const CabecalhoAba({super.key, required this.rotulo, required this.titulo, this.acoes = const []});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final podeVoltar = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, podeVoltar ? 4 : 22, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (podeVoltar)
              Transform.translate(
                // Alinha o ícone com o texto (o botão tem margem interna).
                offset: const Offset(-12, 0),
                child: IconButton(
                  tooltip: 'Voltar',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rotulo.toUpperCase(), style: textos.labelMedium),
                      const SizedBox(height: 6),
                      Text(titulo, style: textos.headlineMedium),
                    ],
                  ),
                ),
                for (final acao in acoes) ...[const SizedBox(width: 6), acao],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão quadrado de 44px do cabeçalho (fundo de card, linha fina e cantos
/// de 10px), como a lupa da Programação e as setas da Agenda.
class BotaoCabecalho extends StatelessWidget {
  final IconData icone;
  final String dica;
  final VoidCallback? aoTocar;

  /// Ligado: fundo na cor de destaque (ex.: a busca aberta).
  final bool ligado;

  const BotaoCabecalho({super.key, required this.icone, required this.dica, this.aoTocar, this.ligado = false});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: dica,
      onPressed: aoTocar,
      icon: Icon(icone, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        foregroundColor: cores.onSurface,
        backgroundColor: ligado ? cores.tertiary : cores.surface,
        side: BorderSide(color: cores.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
