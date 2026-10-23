import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import 'palestra_details_page.dart';

/// Tela de favoritos (aberta pelo Perfil).
///
/// Lista as palestras marcadas como favoritas pelo usuário, obtidas em
/// `GET /api/favoritos/usuario/<id>` (`ApiService.favoritos`). O backend
/// devolve, para cada favorito, os dados da palestra já embutidos no mesmo
/// item (montados no `ListarFavoritosService`).
///
/// Segue a prancha "Favoritos (RF07)" do canvas: horário e dia em
/// JetBrains Mono à esquerda, título e "sala · palestrante" no meio e uma
/// estrela à direita que tira a palestra dos favoritos ali mesmo
/// (`ApiService.alterarFavorito`, o mesmo usado nos Detalhes).
class FavoritosPage extends StatefulWidget {
  final int usuarioId;

  const FavoritosPage({super.key, required this.usuarioId});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  late Future<List<dynamic>> futuro;

  /// Ids das palestras sendo removidas agora. Enquanto a API não responde,
  /// a estrela fica desativada, para dois toques rápidos não mandarem dois
  /// pedidos (o segundo daria erro, com a palestra já removida).
  final removendo = <int>{};

  @override
  void initState() {
    super.initState();
    futuro = ApiService.favoritos(widget.usuarioId);
  }

  /// Chaves no `setState`, e não seta: com a seta, a função devolveria o
  /// `Future` atribuído, e o Flutter recusa um `setState` que devolve um
  /// `Future` (ver `recarregar` em `palestra_details_page.dart`).
  void recarregar() {
    setState(() {
      futuro = ApiService.favoritos(widget.usuarioId);
    });
  }

  /// Tira a palestra dos favoritos e recarrega a lista. Se a API recusar,
  /// mostra o erro e a lista fica como estava.
  Future<void> remover(Palestra p) async {
    if (removendo.contains(p.id)) return;
    setState(() => removendo.add(p.id));
    try {
      await ApiService.alterarFavorito(widget.usuarioId, p.id, false);
      if (mounted) recarregar();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => removendo.remove(p.id));
    }
  }

  /// Abre os detalhes e, ao voltar, recarrega: a pessoa pode ter tirado a
  /// palestra dos favoritos por lá.
  Future<void> abrir(Palestra p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: p.id),
      ),
    );
    if (mounted) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Favoritos'),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                final lista = snapshot.data ?? [];
                if (lista.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Nenhuma palestra favoritada. Toque na estrela nos detalhes de uma palestra para guardá-la aqui.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    for (final item in lista.map((json) => Palestra.fromJson(Map<String, dynamic>.from(json))))
                      _ItemFavorito(
                        palestra: item,
                        aoAbrir: abrir,
                        aoRemover: removendo.contains(item.id) ? null : remover,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma linha da lista: horário e dia, título, "sala · palestrante" e a
/// estrela para remover.
class _ItemFavorito extends StatelessWidget {
  final Palestra palestra;
  final ValueChanged<Palestra> aoAbrir;

  /// `null` enquanto a remoção desta palestra está em andamento.
  final ValueChanged<Palestra>? aoRemover;

  const _ItemFavorito({required this.palestra, required this.aoAbrir, required this.aoRemover});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final p = palestra;
    final local = [p.sala ?? 'Local a definir', if (p.palestrante != null) p.palestrante!].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.outlineVariant))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: InkWell(
            onTap: () => aoAbrir(p),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 54,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    p.horaInicio,
                    style: tema.textTheme.labelMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: cores.primary),
                  ),
                  const SizedBox(height: 3),
                  Text(p.diaCurtoTexto, style: tema.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.titulo, style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(local, style: tema.textTheme.bodySmall),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Remover ${p.titulo} dos favoritos',
          onPressed: aoRemover == null ? null : () => aoRemover!(p),
          icon: Icon(Icons.star_rounded, color: cores.primary),
        ),
      ]),
    );
  }
}
