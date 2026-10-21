import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'programacao_page.dart';

/// Aba Programação da barra de navegação.
///
/// A `ProgramacaoPage` mostra as palestras de UM evento e precisa receber
/// qual. Como o app é pensado para um evento por vez (canvas,
/// "Programação"), esta aba busca a lista de eventos
/// (`GET /api/eventos`, `ApiService.eventos`) e abre a programação do
/// primeiro. Os outros eventos continuam acessíveis pela lista do Início.
class ProgramacaoAbaPage extends StatefulWidget {
  final int usuarioId;

  const ProgramacaoAbaPage({super.key, required this.usuarioId});

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
        final eventos = snapshot.data ?? [];
        if (eventos.isEmpty) {
          return const Center(child: Text('Nenhum evento encontrado.'));
        }
        final evento = eventos.first;
        return ProgramacaoPage(
          eventoId: evento['id_evento'],
          nomeEvento: evento['nome'] ?? '',
          usuarioId: widget.usuarioId,
        );
      },
    );
  }
}
