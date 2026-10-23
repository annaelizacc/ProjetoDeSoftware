import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/estrelas.dart';
import '../widgets/selo.dart';
import 'palestra_details_page.dart';

/// Tela de programação de um evento.
///
/// Lista as palestras de um evento (`GET /api/palestras?id_evento=...`),
/// com um campo de busca que filtra por tema/título
/// (`ApiService.programacao(eventoId, tema: ...)`, que repassa o parâmetro
/// `tema` para o `PalestraRepository` no backend). Cada palestra é exibida
/// em um card do tema (fundo e linha fina), igual para todas as palestras.
class ProgramacaoPage extends StatefulWidget {
  final int eventoId;
  final int usuarioId;
  final String nomeEvento;

  const ProgramacaoPage({super.key, required this.eventoId, required this.usuarioId, required this.nomeEvento});

  @override
  State<ProgramacaoPage> createState() => _ProgramacaoPageState();
}

class _ProgramacaoPageState extends State<ProgramacaoPage> {
  final busca = TextEditingController();
  late Future<List<dynamic>> futuro;

  /// Último termo pesquisado. Ao voltar dos detalhes, a lista recarrega
  /// com ele, e não com um texto digitado e ainda não enviado.
  String temaAtual = '';

  @override
  void initState() {
    super.initState();
    futuro = ApiService.programacao(widget.eventoId);
  }

  void pesquisar() {
    temaAtual = busca.text;
    recarregar();
  }

  /// Chaves no `setState`, e não seta: com a seta, a função devolveria o
  /// `Future` atribuído, e o Flutter recusa um `setState` que devolve um
  /// `Future` (ver `recarregar` em `palestra_details_page.dart`).
  void recarregar() {
    setState(() {
      futuro = ApiService.programacao(widget.eventoId, tema: temaAtual);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nomeEvento)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: busca,
              onSubmitted: (_) => pesquisar(),
              decoration: InputDecoration(
                hintText: 'Pesquisar por tema',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(onPressed: pesquisar, icon: const Icon(Icons.arrow_forward)),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futuro,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
                  final lista = snapshot.data ?? [];
                  if (lista.isEmpty) return const Center(child: Text('Nenhuma palestra encontrada.'));
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (_, index) {
                      final palestra = Palestra.fromJson(Map<String, dynamic>.from(lista[index]));
                      return _ItemPalestra(
                        palestra: palestra,
                        aoTocar: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PalestraDetailsPage(
                                usuarioId: widget.usuarioId,
                                palestraId: palestra.id,
                              ),
                            ),
                          );
                          // Ao voltar dos detalhes, recarrega: a pessoa
                          // pode ter se inscrito ou avaliado (média nova).
                          if (mounted) recarregar();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }
}

/// Um item da lista, como na prancha "Programação" do canvas: horário à
/// esquerda em JetBrains Mono; título, local, tema e vagas à direita; e,
/// desde a F07, a média de estrelas quando a palestra já tem avaliações.
class _ItemPalestra extends StatelessWidget {
  final Palestra palestra;
  final VoidCallback aoTocar;

  const _ItemPalestra({required this.palestra, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final p = palestra;
    final partes = p.horario.split(' - ');

    return InkWell(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.outlineVariant))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 58,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                partes.first,
                style: tema.textTheme.labelMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: cores.primary),
              ),
              if (partes.length > 1) Text(partes[1], style: tema.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.titulo, style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(p.sala ?? 'Local a definir', style: tema.textTheme.bodySmall),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: Text(p.tema ?? 'Sem tema', style: tema.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                if (p.vagas <= 0)
                  const Selo('Esgotada', tipo: TipoSelo.alerta)
                else
                  Selo('${p.vagas} vagas'),
              ]),
              if (p.totalAvaliacoes > 0) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Estrelas(nota: p.mediaEstrelas ?? 0, tamanho: 14),
                  const SizedBox(width: 6),
                  Text('${p.mediaTexto} · ${p.totalAvaliacoes}', style: tema.textTheme.labelMedium),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
