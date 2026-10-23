import 'dart:math';

import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/avatar_iniciais.dart';
import '../widgets/cabecalho_tela.dart';

/// Tela "Inscrições" da área do organizador (F08, RF17).
///
/// Aberta pelo painel (`OrganizadorPainelPage`), que já envia a lista de
/// palestras do evento e qual delas mostrar primeiro. Segue a prancha
/// "Inscrições (RF17)" do canvas:
///
/// - um seletor para trocar de palestra;
/// - a barra de vagas ("2/50 inscritos · 48 vagas livres");
/// - uma busca por nome ou e-mail, feita no próprio app (a lista de uma
///   palestra é pequena, não precisa de uma rota de busca);
/// - a lista de inscritos (`GET /api/organizador/palestras/<id>/inscritos`)
///   com o botão "Remover". Antes de remover, o app pede confirmação,
///   porque não dá para desfazer. A API devolve a vaga e grava um aviso
///   para a pessoa removida.
class OrganizadorInscricoesPage extends StatefulWidget {
  final List<dynamic> palestras;
  final int palestraInicialId;

  const OrganizadorInscricoesPage({
    super.key,
    required this.palestras,
    required this.palestraInicialId,
  });

  @override
  State<OrganizadorInscricoesPage> createState() =>
      _OrganizadorInscricoesPageState();
}

class _OrganizadorInscricoesPageState extends State<OrganizadorInscricoesPage> {
  late int palestraId;
  late Future<List<dynamic>> futuro;
  final busca = TextEditingController();

  /// Inscritos e vagas livres de cada palestra, por id. Começam com os
  /// números do painel (os mesmos do ranking) e são atualizados a cada
  /// remoção, para a barra não ficar desatualizada sem precisar buscar
  /// tudo de novo.
  late final Map<int, int> inscritosPorPalestra = {
    for (final p in widget.palestras)
      p['id_palestra'] as int: p['total_inscritos'] as int,
  };
  late final Map<int, int> vagasLivres = {
    for (final p in widget.palestras)
      p['id_palestra'] as int: p['vagas_disponiveis'] as int,
  };

  @override
  void initState() {
    super.initState();
    palestraId = widget.palestraInicialId;
    futuro = ApiService.inscritosDaPalestra(palestraId);
  }

  Palestra get palestraAtual => Palestra.fromJson(
        Map<String, dynamic>.from(
          widget.palestras.firstWhere((p) => p['id_palestra'] == palestraId),
        ),
      );

  void trocarPalestra(int? id) {
    if (id == null || id == palestraId) return;
    setState(() {
      palestraId = id;
      busca.clear();
      futuro = ApiService.inscritosDaPalestra(id);
    });
  }

  Future<void> remover(Map<String, dynamic> pessoa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Remover inscrição?'),
        content: Text(
          'A inscrição de ${pessoa['nome']} em "${palestraAtual.titulo}" será removida. '
          'A vaga volta para a palestra e a pessoa recebe um aviso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(contexto).colorScheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    // Guarda a palestra da remoção: se a pessoa trocar de palestra
    // enquanto a API responde, a vaga é devolvida na palestra certa.
    final idDaRemocao = palestraId;
    final totalDaRemocao = palestraAtual.total;
    try {
      await ApiService.removerInscricao(idDaRemocao, pessoa['id_usuario']);
      if (!mounted) return;
      setState(() {
        // Mesma regra do backend: a vaga volta, mas nunca passa do total.
        inscritosPorPalestra[idDaRemocao] =
            max(0, (inscritosPorPalestra[idDaRemocao] ?? 0) - 1);
        vagasLivres[idDaRemocao] =
            min(totalDaRemocao, (vagasLivres[idDaRemocao] ?? 0) + 1);
        if (idDaRemocao == palestraId) {
          futuro = ApiService.inscritosDaPalestra(idDaRemocao);
        }
      });
      mostrarMensagem('Inscrição de ${pessoa['nome']} removida.');
    } catch (erro) {
      if (mounted) {
        mostrarMensagem(erro.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final palestra = palestraAtual;
    final livres = vagasLivres[palestraId] ?? 0;
    final inscritos = inscritosPorPalestra[palestraId] ?? 0;

    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(
              titulo: 'Inscrições', secao: 'Organizador · Participantes'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: palestraId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Palestra'),
                  items: [
                    for (final p in widget.palestras)
                      DropdownMenuItem(
                        value: p['id_palestra'] as int,
                        child: Text(p['titulo'] ?? '',
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: trocarPalestra,
                ),
                const SizedBox(height: 6),
                Text(
                  '${palestra.horario} · ${palestra.sala ?? 'Local a definir'}'
                      .toUpperCase(),
                  style: tema.textTheme.labelMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$inscritos/${palestra.total} INSCRITOS',
                      style: tema.textTheme.labelMedium?.copyWith(
                        color: cores.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      livres == 1 ? '1 VAGA LIVRE' : '$livres VAGAS LIVRES',
                      style: tema.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: palestra.total == 0 ? 0 : inscritos / palestra.total,
                    minHeight: 6,
                    backgroundColor: cores.secondaryContainer,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: busca,
                  decoration: const InputDecoration(
                    hintText: 'Buscar participante',
                    prefixIcon: Icon(Icons.search),
                  ),
                  // Só redesenha a lista com o filtro novo.
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<dynamic>>(
                  future: futuro,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', '')),
                      );
                    }
                    final termo = busca.text.trim().toLowerCase();
                    final lista = (snapshot.data ?? [])
                        .map((json) => Map<String, dynamic>.from(json))
                        .where((p) =>
                            termo.isEmpty ||
                            '${p['nome']} ${p['email']}'
                                .toLowerCase()
                                .contains(termo))
                        .toList();
                    if (lista.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          termo.isEmpty
                              ? 'Ninguém se inscreveu nesta palestra ainda.'
                              : 'Nenhum participante encontrado.',
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final pessoa in lista)
                          _ItemInscrito(
                              pessoa: pessoa, aoRemover: () => remover(pessoa))
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }
}

/// Uma pessoa inscrita: iniciais, nome, e-mail e o botão "Remover".
class _ItemInscrito extends StatelessWidget {
  final Map<String, dynamic> pessoa;
  final VoidCallback aoRemover;

  const _ItemInscrito({required this.pessoa, required this.aoRemover});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cores.outlineVariant)),
      ),
      child: Row(
        children: [
          AvatarIniciais(pessoa['nome'] ?? ''),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pessoa['nome'] ?? '', style: tema.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(pessoa['email'] ?? '', style: tema.textTheme.labelMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: aoRemover,
            style: OutlinedButton.styleFrom(
              foregroundColor: cores.error,
              side: BorderSide(color: cores.error),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Remover',
                semanticsLabel: 'Remover inscrição de ${pessoa['nome']}'),
          ),
        ],
      ),
    );
  }
}
