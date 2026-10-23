import 'package:flutter/material.dart';

import '../models/palestra.dart';

/// Componente compartilhado: aviso de choque de horário (F16, S01), como
/// a prancha "Aviso de choque de horário (F16)" do canvas.
///
/// Abre como uma janela que sobe de baixo da tela (`showModalBottomSheet`)
/// e mostra as duas palestras: a que a pessoa já tem inscrição e a nova.
/// Devolve `true` se a pessoa tocar em "Inscrever mesmo assim" e `false`
/// se tocar em "Cancelar" ou fechar a janela.
///
/// A inscrição não é bloqueada: a decisão é de quem usa o app (decisão de
/// 20/10/2026, com texto neutro, sem presumir o gênero).
Future<bool> mostrarAvisoDeChoque(
  BuildContext context, {
  required Palestra jaInscrita,
  required Palestra nova,
}) async {
  final confirmou = await showModalBottomSheet<bool>(
    context: context,
    // Deixa a janela passar da metade da tela; com o conteúdo rolável
    // (abaixo), ela cabe também em telas baixas.
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AvisoChoque(jaInscrita: jaInscrita, nova: nova),
  );
  // Fechar arrastando para baixo devolve `null`: conta como "Cancelar".
  return confirmou ?? false;
}

class _AvisoChoque extends StatelessWidget {
  final Palestra jaInscrita;
  final Palestra nova;

  const _AvisoChoque({required this.jaInscrita, required this.nova});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return SafeArea(
      // Rolável: em telas baixas, o texto e os botões não cabem de uma vez
      // (o Flutter mostraria a faixa amarela e preta de "overflow").
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cores.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.schedule, color: cores.error),
            ),
            const SizedBox(height: 14),
            Text('Choque de horário', style: textos.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Você já tem inscrição em uma palestra nesse horário. Deseja mesmo se inscrever nesta?',
              style: textos.bodyLarge,
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: cores.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _LinhaPalestra(rotulo: 'Já tem inscrição', palestra: jaInscrita, corRotulo: cores.onSurfaceVariant),
                  Divider(height: 1, color: cores.outlineVariant),
                  _LinhaPalestra(rotulo: 'Nova', palestra: nova, corRotulo: cores.error),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Inscrever mesmo assim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma das duas palestras do aviso: rótulo com o horário e o título.
class _LinhaPalestra extends StatelessWidget {
  final String rotulo;
  final Palestra palestra;
  final Color corRotulo;

  const _LinhaPalestra({required this.rotulo, required this.palestra, required this.corRotulo});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rotulo.toUpperCase()} · ${palestra.horario}',
                  style: textos.labelMedium?.copyWith(color: corRotulo),
                ),
                const SizedBox(height: 2),
                Text(palestra.titulo, style: textos.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
