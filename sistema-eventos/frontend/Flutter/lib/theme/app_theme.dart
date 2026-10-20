import 'package:flutter/material.dart';

/// Tema visual centralizado do app Fluxo Eventos.
///
/// FINALIDADE DESTE ARQUIVO:
/// Antes desta refatoração, cada tela definia suas próprias cores em
/// hexadecimal espalhadas pelo código (`Color(0xff063b6d)` repetido em
/// vários arquivos, por exemplo). Isso dificulta manter uma identidade
/// visual consistente: mudar o azul principal do app exigiria editar
/// dezenas de arquivos.
///
/// Esta classe concentra:
/// - a paleta de cores (`AppColors`);
/// - as cores "pastel" usadas como identificação visual das palestras por
///   tema (`AppColors.corDaCategoria`), inspiradas nos cartões coloridos
///   da tela de Programação/Agenda do design de referência;
/// - o `ThemeData` completo (`AppTheme.claro`), aplicado uma única vez em
///   `main.dart`.
///
/// As telas devem sempre ler cores e estilos a partir daqui (ou do
/// `Theme.of(context)`), em vez de declarar novos hexadecimais soltos.
class AppColors {
  AppColors._();

  /// Azul principal da marca — usado em títulos, ícones de destaque e no
  /// botão principal de ação (ex.: "Entrar", "Inscrever-se").
  static const primary = Color(0xFF0B4B83);

  /// Tom mais escuro do azul principal, usado em textos de destaque sobre
  /// fundo claro (títulos grandes) e no botão de login.
  static const primaryDark = Color(0xFF063B6D);

  /// Azul secundário/claro, usado em elementos de apoio (banner da Home,
  /// indicador de navegação selecionado).
  static const secondary = Color(0xFF55B6F5);

  /// Fundo padrão das telas: um branco levemente azulado, para não cansar
  /// a vista em telas grandes de lista, mas ainda transmitir a sensação de
  /// "app claro" pedida no novo design.
  static const fundo = Color(0xFFF5F9FC);

  /// Branco puro, usado em cards e campos de texto sobre o fundo `fundo`.
  static const superficie = Colors.white;

  /// Cinza usado em textos secundários (subtítulos, legendas).
  static const textoSecundario = Color(0xFF6B7A8D);

  /// Cor de borda sutil usada em campos de texto e divisores.
  static const borda = Color(0xFFE1E8F0);

  /// Vermelho suave usado para estados de erro/lotação (ex.: "sem vagas").
  static const erro = Color(0xFFE0554F);

  /// Paleta pastel usada para colorir cards de palestra por categoria,
  /// reproduzindo o efeito "cada palestra tem uma cor" visto nas telas de
  /// Agenda e Programação do design de referência. A cor é escolhida de
  /// forma determinística a partir do texto do tema/título, então a mesma
  /// palestra sempre aparece com a mesma cor.
  static const List<Color> categorias = [
    Color(0xFFDFF4E6), // verde suave
    Color(0xFFFDEBD9), // laranja suave
    Color(0xFFE1F1FC), // azul suave
    Color(0xFFEDE3FB), // roxo suave
  ];

  /// Cor de destaque (texto/ícone) que combina com cada cor pastel acima,
  /// na mesma ordem — usada para o texto dentro do card colorido.
  static const List<Color> categoriasDestaque = [
    Color(0xFF2F8F5B),
    Color(0xFFD98A32),
    Color(0xFF1E7FC2),
    Color(0xFF7E57C2),
  ];

  /// Escolhe uma cor pastel de forma estável a partir de um texto
  /// (normalmente o tema ou o título da palestra), para que cada palestra
  /// tenha sempre a mesma cor de identificação visual entre as telas.
  static int _indiceDaCategoria(String? chave) {
    if (chave == null || chave.trim().isEmpty) return 0;
    return chave.codeUnits.fold<int>(0, (soma, c) => soma + c) %
        categorias.length;
  }

  static Color corDaCategoria(String? chave) =>
      categorias[_indiceDaCategoria(chave)];

  static Color corDeDestaqueDaCategoria(String? chave) =>
      categoriasDestaque[_indiceDaCategoria(chave)];
}

/// Monta o `ThemeData` usado pelo `MaterialApp` inteiro.
class AppTheme {
  AppTheme._();

  static ThemeData get claro {
    final esquemaDeCores = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.superficie,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: esquemaDeCores,
      scaffoldBackgroundColor: AppColors.fundo,
      fontFamily: 'Arial',

      // AppBar clara, sem sombra pesada, com título alinhado ao padrão do
      // design (texto escuro sobre fundo claro, em vez de branco sobre azul).
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Cards brancos com cantos arredondados e sombra bem sutil — usados
      // em quase todas as listas do app (eventos, palestras, favoritos...).
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 1.5,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // Campos de texto claros, com preenchimento branco e borda suave —
      // usados no login e nos campos de busca.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.textoSecundario),
      ),

      // Botão principal: pílula azul-marinho preenchida, usado em "Entrar",
      // "Inscrever-se", etc.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Botão secundário: contorno azul, usado para ações como "Favoritar"
      // e "Ativar lembrete".
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Barra de navegação inferior branca, com indicador azul-claro atrás
      // do ícone selecionado — reproduz o rodapé do design de referência.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.25),
        elevation: 4,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selecionado = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
            color: selecionado ? AppColors.primaryDark : AppColors.textoSecundario,
          );
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fundo,
        side: const BorderSide(color: AppColors.borda),
        labelStyle: const TextStyle(color: AppColors.primaryDark, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
