import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'palestra_details_page.dart';

/// Tela de agenda pessoal.
///
/// Lista as palestras em que o usuário está inscrito, obtidas em
/// `GET /api/eventos/<id_usuario>/agenda` (`ApiService.agenda`), que no
/// backend é resolvida pelo `ObterAgendaUsuarioService` com uma consulta
/// SQL explícita (JOIN entre participação, palestra e evento).
class AgendaPage extends StatelessWidget {
  final int usuarioId;

  const AgendaPage({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha agenda')),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.agenda(usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) return const Center(child: Text('Você ainda não possui inscrições.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: lista.map((json) {
              final p = Palestra.fromJson(Map<String, dynamic>.from(json));
              final cor = AppColors.corDaCategoria(p.tema ?? p.titulo);
              final corTexto = AppColors.corDeDestaqueDaCategoria(p.tema ?? p.titulo);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cor,
                    child: Icon(Icons.event_note, color: corTexto),
                  ),
                  title: Text(p.titulo),
                  subtitle: Text('${p.horario} • ${p.sala ?? ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PalestraDetailsPage(usuarioId: usuarioId, palestraId: p.id),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
