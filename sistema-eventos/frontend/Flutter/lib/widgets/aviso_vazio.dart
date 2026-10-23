import 'package:flutter/material.dart';

/// Componente compartilhado: aviso pequeno de lista vazia (ex.: "Nenhuma
/// palestra neste dia."), num card com linha fina e ícone, usado pela
/// Programação e pela Agenda.
class AvisoVazio extends StatelessWidget {
  final String texto;

  const AvisoVazio(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cores.outlineVariant),
      ),
      child: Row(children: [
        Icon(Icons.event_busy_outlined, size: 18, color: cores.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(texto, style: tema.textTheme.bodySmall)),
      ]),
    );
  }
}
