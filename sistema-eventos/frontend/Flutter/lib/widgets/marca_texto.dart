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

  /// Quanto a faixa sobe, em porcentagem da altura do texto (0 = colada
  /// embaixo). A caixa do texto inclui o espaço abaixo da linha das letras
  /// (para o "p" e o "g"); em textos sem essas letras, como o slogan, a
  /// faixa colada embaixo fica abaixo das letras, e subir deixa o grifo
  /// atrás delas, mais legível.
  final int subir;

  const MarcaTexto(this.texto, {super.key, this.estilo, this.ativo = true, this.cor, this.subir = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // A altura do texto é dividida em partes com `flex` (como
        // porcentagens): um espaço vazio em cima, a faixa com 42 partes e,
        // embaixo, as `subir` partes que levantam a faixa. O `stretch`
        // estica a faixa na largura do texto (sem ele, um `ColoredBox`
        // sem conteúdo ficaria com largura zero).
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 58 - subir),
              Expanded(
                flex: 42,
                child: ColoredBox(
                  color: ativo
                      ? cor ?? Theme.of(context).colorScheme.tertiary
                      : Colors.transparent,
                ),
              ),
              if (subir > 0) Spacer(flex: subir),
            ],
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
