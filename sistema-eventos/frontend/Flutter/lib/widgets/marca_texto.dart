import 'package:flutter/material.dart';

/// Componente compartilhado: marca-texto (grifo) da identidade visual.
///
/// Desenha uma faixa na cor de destaque (`colorScheme.tertiary`, o Céu)
/// atrás da parte de baixo do texto, como uma caneta marca-texto. Usado no
/// nome da pessoa ("Bom dia, Ana"), no slogan e na aba atual da barra de
/// navegação.
///
/// Para grifar só uma palavra dentro de uma frase, use com `WidgetSpan`:
/// `Text.rich(TextSpan(text: 'Bom dia, ', children: [WidgetSpan(child: MarcaTexto('Ana'))]))`.
class MarcaTexto extends StatelessWidget {
  final String texto;
  final TextStyle? estilo;

  /// Quando `false`, mostra o texto sem o grifo (ex.: abas não
  /// selecionadas da barra), sem mudar o tamanho do componente.
  final bool ativo;

  /// Cor do grifo, quando não puder ser o Céu. Ex.: no login e no
  /// cadastro o fundo já é Céu, então o slogan é grifado com a cor dos
  /// cards (`colorScheme.surface`), como no canvas.
  final Color? cor;

  const MarcaTexto(this.texto, {super.key, this.estilo, this.ativo = true, this.cor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // A faixa ocupa os 42% de baixo da altura do texto.
        Positioned.fill(
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.42,
            child: ColoredBox(
              color: ativo
                  ? cor ?? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(texto, style: estilo),
        ),
      ],
    );
  }
}
