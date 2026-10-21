import 'package:flutter/material.dart';

import 'rotulo_secao.dart';

/// Componente compartilhado: cabeçalho das telas internas.
///
/// Mostra o botão de voltar (só quando existe uma tela anterior), um
/// rótulo de seção opcional e o título em Bricolage, com uma linha fina
/// embaixo. Usado nas telas abertas a partir de outra (Detalhes, Avaliar,
/// Palestrantes, Planta, Patrocinadores e os formulários do organizador).
///
/// Fica no topo do corpo da tela, no lugar da `AppBar`:
/// `Column(children: [CabecalhoTela(titulo: 'Avaliar', secao: 'Palestra'), ...])`.
class CabecalhoTela extends StatelessWidget {
  final String titulo;

  /// Texto pequeno acima do título (ex.: `ORGANIZADOR`). Opcional.
  final String? secao;

  const CabecalhoTela({super.key, required this.titulo, this.secao});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final podeVoltar = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: tema.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (podeVoltar)
              IconButton(
                tooltip: 'Voltar',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (secao != null) ...[
                    RotuloSecao(secao!),
                    const SizedBox(height: 2),
                  ],
                  Text(titulo, style: tema.textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
