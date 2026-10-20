import 'package:flutter/material.dart';

import 'pages/app_shell.dart';
import 'pages/login_page.dart';
import 'theme/app_theme.dart';

/// Ponto de entrada do aplicativo Flutter.
void main() {
  runApp(const FluxoApp());
}

/// Widget raiz do app.
///
/// Aplica o tema claro centralizado (`AppTheme.claro`, definido em
/// `theme/app_theme.dart`) para toda a árvore de widgets, e define a
/// primeira tela como a `SplashPage`.
class FluxoApp extends StatelessWidget {
  const FluxoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluxo Eventos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const SplashPage(),
    );
  }
}

/// Tela de abertura (splash), exibida por 2 segundos ao abrir o app.
///
/// Depois desse tempo, navega automaticamente para a `LoginPage`. Não
/// consome nenhum endpoint da API — é puramente visual, servindo para dar
/// tempo do app carregar e reforçar a identidade da marca "Fluxo".
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
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
    return const Scaffold(
      backgroundColor: Color(0xffa3d3f0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 92, color: Colors.white),
            SizedBox(height: 14),
            Text(
              'FLUXO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
