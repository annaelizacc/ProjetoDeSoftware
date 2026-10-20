import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'palestra_details_page.dart';

/// Tela de favoritos.
///
/// Lista as palestras marcadas como favoritas pelo usuário, obtidas em
/// `GET /api/favoritos/usuario/<id>` (`ApiService.favoritos`). O backend
/// devolve, para cada favorito, os dados da palestra já embutidos em
/// `item['palestra']` (montados no `ListarFavoritosService`).
class FavoritosPage extends StatefulWidget {
  final int usuarioId;

  const FavoritosPage({super.key, required this.usuarioId});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  late Future<List<dynamic>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = ApiService.favoritos(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus favoritos')),
      body: FutureBuilder<List<dynamic>>(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) return const Center(child: Text('Nenhuma palestra favoritada.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: lista.map((item) {
              final p = Palestra.fromJson(Map<String, dynamic>.from(item));
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(p.titulo),
                  subtitle: Text(p.tema ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PalestraDetailsPage(
                        usuarioId: widget.usuarioId,
                        palestraId: p.id,
                      ),
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
