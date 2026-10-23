import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Localização" (F03, RF10).
///
/// Segue a prancha "Planta do lugar (RF10)" do canvas, com o título
/// "Localização" (decisão da Manuela, 23/10/2026) (proposta "eventos,
/// lugares e salas", 23/10/2026): um evento acontece em um **lugar**
/// (`evento.local`, ex.: Centro de Convenções UFMG), que tem várias
/// **salas** (os locais cadastrados pelo organizador). A tela mostra:
/// - o evento, o nome do lugar e quantas salas ele tem;
/// - a planta baixa (`GET /api/eventos/<id>/planta`, `ApiService.planta`);
/// - as salas com o caminho até elas (`GET /api/locais?id_evento=<id>`,
///   `ApiService.locais`) e quantas palestras cada uma recebe, contadas
///   na programação do evento pelo `id_localizacao`.
///
/// Abre pelo atalho "Localização" do Início e pelo "Ver planta" dos
/// Detalhes. O nome do lugar vem da lista de eventos, e não de um
/// parâmetro, para a tela ficar igual pelos dois caminhos.
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

typedef _DadosPlanta = ({
  Map<String, dynamic>? planta,
  List<dynamic> locais,
  String? lugar,
  Map<int, int> palestrasPorSala,
});

class _PlantaPageState extends State<PlantaPage> {
  /// A busca começa uma vez só, no `initState` (ver `PatrocinadoresPage`).
  late final Future<_DadosPlanta> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  /// Busca a planta, as salas, a programação e os eventos ao mesmo tempo
  /// (`Future.wait`). A programação e os eventos são opcionais: se falharem,
  /// a tela abre sem a contagem de palestras e sem o nome do lugar.
  Future<_DadosPlanta> carregar() async {
    final respostas = await Future.wait<dynamic>([
      ApiService.planta(widget.eventoId),
      ApiService.locais(widget.eventoId),
      ApiService.programacao(widget.eventoId).catchError((_) => <dynamic>[]),
      ApiService.eventos().catchError((_) => <dynamic>[]),
    ]);

    // Quantas palestras cada sala recebe: chave = `id_localizacao`.
    final palestrasPorSala = <int, int>{};
    for (final palestra in respostas[2] as List<dynamic>) {
      final sala = palestra['id_localizacao'];
      if (sala is int) palestrasPorSala[sala] = (palestrasPorSala[sala] ?? 0) + 1;
    }

    String? lugar;
    for (final evento in respostas[3] as List<dynamic>) {
      if (evento['id_evento'] == widget.eventoId) lugar = evento['local'];
    }

    return (
      planta: respostas[0] as Map<String, dynamic>?,
      locais: respostas[1] as List<dynamic>,
      lugar: lugar,
      palestrasPorSala: palestrasPorSala,
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
          const CabecalhoTela(titulo: 'Localização'),
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
                final lugar = snapshot.data!.lugar;
                final palestrasPorSala = snapshot.data!.palestrasPorSala;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    RotuloSecao('Evento · ${widget.nomeEvento}'),
                    if (lugar != null && lugar.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 20, color: cores.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(lugar, style: textos.headlineSmall?.copyWith(fontSize: 22))),
                      ]),
                    ],
                    if (locais.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Todas as palestras deste evento acontecem aqui, '
                        '${locais.length == 1 ? 'em 1 sala' : 'em ${locais.length} salas'}.',
                        style: textos.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
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
                    const RotuloSecao('Salas e como chegar'),
                    const SizedBox(height: 6),
                    if (locais.isEmpty)
                      Text('Este evento ainda não tem salas cadastradas.', style: textos.bodySmall)
                    else
                      for (final local in locais)
                        _Sala(local: local, palestras: palestrasPorSala[local['id_localizacao']] ?? 0),
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

/// Uma sala da lista: nome, o caminho até ela e quantas palestras ela
/// recebe (`3 PALESTRAS NESTA SALA`, em JetBrains Mono). Sala sem
/// palestras fica sem a linha da contagem.
class _Sala extends StatelessWidget {
  final dynamic local;
  final int palestras;

  const _Sala({required this.local, required this.palestras});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final caminho = (local['descricao'] ?? '').toString().trim();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cores.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local['nome_local'] ?? '', style: textos.titleSmall),
          if (caminho.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(caminho, style: textos.bodySmall?.copyWith(height: 1.4)),
          ],
          if (palestras > 0) ...[
            const SizedBox(height: 4),
            Text(
              palestras == 1 ? '1 PALESTRA NESTA SALA' : '$palestras PALESTRAS NESTA SALA',
              style: textos.labelSmall?.copyWith(color: cores.primary),
            ),
          ],
        ],
      ),
    );
  }
}
