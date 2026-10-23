import 'package:flutter/material.dart';

/// Componente compartilhado: círculo com as iniciais do nome.
///
/// Usado no Perfil e na lista de inscritos da área do organizador
/// ("Ana Silva" → "AS"). As cores vêm do tema (`secondaryContainer`).
class AvatarIniciais extends StatelessWidget {
  final String nome;
  final double raio;

  /// Estilo das letras. Sem ele, Figtree 14 em negrito (lista de
  /// inscritos); o Perfil passa o título em Bricolage.
  final TextStyle? estilo;

  const AvatarIniciais(this.nome, {super.key, this.raio = 20, this.estilo});

  /// Até duas iniciais do nome: a primeira letra do primeiro e do último.
  String get _iniciais {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (partes.isEmpty) return '?';
    final letras = [partes.first, if (partes.length > 1) partes.last]
        // `characters.first` pega a primeira letra "visível", mesmo quando
        // ela ocupa mais de um código no texto (ex.: emoji).
        .map((p) => p.characters.first.toUpperCase());
    return letras.join();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: raio,
      backgroundColor: cores.secondaryContainer,
      foregroundColor: cores.onSecondaryContainer,
      child: Text(
        _iniciais,
        style: (estilo ??
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))
            .copyWith(color: cores.onSecondaryContainer),
      ),
    );
  }
}
