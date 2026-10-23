import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/avatar_iniciais.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/perfil_palestrante.dart';
import '../widgets/rotulo_secao.dart';
import 'palestra_details_page.dart';

/// Tela "Palestrantes" (F05, RF13).
///
/// Lista os palestrantes do evento e permite pesquisar pelo nome
/// (`GET /api/palestrantes?id_evento=<id>&busca=<texto>`,
/// `ApiService.palestrantes`), como na prancha "Palestrantes (RF13)" do
/// canvas. Abre pelo atalho "Palestrantes" do Início.
///
/// Tocar num palestrante abre o perfil (RF14, `abrirPerfilPalestrante`),
/// o mesmo usado nos detalhes da palestra. Tocar numa palestra do perfil
/// abre os detalhes dela.
class PalestrantesPage extends StatefulWidget {
  final int eventoId;
  final String nomeEvento;
  final int usuarioId;

  const PalestrantesPage({
    super.key,
    required this.eventoId,
    required this.nomeEvento,
    required this.usuarioId,
  });

  @override
  State<PalestrantesPage> createState() => _PalestrantesPageState();
}

class _PalestrantesPageState extends State<PalestrantesPage> {
  /// Busca atual na API. A cada letra digitada, recebe uma busca nova.
  /// O `FutureBuilder` só mostra o resultado da busca mais recente: se a
  /// resposta de uma busca antiga chegar atrasada, ela é ignorada.
  late Future<List<dynamic>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = ApiService.palestrantes(widget.eventoId);
  }

  void pesquisar(String texto) {
    setState(() {
      futuro = ApiService.palestrantes(widget.eventoId, busca: texto);
    });
  }

  /// Abre o perfil do palestrante. Tocar numa palestra do perfil fecha a
  /// janela e abre os detalhes da palestra.
  void abrirPerfil(int idPalestrante) {
    abrirPerfilPalestrante(
      context,
      idPalestrante: idPalestrante,
      idEvento: widget.eventoId,
      aoAbrirPalestra: (palestra) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PalestraDetailsPage(usuarioId: widget.usuarioId, palestraId: palestra.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(titulo: 'Palestrantes'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              onChanged: pesquisar,
              decoration: const InputDecoration(
                hintText: 'Pesquisar pelo nome',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futuro,
              builder: (context, snapshot) {
                // Durante uma busca nova, o `FutureBuilder` guarda a lista
                // anterior (`hasData`): ela continua na tela, sem piscar o
                // círculo de carregando a cada letra.
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
                }
                final lista = snapshot.data ?? [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    RotuloSecao('Quem fala: ${widget.nomeEvento}'),
                    const SizedBox(height: 8),
                    if (lista.isEmpty)
                      Text('Nenhum palestrante encontrado.', style: Theme.of(context).textTheme.bodySmall)
                    else
                      for (final item in lista)
                        _LinhaPalestrante(
                          dados: Map<String, dynamic>.from(item),
                          aoTocar: () => abrirPerfil(item['id_palestrante']),
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

/// Linha da lista: foto (ou as iniciais), nome e o começo da descrição.
class _LinhaPalestrante extends StatelessWidget {
  final Map<String, dynamic> dados;
  final VoidCallback aoTocar;

  const _LinhaPalestrante({required this.dados, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final nome = (dados['nome'] ?? '').toString();
    final foto = dados['foto'];
    final descricao = (dados['descricao'] ?? '').toString().trim();

    return InkWell(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cores.outlineVariant)),
        ),
        child: Row(
          children: [
            foto == null
                ? AvatarIniciais(nome, raio: 24)
                : ClipOval(
                    child: Image.network(
                      ApiService.urlImagem(foto),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      // Se a imagem não carregar, mostra as iniciais.
                      errorBuilder: (_, __, ___) => AvatarIniciais(nome, raio: 24),
                    ),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: textos.titleSmall),
                  if (descricao.isNotEmpty)
                    Text(
                      descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.bodySmall,
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cores.outline),
          ],
        ),
      ),
    );
  }
}
