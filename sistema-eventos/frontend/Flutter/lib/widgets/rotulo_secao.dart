import 'package:flutter/material.dart';

/// Componente compartilhado: rótulo de seção.
///
/// Texto pequeno em JetBrains Mono, maiúsculo e espaçado, que abre um
/// bloco da tela (ex.: `PRÓXIMA NA AGENDA`, `MANHÃ`, `PALESTRANTE`). O
/// estilo vem do `labelSmall` do tema (`theme/app_theme.dart`).
class RotuloSecao extends StatelessWidget {
  final String texto;

  const RotuloSecao(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}
