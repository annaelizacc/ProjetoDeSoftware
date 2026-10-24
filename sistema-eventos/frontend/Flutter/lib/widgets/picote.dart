import 'package:flutter/material.dart';

/// Componente compartilhado: o "picote" do canvas.
///
/// É a linha tracejada de 1px que lembra o picote de um ingresso. Aparece
/// acima da barra de ações dos Detalhes (na horizontal) e entre o horário
/// e o título do card "Próxima na agenda" do Início (na vertical).
///
/// O Flutter não tem borda tracejada pronta, então a linha é desenhada à
/// mão com um `CustomPainter`: traços de 4px separados por espaços de 3px.
/// A cor é a `outline` do tema, a mesma das bordas de botões.
class Picote extends StatelessWidget {
  /// `true`: linha em pé, com a altura que o pai der (ex.: uma `Row` com
  /// `CrossAxisAlignment.stretch`); `false`: deitada, na largura toda.
  final bool vertical;

  const Picote({super.key, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.outline;
    final linha = CustomPaint(painter: _PicotePainter(cor: cor, vertical: vertical));
    // Na vertical só a largura é fixa: pedir altura infinita quebraria
    // dentro de um `IntrinsicHeight`.
    return vertical ? SizedBox(width: 1, child: linha) : SizedBox(width: double.infinity, height: 1, child: linha);
  }
}

class _PicotePainter extends CustomPainter {
  final Color cor;
  final bool vertical;

  _PicotePainter({required this.cor, required this.vertical});

  static const _traco = 4.0;
  static const _espaco = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..strokeWidth = 1;
    final comprimento = vertical ? size.height : size.width;
    // Desenha um traço, pula o espaço e repete até o fim da linha.
    for (var inicio = 0.0; inicio < comprimento; inicio += _traco + _espaco) {
      final fim = (inicio + _traco).clamp(0.0, comprimento);
      canvas.drawLine(
        vertical ? Offset(0.5, inicio) : Offset(inicio, 0.5),
        vertical ? Offset(0.5, fim) : Offset(fim, 0.5),
        pincel,
      );
    }
  }

  @override
  bool shouldRepaint(_PicotePainter antigo) => antigo.cor != cor || antigo.vertical != vertical;
}
