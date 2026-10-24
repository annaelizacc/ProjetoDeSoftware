import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/estrelas.dart';
import '../widgets/rotulo_secao.dart';
import 'palestra_details_page.dart';

/// Tela "Avaliações do evento" (F16).
///
/// Aberta pelo botão "Ver avaliações" do card de um evento encerrado no
/// Início (no lugar de "Ver programação"). Mostra as palestras do
/// evento com a média de estrelas e o total de avaliações, da maior média
/// para a menor; tocar numa palestra abre os detalhes, onde ficam os
/// comentários.
///
/// Usa a mesma rota da Programação (`GET /api/palestras?id_evento=<id>`,
/// `ApiService.programacao`), que já devolve `media_estrelas` e
/// `total_avaliacoes` (F06/F07). Por isso não precisou de rota nova no
/// backend.
class AvaliacoesEventoPage extends StatefulWidget {
  final int eventoId;
  final String nomeEvento;
  final int usuarioId;

  const AvaliacoesEventoPage({
    super.key,
    required this.eventoId,
    required this.nomeEvento,
    required this.usuarioId,
  });

  @override
  State<AvaliacoesEventoPage> createState() => _AvaliacoesEventoPageState();
}

class _AvaliacoesEventoPageState extends State<AvaliacoesEventoPage> {
  /// A busca começa uma vez só, no `initState` (ver `PatrocinadoresPage`).
  late final Future<List<Palestra>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca as palestras e ordena pela média: as sem avaliação vão para o
  /// fim da lista.
  Future<List<Palestra>> carregar() async {
    final lista = [
      for (final json in await ApiService.programacao(widget.eventoId))
        Palestra.fromJson(Map<String, dynamic>.from(json)),
    ];
    lista.sort((a, b) => (b.mediaEstrelas ?? -1).compareTo(a.mediaEstrelas ?? -1));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(titulo: 'Avaliações'),
          Expanded(
            child: FutureBuilder<List<Palestra>>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                final palestras = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    RotuloSecao(widget.nomeEvento),
                    const SizedBox(height: 8),
                    if (palestras.isEmpty)
                      Text('Este evento não tem palestras.', style: textos.bodySmall)
                    else
                      for (final p in palestras)
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: p.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: cores.outlineVariant)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.titulo, style: textos.titleSmall),
                                      const SizedBox(height: 4),
                                      p.totalAvaliacoes == 0
                                          ? Text('Ainda sem avaliações', style: textos.bodySmall)
                                          : Row(children: [
                                              Estrelas(nota: p.mediaEstrelas ?? 0, tamanho: 14),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${p.mediaTexto} · ${p.totalAvaliacoes} '
                                                '${p.totalAvaliacoes == 1 ? 'avaliação' : 'avaliações'}',
                                                style: textos.labelMedium,
                                              ),
                                            ]),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: cores.outline),
                              ],
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
