import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'theme/app_theme.dart';
import 'theme/controle_tema.dart';

/// Ponto de entrada do aplicativo Flutter.
///
/// Antes de desenhar o app, lê no celular se o modo escuro estava ligado
/// (`ControleTema.carregar`). Isso evita que o app abra no claro e "pisque"
/// para o escuro logo depois.
Future<void> main() async {
  // Necessário antes de usar plugins (como o `shared_preferences`) ainda
  // dentro do `main`, antes do `runApp`: prepara a ligação entre o Flutter
  // e o sistema do celular.
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ControleTema.carregar();
  } catch (_) {
    // Se o celular não conseguir ler a preferência, o app abre no tema
    // claro em vez de travar: o tema é só visual, não impede o uso.
  }
  runApp(const FluxoApp());
}

/// Widget raiz do app.
///
/// Recebe os dois temas de `theme/app_theme.dart` (claro e escuro) e ouve o
/// `ControleTema.modo`: quando a pessoa troca o tema no Perfil, o
/// `ValueListenableBuilder` redesenha o `MaterialApp` com o tema novo.
class FluxoApp extends StatelessWidget {
  const FluxoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ControleTema.modo,
      builder: (context, modo, _) => MaterialApp(
        title: 'Fluxo Eventos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        darkTheme: AppTheme.escuro,
        themeMode: modo,
        home: const SplashPage(),
      ),
    );
  }
}

/// Tela de abertura (splash), exibida por 2 segundos ao abrir o app.
///
/// Depois desse tempo, navega automaticamente para a `LoginPage`. Não
/// consome nenhum endpoint da API — é puramente visual, servindo para dar
/// tempo do app carregar e reforçar a identidade da marca "Fluxo". As
/// cores vêm do tema; o visual completo da abertura (canvas, "Abertura")
/// é feito na F20 parte 2.
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
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cores.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 92, color: cores.onPrimary),
            const SizedBox(height: 14),
            Text(
              'fluxo',
              style: TextStyle(
                fontFamily: AppFontes.titulo,
                color: cores.onPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: cores.onPrimary),
          ],
        ),
      ),
    );
  }
}
