import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import 'avatar_iniciais.dart';
import 'rotulo_secao.dart';

/// Componente compartilhado: perfil do palestrante (RF14), como a prancha
/// "Perfil do palestrante" do canvas.
///
/// Abre como uma janela que sobe de baixo da tela (`showModalBottomSheet`,
/// o "bottom sheet" do Flutter), por cima da tela atual. Mostra a foto
/// (ou as iniciais), o nome, a rede social, a descrição e as palestras da
/// pessoa no mesmo evento. Tocar numa palestra chama `aoAbrirPalestra`.
///
/// Busca o palestrante em `GET /api/palestrantes/<id>` e as palestras em
/// `GET /api/palestras?id_evento=` (a programação), ficando só com as
/// dele.
Future<void> abrirPerfilPalestrante(
  BuildContext context, {
  required int idPalestrante,
  required int idEvento,
  required ValueChanged<Palestra> aoAbrirPalestra,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // Sem isso, a janela para na metade da tela.
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PerfilPalestrante(
      idPalestrante: idPalestrante,
      idEvento: idEvento,
      aoAbrirPalestra: aoAbrirPalestra,
    ),
  );
}

typedef _DadosPerfil = ({Map<String, dynamic> palestrante, List<Palestra> palestras});

class _PerfilPalestrante extends StatefulWidget {
  final int idPalestrante;
  final int idEvento;
  final ValueChanged<Palestra> aoAbrirPalestra;

  const _PerfilPalestrante({
    required this.idPalestrante,
    required this.idEvento,
    required this.aoAbrirPalestra,
  });

  @override
  State<_PerfilPalestrante> createState() => _PerfilPalestranteState();
}

class _PerfilPalestranteState extends State<_PerfilPalestrante> {
  late final Future<_DadosPerfil> futuro = carregar();

  Future<_DadosPerfil> carregar() async {
    final respostas = await Future.wait([
      ApiService.palestrante(widget.idPalestrante),
      ApiService.programacao(widget.idEvento),
    ]);
    return (
      palestrante: respostas[0] as Map<String, dynamic>,
      palestras: [
        for (final json in respostas[1] as List<dynamic>)
          if (json['id_palestrante'] == widget.idPalestrante)
            Palestra.fromJson(Map<String, dynamic>.from(json)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return FractionallySizedBox(
      heightFactor: 0.75,
      child: FutureBuilder<_DadosPerfil>(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
            );
          }
          final pessoa = snapshot.data!.palestrante;
          final nome = pessoa['nome'] ?? '';
          final foto = pessoa['foto'];
          final redeSocial = (pessoa['rede_social'] ?? '').toString().trim();
          final descricao = (pessoa['descricao'] ?? '').toString().trim();

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
            children: [
              Row(
                children: [
                  foto == null
                      ? AvatarIniciais(nome, raio: 42, estilo: textos.headlineSmall)
                      : ClipOval(
                          child: Image.network(
                            ApiService.urlImagem(foto),
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            // Se a imagem não carregar (ex.: arquivo
                            // apagado do servidor), mostra as iniciais.
                            errorBuilder: (_, __, ___) =>
                                AvatarIniciais(nome, raio: 42, estilo: textos.headlineSmall),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RotuloSecao('Palestrante'),
                        const SizedBox(height: 4),
                        Text(nome, style: textos.headlineSmall),
                        if (redeSocial.isNotEmpty)
                          // Selecionável para a pessoa poder copiar: o app
                          // ainda não abre links no navegador.
                          SelectableText(
                            redeSocial,
                            style: textos.labelMedium?.copyWith(color: cores.primary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (descricao.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(descricao, style: textos.bodyLarge),
              ],
              const SizedBox(height: 20),
              const RotuloSecao('Palestras no evento'),
              const SizedBox(height: 6),
              for (final p in snapshot.data!.palestras)
                InkWell(
                  onTap: () => widget.aoAbrirPalestra(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: cores.outlineVariant)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            p.horario.split(' - ').first,
                            style: textos.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cores.primary,
                            ),
                          ),
                        ),
                        Expanded(child: Text(p.titulo, style: textos.titleSmall)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
