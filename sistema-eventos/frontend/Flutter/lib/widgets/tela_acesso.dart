import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Componentes compartilhados das telas de acesso: login e cadastro (F01).
///
/// As duas telas têm o mesmo visual no canvas ("Login" e "Cadastro
/// (RF01)"): fundo Céu com a curva do rio, um cartão de vidro fosco no
/// meio e, dentro dele, a logo e os campos. Este arquivo reúne essas
/// partes para as duas telas não repetirem o mesmo código:
///
/// - `FundoAcesso`: o fundo, o rio e o cartão de vidro;
/// - `LogoFluxo`: a logo (círculo com o rio) e o nome "fluxo";
/// - `CampoAcesso`: um campo de texto com o rótulo em cima.
///
/// As cores vêm todas do tema (`theme/app_theme.dart`): no modo escuro o
/// fundo, o rio e o cartão mudam junto com o resto do app.

/// Fundo das telas de acesso, com o conteúdo dentro do cartão de vidro.
///
/// O "vidro fosco" é feito com um `BackdropFilter`: ele desfoca tudo o que
/// está ATRÁS do cartão (o rio e o fundo), e por cima vai uma camada
/// branca quase transparente. O `ClipRRect` limita o desfoque ao formato
/// do cartão; sem ele, a tela inteira ficaria desfocada.
class FundoAcesso extends StatelessWidget {
  final Widget child;

  const FundoAcesso({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final cantos = BorderRadius.circular(26);

    return Scaffold(
      backgroundColor: cores.tertiary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RioPainter(Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  // A sombra fica fora do `ClipRRect`, senão seria cortada.
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: cantos,
                      boxShadow: [
                        BoxShadow(
                          color: cores.primary.withValues(alpha: 0.14),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: cantos,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cores.surface.withValues(alpha: 0.2),
                            borderRadius: cantos,
                            border: Border.all(
                              color: cores.surface.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          // O grão é desenhado atrás do conteúdo. O
                          // `RepaintBoundary` evita redesenhar os pontos a
                          // cada letra digitada nos campos.
                          child: CustomPaint(
                            painter: _GraoPainter(cores.onSurface, cores.surface),
                            child: RepaintBoundary(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desenha a curva larga do rio atravessando a tela, de cima para baixo.
///
/// O caminho foi copiado do canvas, que usa uma tela de 390 × 844. Para
/// caber em qualquer tamanho de tela, cada ponto é multiplicado pela
/// proporção entre a tela real e a do canvas (`sx` e `sy`).
class _RioPainter extends CustomPainter {
  final Color cor;

  _RioPainter(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390;
    final sy = size.height / 844;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final caminho = Path()..moveTo(p(420, 10).dx, p(420, 10).dy);
    // Cada `cubicTo` é uma curva: dois pontos que "puxam" a linha e o
    // ponto onde ela termina (o `C` do SVG do canvas).
    void curva(double x1, double y1, double x2, double y2, double x, double y) {
      final a = p(x1, y1), b = p(x2, y2), c = p(x, y);
      caminho.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);
    }

    curva(330, 20, 350, 90, 260, 130);
    curva(140, 185, 60, 230, 150, 330);
    curva(240, 430, 380, 430, 330, 570);
    curva(290, 690, 90, 720, -40, 830);

    canvas.drawPath(
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 110 * sx
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RioPainter antigo) => antigo.cor != cor;
}

/// Desenha o "grão" do vidro: milhares de pontinhos quase transparentes,
/// claros e escuros, que dão textura ao cartão (no canvas, um filtro de
/// ruído).
///
/// Os pontos são sorteados com `Random(7)`: com o mesmo número inicial
/// (a "semente"), o sorteio dá sempre o mesmo resultado, então os pontos
/// não "pulam" de lugar quando o cartão é redesenhado.
///
/// Desempenho: são milhares de pontos, e o cartão é redesenhado a cada
/// quadro enquanto o teclado abre. Por isso o sorteio é feito uma vez só
/// e guardado nas listas `static` (que pertencem à classe, e não a cada
/// `_GraoPainter`, já que um novo é criado a cada `build`). Só se sorteia
/// de novo quando o tamanho do cartão muda.
class _GraoPainter extends CustomPainter {
  final Color escuro;
  final Color claro;

  _GraoPainter(this.escuro, this.claro);

  static Size? _tamanhoSorteado;
  static List<Offset> _pontosEscuros = [];
  static List<Offset> _pontosClaros = [];

  /// Sorteia os pontos para o tamanho `size`, se ainda não foram sorteados.
  static void _sortearPontos(Size size) {
    if (size == _tamanhoSorteado) return;
    final sorteio = Random(7);
    final quantidade = (size.width * size.height / 14).round();
    _pontosEscuros = [];
    _pontosClaros = [];
    for (var i = 0; i < quantidade; i++) {
      final ponto = Offset(
        sorteio.nextDouble() * size.width,
        sorteio.nextDouble() * size.height,
      );
      (i.isEven ? _pontosEscuros : _pontosClaros).add(ponto);
    }
    _tamanhoSorteado = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _sortearPontos(size);
    final pontosEscuros = _pontosEscuros;
    final pontosClaros = _pontosClaros;

    final pincel = Paint()..strokeWidth = 1;
    canvas.drawPoints(
      PointMode.points,
      pontosEscuros,
      pincel..color = escuro.withValues(alpha: 0.05),
    );
    canvas.drawPoints(
      PointMode.points,
      pontosClaros,
      pincel..color = claro.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(_GraoPainter antigo) =>
      antigo.escuro != escuro || antigo.claro != claro;
}

/// Logo do Fluxo: um círculo na cor principal cortado pelo rio, ao lado
/// do nome "fluxo" em Bricolage Grotesque.
class LogoFluxo extends StatelessWidget {
  /// Tamanho do círculo; o nome acompanha a proporção.
  final double tamanho;

  const LogoFluxo({super.key, this.tamanho = 36});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(tamanho),
          painter: _LogoPainter(
            circulo: cores.primary,
            rio: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        SizedBox(width: tamanho * 0.28),
        Text(
          'fluxo',
          style: TextStyle(
            fontFamily: AppFontes.titulo,
            fontSize: tamanho * 0.94,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: cores.primary,
          ),
        ),
      ],
    );
  }
}

/// Desenha o círculo da logo e o rio dentro dele. O desenho do canvas usa
/// uma área de 100 × 100; `escala` adapta para o tamanho pedido.
class _LogoPainter extends CustomPainter {
  final Color circulo;
  final Color rio;

  _LogoPainter({required this.circulo, required this.rio});

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / 100;
    canvas.scale(escala);

    final formaCirculo = Path()
      ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 48));
    canvas.drawPath(formaCirculo, Paint()..color = circulo);

    // O rio só aparece dentro do círculo (`clipPath`).
    canvas.clipPath(formaCirculo);
    final formaRio = Path()
      ..moveTo(64, 0)
      ..cubicTo(30, 10, 26, 34, 50, 46)
      ..cubicTo(74, 58, 70, 82, 36, 100)
      ..lineTo(62, 100)
      ..cubicTo(92, 84, 94, 54, 68, 40)
      ..cubicTo(50, 30, 52, 14, 86, 4)
      ..close();
    canvas.drawPath(formaRio, Paint()..color = rio);
  }

  @override
  bool shouldRepaint(_LogoPainter antigo) =>
      antigo.circulo != circulo || antigo.rio != rio;
}

/// Campo de texto das telas de acesso, com o rótulo em JetBrains Mono
/// maiúsculo em cima (ex.: `E-MAIL`), como no canvas.
///
/// `sufixo` permite colocar um botão dentro do campo (ex.: o "olho" que
/// mostra a senha no login).
class CampoAcesso extends StatelessWidget {
  final String rotulo;
  final String dica;
  final TextEditingController controller;
  final TextInputType? teclado;
  final bool esconderTexto;
  final Widget? sufixo;

  const CampoAcesso({
    super.key,
    required this.rotulo,
    required this.dica,
    required this.controller,
    this.teclado,
    this.esconderTexto = false,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sobre o fundo Céu, o rótulo usa a cor do texto principal: a cor
        // apagada dos rótulos comuns ficaria com pouco contraste.
        Text(
          rotulo,
          style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: teclado,
          obscureText: esconderTexto,
          decoration: InputDecoration(hintText: dica, suffixIcon: sufixo),
        ),
      ],
    );
  }
}
