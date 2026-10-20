import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Tela de avisos e notificações.
///
/// Lista as notificações/lembretes do usuário
/// (`GET /api/notificacoes/usuario/<id>`, via `ApiService.notificacoes`).
/// O ícone e a cor de cada item mudam conforme `tipo_notificacao`,
/// reaproveitando os assets `imgAtencao.png`/`imgInfo.png`/`imgLembrete.png`
/// que já existiam no projeto para diferenciar visualmente os tipos de
/// aviso, como na tela "Avisos" do design de referência.
class NotificacoesPage extends StatelessWidget {
  final int usuarioId;

  const NotificacoesPage({super.key, required this.usuarioId});

  /// Escolhe o asset e a cor de fundo do card conforme o tipo de notificação.
  ({String asset, Color cor}) _estiloPorTipo(String? tipo) {
    switch (tipo) {
      case 'atencao':
        return (asset: 'assets/images/imgAtencao.png', cor: AppColors.categorias[1]);
      case 'lembrete':
        return (asset: 'assets/images/imgLembrete.png', cor: AppColors.categorias[2]);
      default:
        return (asset: 'assets/images/imgInfo.png', cor: AppColors.categorias[0]);
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
              final estilo = _estiloPorTipo(item['tipo_notificacao']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: estilo.cor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: Image.asset(estilo.asset, width: 32, height: 32),
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
