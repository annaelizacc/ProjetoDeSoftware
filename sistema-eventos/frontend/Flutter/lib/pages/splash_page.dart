import 'package:flutter/material.dart';

import '../widgets/marca_texto.dart';
import '../widgets/tela_acesso.dart';
import 'login_page.dart';

/// Tela de abertura (splash), exibida por 5 segundos ao abrir o app.
///
/// Segue a prancha "Abertura" do canvas: fundo Céu com o rio (o mesmo das
/// telas de acesso, `FundoRio`), a logo com o nome embaixo, o slogan com
/// marca-texto e uma barra fina que enche durante os 5 segundos. Depois
/// desse tempo, navega para a `LoginPage`. Não consome nenhum endpoint da
/// API: é puramente visual.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const duracao = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    Future.delayed(duracao, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final slogan = tema.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500);

    return Scaffold(
      body: FundoRio(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoFluxo(tamanho: 96, vertical: true),
                  const SizedBox(height: 14),
                  // O fundo já é Céu, então o grifo usa a cor dos cards,
                  // como no login.
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: 'Seu evento, ',
                      style: slogan,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: MarcaTexto('sem desencontros', estilo: slogan, cor: cores.surface, subir: 14),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Barra de progresso fina perto do rodapé. O
            // `TweenAnimationBuilder` anima o valor de 0 a 1 durante os
            // 5 segundos da abertura, sem precisar de um controlador.
            Positioned(
              left: 0,
              right: 0,
              bottom: 64,
              child: Center(
                child: SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: duracao,
                      builder: (_, valor, __) => LinearProgressIndicator(
                        value: valor,
                        minHeight: 4,
                        color: cores.primary,
                        backgroundColor: cores.primary.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
