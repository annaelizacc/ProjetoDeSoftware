import 'package:flutter/material.dart';

import 'pages/splash_page.dart';
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
