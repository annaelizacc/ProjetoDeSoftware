import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Os três jeitos de um `Selo` aparecer.
///
/// - `destaque`: preenchido na cor principal (ex.: `INSCRITA`);
/// - `alerta`: contorno e texto na cor de atenção (ex.: `ESGOTADA`);
/// - `neutro`: contorno discreto (ex.: `48 VAGAS`);
/// - `organizacao`: preenchido na cor Areia, para os comunicados do
///   organizador na aba Avisos (ex.: `ORGANIZAÇÃO`, F09).
enum TipoSelo { destaque, alerta, neutro, organizacao }

/// Componente compartilhado: selo (etiqueta) de situação.
///
/// Etiqueta pequena em JetBrains Mono com a situação de uma palestra.
/// Usado na Programação, nos Detalhes, na Agenda, nos Favoritos e nos
/// Avisos.
class Selo extends StatelessWidget {
  final String texto;
  final TipoSelo tipo;

  const Selo(this.texto, {super.key, this.tipo = TipoSelo.neutro});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    // Escolhe fundo, texto e borda conforme o tipo.
    final (fundo, corTexto, borda) = switch (tipo) {
      TipoSelo.destaque => (cores.primary, cores.onPrimary, cores.primary),
      TipoSelo.alerta => (Colors.transparent, cores.error, cores.error),
      TipoSelo.neutro =>
        (Colors.transparent, cores.onSurfaceVariant, cores.outline),
      TipoSelo.organizacao => (
          cores.secondaryContainer,
          cores.onSecondaryContainer,
          cores.secondaryContainer
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borda),
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFontes.mono,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: corTexto,
        ),
      ),
    );
  }
}
