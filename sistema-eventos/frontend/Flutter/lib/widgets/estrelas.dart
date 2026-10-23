import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Componente compartilhado: cinco estrelas de avaliação (F07, RF16).
///
/// Funciona de dois jeitos, conforme `aoEscolher`:
/// - **só mostrar** (`aoEscolher` nulo): exibe uma nota, que pode ser
///   decimal, como a média `4,6`. Meia estrela a partir de ,5;
/// - **escolher** (`aoEscolher` preenchido): cada estrela vira um botão
///   de 52px, como na prancha "Avaliar palestra" do canvas, e tocar
///   nela devolve a nota escolhida (1 a 5).
///
/// Usado nos cards da Programação, nos Detalhes e na tela Avaliar.
class Estrelas extends StatelessWidget {
  final double nota;
  final double tamanho;
  final ValueChanged<int>? aoEscolher;

  const Estrelas({super.key, required this.nota, this.tamanho = 16, this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corMarcada =
        tema.brightness == Brightness.dark ? AppColors.estrelaEscura : AppColors.estrela;
    final corVazia = tema.colorScheme.onSurfaceVariant;

    // Para cada posição (1 a 5), decide se a estrela fica cheia, pela
    // metade ou vazia.
    Icon icone(int posicao) {
      final IconData desenho;
      if (nota >= posicao) {
        desenho = Icons.star_rounded;
      } else if (nota >= posicao - 0.5) {
        desenho = Icons.star_half_rounded;
      } else {
        desenho = Icons.star_outline_rounded;
      }
      return Icon(
        desenho,
        size: tamanho,
        color: nota >= posicao - 0.5 ? corMarcada : corVazia,
      );
    }

    if (aoEscolher == null) {
      // `Semantics` diz ao leitor de tela a nota inteira, em vez de ler
      // cinco ícones soltos.
      return Semantics(
        label: '${nota.toStringAsFixed(1).replaceAll('.', ',')} de 5 estrelas',
        child: ExcludeSemantics(
          child: Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 1; i <= 5; i++) icone(i)]),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
            child: IconButton(
              tooltip: i == 1 ? '1 estrela' : '$i estrelas',
              onPressed: () => aoEscolher!(i),
              icon: icone(i),
              style: IconButton.styleFrom(
                fixedSize: const Size(52, 52),
                backgroundColor: tema.colorScheme.surface,
                side: BorderSide(color: tema.colorScheme.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }
}
