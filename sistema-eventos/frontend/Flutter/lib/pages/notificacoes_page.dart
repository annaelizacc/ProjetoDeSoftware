import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Tela de avisos e notificações.
///
/// Lista as notificações/lembretes do usuário
/// (`GET /api/notificacoes/usuario/<id>`, via `ApiService.notificacoes`).
/// O ícone de cada item muda conforme `tipo_notificacao`, reaproveitando os assets `imgAtencao.png`/`imgInfo.png`/`imgLembrete.png`
/// que já existiam no projeto para diferenciar visualmente os tipos de
/// aviso, como na tela "Avisos" do design de referência.
class NotificacoesPage extends StatelessWidget {
  final int usuarioId;

  const NotificacoesPage({super.key, required this.usuarioId});

  /// Escolhe o ícone (asset) conforme o tipo de notificação.
  String _iconePorTipo(String? tipo) {
    switch (tipo) {
      case 'atencao':
        return 'assets/images/imgAtencao.png';
      case 'lembrete':
        return 'assets/images/imgLembrete.png';
      default:
        return 'assets/images/imgInfo.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avisos e notificações')),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.notificacoes(usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) return const Center(child: Text('Você não possui notificações.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: lista.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Image.asset(
                    _iconePorTipo(item['tipo_notificacao']),
                    width: 32,
                    height: 32,
                  ),
                  title: Text(item['mensagem'] ?? ''),
                  subtitle: Text(item['tipo_notificacao'] ?? 'aviso'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
