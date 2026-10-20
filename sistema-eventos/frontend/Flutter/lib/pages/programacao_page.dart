import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'palestra_details_page.dart';

/// Tela de programação de um evento.
///
/// Lista as palestras de um evento (`GET /api/palestras?id_evento=...`),
/// com um campo de busca que filtra por tema/título
/// (`ApiService.programacao(eventoId, tema: ...)`, que repassa o parâmetro
/// `tema` para o `PalestraRepository` no backend). Cada palestra é exibida
/// em um card colorido conforme seu tema, para reproduzir o efeito visual
/// do design de referência.
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

  @override
  void initState() {
    super.initState();
    futuro = ApiService.programacao(widget.eventoId);
  }

  void pesquisar() => setState(() => futuro = ApiService.programacao(widget.eventoId, tema: busca.text));

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
                      final corFundo = AppColors.corDaCategoria(palestra.tema ?? palestra.titulo);
                      final corTexto = AppColors.corDeDestaqueDaCategoria(palestra.tema ?? palestra.titulo);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: corFundo,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          title: Text(
                            palestra.titulo,
                            style: TextStyle(fontWeight: FontWeight.bold, color: corTexto),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${palestra.tema ?? 'Sem tema'} • ${palestra.sala ?? 'Sala a definir'}\n'
                              '${palestra.horario} • ${palestra.vagas} vagas',
                              style: TextStyle(color: corTexto.withValues(alpha: 0.85)),
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right, color: corTexto),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PalestraDetailsPage(
                                usuarioId: widget.usuarioId,
                                palestraId: palestra.id,
                              ),
                            ),
                          ),
                        ),
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
