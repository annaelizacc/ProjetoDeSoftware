import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Planta do local" (F03, RF10).
///
/// Mostra a planta baixa do evento (`GET /api/eventos/<id>/planta`,
/// `ApiService.planta`) e, abaixo, os locais do evento com o passo a
/// passo de como chegar (`GET /api/locais?id_evento=<id>`,
/// `ApiService.locais`), como na prancha "Planta do local (RF10)" do
/// canvas. Abre pelo atalho "Mapa do local" do Início.
///
/// A imagem é enviada pelo organizador (F14). Sem imagem, a tela avisa
/// que a planta ainda não foi enviada e mostra só os locais.
///
/// O zoom usa o `InteractiveViewer`, um widget do próprio Flutter que
/// deixa ampliar (pinça, ou roda do mouse no navegador) e arrastar o que
/// estiver dentro dele.
class PlantaPage extends StatefulWidget {
  final int eventoId;
  final String nomeEvento;

  const PlantaPage({super.key, required this.eventoId, required this.nomeEvento});

  @override
  State<PlantaPage> createState() => _PlantaPageState();
}

typedef _DadosPlanta = ({Map<String, dynamic>? planta, List<dynamic> locais});

class _PlantaPageState extends State<PlantaPage> {
  /// A busca começa uma vez só, no `initState` (ver `PatrocinadoresPage`).
  late final Future<_DadosPlanta> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca a planta e os locais ao mesmo tempo (`Future.wait`).
  Future<_DadosPlanta> carregar() async {
    final respostas = await Future.wait([
      ApiService.planta(widget.eventoId),
      ApiService.locais(widget.eventoId),
    ]);
    return (
      planta: respostas[0] as Map<String, dynamic>?,
      locais: respostas[1] as List<dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(titulo: 'Planta do local'),
          Expanded(
            child: FutureBuilder<_DadosPlanta>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                final planta = snapshot.data!.planta;
                final imagem = planta?['imagem_mapa'];
                final descricao = (planta?['descricao'] ?? '').toString().trim();
                final locais = snapshot.data!.locais;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    RotuloSecao(widget.nomeEvento),
                    const SizedBox(height: 10),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: cores.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cores.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imagem == null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'O organizador ainda não enviou a planta deste evento.',
                                  textAlign: TextAlign.center,
                                  style: textos.bodySmall,
                                ),
                              ),
                            )
                          : InteractiveViewer(
                              maxScale: 5,
                              child: Image.network(
                                ApiService.urlImagem(imagem),
                                fit: BoxFit.contain,
                                // Se a imagem não carregar (ex.: arquivo
                                // apagado do servidor), avisa no quadro.
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text('Não foi possível carregar a planta.', style: textos.bodySmall),
                                ),
                              ),
                            ),
                    ),
                    if (imagem != null) ...[
                      const SizedBox(height: 6),
                      Text('Use dois dedos (ou a roda do mouse) para ampliar.', style: textos.labelSmall),
                    ],
                    if (descricao.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(descricao, style: textos.bodyLarge),
                    ],
                    const SizedBox(height: 22),
                    const RotuloSecao('Locais e como chegar'),
                    const SizedBox(height: 6),
                    if (locais.isEmpty)
                      Text('Este evento ainda não tem locais cadastrados.', style: textos.bodySmall)
                    else
                      for (final local in locais)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: cores.outlineVariant)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(local['nome_local'] ?? '', style: textos.titleSmall),
                              if ((local['descricao'] ?? '').toString().trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(local['descricao'], style: textos.bodySmall?.copyWith(height: 1.4)),
                              ],
                            ],
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
