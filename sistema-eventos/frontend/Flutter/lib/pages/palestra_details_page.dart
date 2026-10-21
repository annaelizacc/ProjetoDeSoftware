import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';

/// Tela de detalhes da palestra.
///
/// Busca os dados completos de uma palestra, já com as flags do usuário
/// logado (`inscrito`, `favorita`, `lembreteAtivo`), em
/// `GET /api/palestras/<id>` (`ApiService.palestra`, usuário vindo do token). A
/// partir daqui o usuário pode:
/// - se inscrever ou cancelar a inscrição (`/api/inscricoes`);
/// - favoritar ou remover dos favoritos (`/api/favoritos`);
/// - ativar ou desativar o lembrete da palestra (`/api/lembretes`).
///
/// Depois de qualquer ação, a tela recarrega os dados (`carregar()`) para
/// refletir o novo estado vindo do backend, em vez de tentar adivinhar o
/// resultado no próprio Flutter.
class PalestraDetailsPage extends StatefulWidget {
  final int usuarioId;
  final int palestraId;

  const PalestraDetailsPage({super.key, required this.usuarioId, required this.palestraId});

  @override
  State<PalestraDetailsPage> createState() => _PalestraDetailsPageState();
}

class _PalestraDetailsPageState extends State<PalestraDetailsPage> {
  late Future<Palestra> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  Future<Palestra> carregar() async => Palestra.fromJson(await ApiService.palestra(widget.palestraId, widget.usuarioId));

  /// Executa uma ação da API (inscrever, favoritar, etc.) e recarrega os
  /// dados da tela; erros de negócio vindos do backend (ex.: "sem vagas")
  /// aparecem como um SnackBar, sem quebrar a tela.
  Future<void> executar(Future<void> Function() acao) async {
    try {
      await acao();
      if (mounted) setState(() => futuro = carregar());
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da palestra')),
      body: FutureBuilder<Palestra>(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final p = snapshot.data!;
          final temVagas = p.vagas > 0;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                p.titulo,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cores.primary),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text(p.tema ?? 'Sem tema')),
                Chip(label: Text(p.sala ?? 'Sala a definir')),
                Chip(label: Text(p.horario)),
              ]),
              const SizedBox(height: 20),
              Text(
                p.resumo ?? 'Resumo não informado.',
                style: TextStyle(fontSize: 15, height: 1.5, color: cores.onSurfaceVariant),
              ),
              const SizedBox(height: 22),
              // Palestra lotada: ícone e texto na cor `error` (Brasa), a cor
              // de "esgotada e atenção" da identidade visual.
              Card(
                child: ListTile(
                  leading: Icon(
                    temVagas ? Icons.people_alt_outlined : Icons.block,
                    color: temVagas ? cores.primary : cores.error,
                  ),
                  title: Text(
                    temVagas ? '${p.vagas} vagas disponíveis' : 'Palestra lotada',
                    style: temVagas ? null : TextStyle(color: cores.error),
                  ),
                  subtitle: Text('Capacidade total: ${p.total}'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: p.inscrito
                    ? () => executar(() => ApiService.cancelarInscricao(widget.usuarioId, p.id))
                    : temVagas
                        ? () => executar(() => ApiService.inscrever(widget.usuarioId, p.id))
                        : null,
                icon: Icon(p.inscrito ? Icons.event_busy : Icons.event_available),
                label: Text(p.inscrito ? 'Cancelar inscrição' : 'Inscrever-se'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => executar(() => ApiService.alterarFavorito(widget.usuarioId, p.id, !p.favorita)),
                icon: Icon(p.favorita ? Icons.star : Icons.star_border),
                label: Text(p.favorita ? 'Remover dos favoritos' : 'Favoritar palestra'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => executar(() => ApiService.alterarLembrete(widget.usuarioId, p.id, !p.lembreteAtivo)),
                icon: Icon(p.lembreteAtivo ? Icons.notifications_active : Icons.notifications_none),
                label: Text(p.lembreteAtivo ? 'Desativar lembrete' : 'Ativar lembrete'),
              ),
            ],
          );
        },
      ),
    );
  }
}
