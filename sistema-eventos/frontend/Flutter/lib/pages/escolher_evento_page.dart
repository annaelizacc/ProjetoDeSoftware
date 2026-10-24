import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/datas.dart';
import '../widgets/cabecalho_tela.dart';

/// Tela "Escolher evento" (F20), como a prancha do canvas (proposta
/// "eventos, lugares e salas", 23/10/2026).
///
/// Abre pelo cartão "Você está no evento" do Início. Mostra um card por
/// evento com as datas, o nome, o lugar e quantas palestras ele tem. O
/// evento atual tem a borda na cor principal e o selo `VOCÊ ESTÁ AQUI`; os
/// que já terminaram mostram `ENCERRADO`.
///
/// Tocar num card fecha a tela e devolve o `id_evento` escolhido
/// (`Navigator.pop(context, id)`), como a tela Avaliar devolve se algo
/// mudou. Quem troca o evento é o Início, ao receber esse valor.
///
/// A lista de eventos vem do Início, que já a buscou. Esta tela só busca
/// a programação de cada evento (`GET /api/eventos/<id>/programacao`),
/// todas ao mesmo tempo, para contar as palestras.
class EscolherEventoPage extends StatefulWidget {
  final List<dynamic> eventos;
  final int idEventoAtual;

  const EscolherEventoPage({super.key, required this.eventos, required this.idEventoAtual});

  @override
  State<EscolherEventoPage> createState() => _EscolherEventoPageState();
}

class _EscolherEventoPageState extends State<EscolherEventoPage> {
  /// Quantas palestras cada evento tem (chave: `id_evento`). Um evento
  /// cuja busca falhou fica fora do mapa e aparece sem a contagem.
  late final Future<Map<int, int>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = contarPalestras();
  }

  Future<Map<int, int>> contarPalestras() async {
    final ids = [for (final e in widget.eventos) e['id_evento'] as int];
    final listas = await Future.wait([
      for (final id in ids) ApiService.programacao(id).then<List<dynamic>?>((l) => l).catchError((_) => null),
    ]);
    return {
      for (var i = 0; i < ids.length; i++)
        if (listas[i] != null) ids[i]: listas[i]!.length,
    };
  }

  /// O evento já terminou (o último dia é anterior a hoje)?
  bool encerrado(dynamic evento) {
    final fim = DateTime.tryParse(evento['data_fim'] ?? '');
    return fim != null && fim.isBefore(DateUtils.dateOnly(DateTime.now()));
  }

  /// Ordem dos cards: o evento atual primeiro, depois os que ainda não
  /// terminaram (por data de início) e, por último, os encerrados.
  List<dynamic> ordenados() {
    int grupo(dynamic e) => e['id_evento'] == widget.idEventoAtual ? 0 : (encerrado(e) ? 2 : 1);
    return [...widget.eventos]..sort((a, b) {
        final porGrupo = grupo(a).compareTo(grupo(b));
        return porGrupo != 0 ? porGrupo : (a['data_inicio'] ?? '').compareTo(b['data_inicio'] ?? '');
      });
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(titulo: 'Escolher evento'),
          Expanded(
            // Os cards aparecem na hora; só a contagem de palestras espera
            // a busca terminar.
            child: FutureBuilder<Map<int, int>>(
              future: futuro,
              builder: (context, snapshot) {
                final palestras = snapshot.data ?? {};
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Text(
                      'Cada evento acontece em um lugar, com a própria programação, planta e palestrantes.',
                      style: textos.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    for (final evento in ordenados())
                      _CardEscolha(
                        evento: evento,
                        atual: evento['id_evento'] == widget.idEventoAtual,
                        encerrado: encerrado(evento),
                        palestras: palestras[evento['id_evento']],
                        aoTocar: () => Navigator.pop(context, evento['id_evento'] as int),
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

/// Um card de evento: datas e selo na primeira linha, nome em Bricolage e
/// "lugar · N palestras".
class _CardEscolha extends StatelessWidget {
  final dynamic evento;
  final bool atual;
  final bool encerrado;

  /// `null` enquanto a contagem não chegou (ou se a busca falhou).
  final int? palestras;
  final VoidCallback aoTocar;

  const _CardEscolha({
    required this.evento,
    required this.atual,
    required this.encerrado,
    required this.palestras,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final cantos = BorderRadius.circular(12);
    final lugar = (evento['local'] ?? 'Local a definir').toString();
    final contagem = palestras == null ? '' : (palestras == 1 ? ' · 1 palestra' : ' · $palestras palestras');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: cantos,
          side: BorderSide(color: atual ? cores.primary : cores.outlineVariant),
        ),
        child: InkWell(
          borderRadius: cantos,
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(periodoEvento(evento['data_inicio'], evento['data_fim']), style: textos.labelMedium),
                  ),
                  if (atual)
                    const _SeloAqui()
                  else if (encerrado)
                    Text('ENCERRADO', style: textos.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                Text(evento['nome'] ?? '', style: textos.titleLarge),
                const SizedBox(height: 6),
                Text('$lugar$contagem', style: textos.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selo `VOCÊ ESTÁ AQUI`, preenchido na cor de destaque (Céu), como o
/// marca-texto.
class _SeloAqui extends StatelessWidget {
  const _SeloAqui();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: cores.tertiary, borderRadius: BorderRadius.circular(6)),
      child: Text(
        'VOCÊ ESTÁ AQUI',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cores.onTertiary,
            ),
      ),
    );
  }
}
