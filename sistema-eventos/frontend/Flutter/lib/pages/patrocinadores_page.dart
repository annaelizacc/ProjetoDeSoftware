import 'package:flutter/material.dart';

import '../models/patrocinador.dart';
import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Patrocinadores" (F10, RF19).
///
/// Lista as empresas que patrocinam o evento
/// (`GET /api/patrocinadores?id_evento=<id>`, `ApiService.patrocinadores`)
/// numa grade de duas colunas, como na prancha "Patrocinadores (RF19)" do
/// canvas. Abre pelo botão "Patrocinadores" da tela de Programação, que já
/// sabe qual é o evento.
///
/// Por enquanto:
/// - o logo enviado pelo organizador (F14) aparece no quadro do topo do
///   card. Sem logo, o quadro mostra as iniciais da empresa;
/// - o site é um texto que dá para selecionar e copiar. Abrir o navegador
///   exigiria o pacote `url_launcher`, que fica para depois da P17
///   (versão do Flutter da equipe).
class PatrocinadoresPage extends StatefulWidget {
  final int eventoId;
  final String nomeEvento;

  const PatrocinadoresPage({super.key, required this.eventoId, required this.nomeEvento});

  @override
  State<PatrocinadoresPage> createState() => _PatrocinadoresPageState();
}

class _PatrocinadoresPageState extends State<PatrocinadoresPage> {
  /// A busca começa uma vez só, no `initState`. Se ficasse dentro do
  /// `build`, a API seria chamada de novo a cada redesenho da tela (ex.:
  /// ao trocar o modo escuro).
  late final Future<List<dynamic>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = ApiService.patrocinadores(widget.eventoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(titulo: 'Patrocinadores'),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                final lista = [
                  for (final item in snapshot.data ?? []) Patrocinador.fromJson(Map<String, dynamic>.from(item)),
                ];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    RotuloSecao('Quem apoia: ${widget.nomeEvento}'),
                    const SizedBox(height: 14),
                    if (lista.isEmpty)
                      Text('Este evento ainda não tem patrocinadores.', style: Theme.of(context).textTheme.bodySmall)
                    else
                      // Duas colunas com 10px entre elas. O `Wrap` deixa
                      // cada card com a própria altura (as descrições têm
                      // tamanhos diferentes), o que uma grade de altura
                      // fixa cortaria.
                      LayoutBuilder(
                        builder: (context, limites) {
                          final largura = (limites.maxWidth - 10) / 2;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (var i = 0; i < lista.length; i++)
                                SizedBox(width: largura, child: _CardPatrocinador(patrocinador: lista[i], posicao: i)),
                            ],
                          );
                        },
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

/// Card de um patrocinador: logo (ou as iniciais), nome, descrição e
/// site.
class _CardPatrocinador extends StatelessWidget {
  final Patrocinador patrocinador;

  /// Posição na lista, usada para alternar a cor do quadro das iniciais
  /// (céu e areia), como no canvas.
  final int posicao;

  const _CardPatrocinador({required this.patrocinador, required this.posicao});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final p = patrocinador;
    final site = p.siteCurto;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cores.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Logo de ${p.nome}',
            child: ExcludeSemantics(
              child: Container(
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: posicao.isEven ? cores.tertiary : cores.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: p.logo == null
                    ? Text(
                        p.iniciais,
                        style: tema.textTheme.titleLarge?.copyWith(fontSize: 22, color: cores.onSecondaryContainer),
                      )
                    : Image.network(
                        ApiService.urlImagem(p.logo!),
                        fit: BoxFit.contain,
                        // Se a imagem não carregar, volta para as iniciais.
                        errorBuilder: (_, __, ___) => Text(p.iniciais, style: tema.textTheme.titleLarge),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(p.nome, style: tema.textTheme.titleSmall),
          if (p.descricao != null && p.descricao!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(p.descricao!, style: tema.textTheme.bodySmall?.copyWith(height: 1.4)),
          ],
          if (site != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              site,
              style: tema.textTheme.labelSmall?.copyWith(letterSpacing: 0, color: cores.onSurface),
            ),
          ],
        ],
      ),
    );
  }
}
