import 'package:flutter/material.dart';

/// Tema visual centralizado do app Fluxo Eventos.
///
/// FINALIDADE DESTE ARQUIVO:
/// Concentrar em um só lugar as cores, as fontes e o estilo dos
/// componentes do app, seguindo a identidade visual aprovada no canvas
/// ("Telas do projeto · opção 1 refinada", F20). As telas nunca declaram
/// cores fixas: elas pedem a cor pela FUNÇÃO, por exemplo
/// `Theme.of(context).colorScheme.primary`. Assim, quando o modo escuro é
/// ligado (F11, RF20), todas as cores mudam juntas.
///
/// Este arquivo tem:
/// - a paleta de cores da marca (`AppColors`);
/// - os nomes das três fontes (`AppFontes`);
/// - os dois temas completos (`AppTheme.claro` e `AppTheme.escuro`),
///   aplicados uma única vez em `main.dart`.
///
/// QUAL COR FICA EM QUAL FUNÇÃO DO `ColorScheme`:
///
/// | Função              | Uso nas telas                     | Claro      | Escuro     |
/// |---------------------|-----------------------------------|------------|------------|
/// | primary             | botões, títulos, links            | Marinho    | Céu        |
/// | onPrimary           | texto sobre o primary             | Papel      | #071827    |
/// | secondary           | ícones e logo                     | Rio        | Rio        |
/// | tertiary            | marca-texto (grifo)               | Céu        | #1F5C86    |
/// | error               | esgotada, atenção, contador       | Brasa      | #F08A5D    |
/// | surface             | cards, campos, barra de navegação | Branco     | #0E2539    |
/// | onSurface           | texto principal                   | Tinta      | #F3EDE4    |
/// | onSurfaceVariant    | texto secundário e rótulos        | #6B5E50    | #B3C0CC    |
/// | outline             | borda de campos e selos           | #CDBBA3    | #2A4A66    |
/// | outlineVariant      | linhas finas de 1px               | #E4D8C8    | #1F3A54    |
/// | surfaceContainer    | blocos de apoio (atalhos, abas)   | #EFE2D0    | #12304A    |
/// | secondaryContainer  | superfícies quentes (avatar)      | Areia      | #12304A    |
///
/// O fundo das telas não está no `ColorScheme`: é o
/// `scaffoldBackgroundColor` (Papel no claro, #071827 no escuro).
///
/// A Brasa original (#B4471A) fica com pouco contraste sobre o fundo
/// escuro, por isso o modo escuro usa um tom mais claro dela.
class AppColors {
  AppColors._();

  // ---- Paleta da marca (modo claro) ----

  /// Fundo das telas.
  static const papel = Color(0xFFF6EEE3);

  /// Cards e campos de texto.
  static const branco = Color(0xFFFFFDF9);

  /// O rio da logo e superfícies quentes.
  static const areia = Color(0xFFE9D2B4);

  /// Marca-texto e destaques.
  static const ceu = Color(0xFF99D8FF);

  /// Ícones e logo.
  static const rio = Color(0xFF6AB9E9);

  /// Botões e títulos.
  static const marinho = Color(0xFF003465);

  /// Texto principal.
  static const tinta = Color(0xFF0B2440);

  /// Palestra esgotada e avisos de atenção.
  static const brasa = Color(0xFFB4471A);

  // ---- Modo escuro ----

  /// Fundo das telas no modo escuro.
  static const fundoEscuro = Color(0xFF071827);

  /// Cards e campos no modo escuro.
  static const superficieEscura = Color(0xFF0E2539);

  /// Texto principal no modo escuro.
  static const textoEscuro = Color(0xFFF3EDE4);
}

/// Nomes das fontes declaradas no `pubspec.yaml` (pasta `assets/fonts/`).
///
/// - `titulo`: Bricolage Grotesque, peso 600, só nos títulos;
/// - `texto`: Figtree, nos textos e botões (fonte padrão do app);
/// - `mono`: JetBrains Mono, em horários, salas, datas e rótulos.
class AppFontes {
  AppFontes._();

  static const titulo = 'Bricolage Grotesque';
  static const texto = 'Figtree';
  static const mono = 'JetBrains Mono';
}

/// Monta os `ThemeData` usados pelo `MaterialApp` inteiro.
class AppTheme {
  AppTheme._();

  // `static final`: cada tema é montado uma única vez, na primeira vez que
  // é usado, e reaproveitado em toda troca de tema.
  static final ThemeData claro = _montarTema(
        brilho: Brightness.light,
        fundo: AppColors.papel,
        corTitulo: AppColors.marinho,
        cores: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.marinho,
          onPrimary: AppColors.papel,
          secondary: AppColors.rio,
          onSecondary: AppColors.tinta,
          tertiary: AppColors.ceu,
          onTertiary: AppColors.tinta,
          error: AppColors.brasa,
          onError: AppColors.branco,
          surface: AppColors.branco,
          onSurface: AppColors.tinta,
          onSurfaceVariant: Color(0xFF6B5E50),
          outline: Color(0xFFCDBBA3),
          outlineVariant: Color(0xFFE4D8C8),
          surfaceContainer: Color(0xFFEFE2D0),
          secondaryContainer: AppColors.areia,
          onSecondaryContainer: AppColors.marinho,
        ),
      );

  static final ThemeData escuro = _montarTema(
        brilho: Brightness.dark,
        fundo: AppColors.fundoEscuro,
        corTitulo: AppColors.textoEscuro,
        cores: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.ceu,
          onPrimary: AppColors.fundoEscuro,
          secondary: AppColors.rio,
          onSecondary: AppColors.fundoEscuro,
          tertiary: Color(0xFF1F5C86),
          onTertiary: AppColors.textoEscuro,
          error: Color(0xFFF08A5D),
          onError: AppColors.fundoEscuro,
          surface: AppColors.superficieEscura,
          onSurface: AppColors.textoEscuro,
          onSurfaceVariant: Color(0xFFB3C0CC),
          outline: Color(0xFF2A4A66),
          outlineVariant: Color(0xFF1F3A54),
          surfaceContainer: Color(0xFF12304A),
          secondaryContainer: Color(0xFF12304A),
          onSecondaryContainer: AppColors.textoEscuro,
        ),
      );

  /// Monta um tema a partir de um jogo de cores. Os dois modos (claro e
  /// escuro) usam esta mesma função, então os tamanhos, cantos e fontes
  /// são sempre iguais: só as cores mudam.
  static ThemeData _montarTema({
    required Brightness brilho,
    required ColorScheme cores,
    required Color fundo,
    required Color corTitulo,
  }) {
    final cantos = BorderRadius.circular(10);

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: cores,
      scaffoldBackgroundColor: fundo,
      fontFamily: AppFontes.texto,
      textTheme: _textos(cores, corTitulo),

      // Cabeçalho sem sombra, na cor do fundo, com o título em Bricolage.
      appBarTheme: AppBarTheme(
        backgroundColor: fundo,
        foregroundColor: cores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFontes.titulo,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: corTitulo,
        ),
      ),

      // Cards planos: sem sombra, só uma linha de 1px e cantos de 12px.
      cardTheme: CardThemeData(
        color: cores.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),

      // Campos de texto com fundo branco (ou superfície escura) e borda de
      // 1px; ao receber o foco, a borda fica na cor principal.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide(color: cores.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide(color: cores.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: cantos,
          borderSide: BorderSide(color: cores.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: cores.onSurfaceVariant),
        hintStyle: TextStyle(color: cores.onSurfaceVariant),
      ),

      // Botão principal: preenchido, cor principal, 50px de altura
      // (ex.: "Entrar", "Garantir vaga").
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cores.primary,
          foregroundColor: cores.onPrimary,
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(borderRadius: cantos),
          textStyle: const TextStyle(
            fontFamily: AppFontes.texto,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botão secundário: só o contorno de 1px (ex.: "Cancelar").
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cores.onSurface,
          side: BorderSide(color: cores.outline),
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(borderRadius: cantos),
          textStyle: const TextStyle(
            fontFamily: AppFontes.texto,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cores.primary,
          textStyle: const TextStyle(
            fontFamily: AppFontes.texto,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Filtros (ex.: temas na Programação): cantos de 8px e borda de 1px.
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: cores.onSurface,
        side: BorderSide(color: cores.outline),
        labelStyle: TextStyle(
          fontFamily: AppFontes.texto,
          fontSize: 13,
          color: cores.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Interruptor (ex.: "Modo escuro" no Perfil): trilho na cor
      // principal quando ligado, bolinha sempre clara.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(cores.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? cores.primary
              : cores.outline,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      dividerTheme: DividerThemeData(
        color: cores.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: cores.primary),
    );
  }

  /// Estilos de texto do app. Cada nome do `TextTheme` tem um uso fixo:
  ///
  /// - `headlineMedium`, `headlineSmall`, `titleLarge`: títulos, em
  ///   Bricolage Grotesque 600 (30, 26 e 20px);
  /// - `titleMedium`, `titleSmall`: título de card ou de item de lista,
  ///   em Figtree 600 (16 e 15px);
  /// - `bodyLarge`, `bodyMedium`, `bodySmall`: textos corridos, em Figtree
  ///   (o `bodySmall` é o texto secundário, mais apagado);
  /// - `labelLarge`: botões, em Figtree 600;
  /// - `labelMedium`: horários, salas e datas, em JetBrains Mono
  ///   (ex.: `QUA 10 · 09:00—10:30`);
  /// - `labelSmall`: rótulos de seção, em JetBrains Mono maiúsculo
  ///   (ex.: `PRÓXIMA NA AGENDA`; ver `widgets/rotulo_secao.dart`).
  static TextTheme _textos(ColorScheme cores, Color corTitulo) {
    TextStyle titulo(double tamanho) => TextStyle(
          fontFamily: AppFontes.titulo,
          fontSize: tamanho,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: corTitulo,
        );

    return TextTheme(
      headlineMedium: titulo(30),
      headlineSmall: titulo(26),
      titleLarge: titulo(20),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: cores.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: cores.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: cores.onSurface),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: cores.onSurface),
      bodySmall: TextStyle(fontSize: 13, color: cores.onSurfaceVariant),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(
        fontFamily: AppFontes.mono,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: cores.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFontes.mono,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: cores.onSurfaceVariant,
      ),
    );
  }
}
