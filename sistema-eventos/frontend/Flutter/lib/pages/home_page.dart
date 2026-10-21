import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'programacao_page.dart';

/// Tela inicial (Home).
///
/// Exibe uma saudação ao usuário logado e a lista de eventos disponíveis,
/// obtida via `GET /api/eventos` (`ApiService.eventos`). A partir daqui o
/// usuário toca em um evento para ver sua programação completa
/// (`ProgramacaoPage`), que lista as palestras daquele evento.
class HomePage extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;

  const HomePage({super.key, required this.usuarioId, required this.nomeUsuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> futuroEventos;

  @override
  void initState() {
    super.initState();
    futuroEventos = ApiService.eventos();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(() => futuroEventos = ApiService.eventos()),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Olá, ${widget.nomeUsuario}',
              style: TextStyle(fontSize: 15, color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Encontre seu próximo evento',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: cores.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Banner de destaque: usa o azul secundário do tema (Rio), e o
            // texto usa `onSecondary`, a cor feita para ficar legível sobre
            // ele nos dois modos.
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cores.secondary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available, color: cores.onSecondary, size: 42),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'A programação oficial está pronta para você.',
                      style: TextStyle(
                        color: cores.onSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Eventos disponíveis',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<dynamic>>(
              future: futuroEventos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) return Text('Erro: ${snapshot.error}');
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum evento encontrado.');
                }
                return Column(
                  children: snapshot.data!.map((evento) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cores.secondaryContainer,
                          child: Icon(Icons.event, color: cores.onSecondaryContainer),
                        ),
                        title: Text(evento['nome'] ?? ''),
                        subtitle: Text(evento['local'] ?? 'Local não informado'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProgramacaoPage(
                              eventoId: evento['id_evento'],
                              nomeEvento: evento['nome'],
                              usuarioId: widget.usuarioId,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
