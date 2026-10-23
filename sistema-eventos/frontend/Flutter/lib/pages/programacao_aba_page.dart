import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'home_page.dart';
import 'programacao_page.dart';

/// Aba Programação da barra de navegação.
///
/// A `ProgramacaoPage` mostra as palestras de UM evento e precisa receber
/// qual. Como o app é pensado para um evento por vez (canvas,
/// "Programação"), esta aba busca a lista de eventos
/// (`GET /api/eventos`, `ApiService.eventos`) e abre a programação do
/// mesmo evento do Início: o escolhido em "Trocar evento" ou, sem
/// escolha, o próximo evento (`escolherEvento`, em `home_page.dart`).
class ProgramacaoAbaPage extends StatefulWidget {
  final int usuarioId;

  /// Evento escolhido no Início (guardado no `AppShell`), ou `null`.
  final int? eventoId;

  const ProgramacaoAbaPage({super.key, required this.usuarioId, required this.eventoId});

  @override
  State<ProgramacaoAbaPage> createState() => _ProgramacaoAbaPageState();
}

class _ProgramacaoAbaPageState extends State<ProgramacaoAbaPage> {
  late Future<List<dynamic>> futuroEventos;

  @override
  void initState() {
    super.initState();
    futuroEventos = ApiService.eventos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futuroEventos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        final evento = escolherEvento(snapshot.data ?? [], widget.eventoId);
        if (evento == null) {
          return const Center(child: Text('Nenhum evento encontrado.'));
        }
        return ProgramacaoPage(
          eventoId: evento['id_evento'],
          nomeEvento: evento['nome'] ?? '',
          usuarioId: widget.usuarioId,
        );
      },
    );
  }
}
