import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'cabecalho_tela.dart';
import 'formulario_organizador.dart';

/// Um item da lista de um cadastro: o que aparece em cada card.
class ItemCadastro {
  final String titulo;
  final String? detalhe;

  /// Nome da imagem enviada (foto, logo), mostrada à esquerda.
  final String? imagem;

  const ItemCadastro({required this.titulo, this.detalhe, this.imagem});
}

/// Componente compartilhado: a lista de um cadastro do organizador (F14).
///
/// Locais, palestrantes, palestras e patrocinadores têm a mesma tela de
/// lista: um card por registro, um botão "Adicionar" e um toque no card
/// para editar. Este componente faz essa parte comum (buscar os dados,
/// mostrar o carregamento, o erro ou a lista vazia, e buscar de novo ao
/// voltar do formulário). Cada tela só diz:
///
/// - `carregar`: como buscar a lista na API;
/// - `montarItem`: o que mostrar em cada card;
/// - `abrirFormulario`: qual formulário abrir. Recebe o registro tocado,
///   ou `null` para um novo, e devolve `true` se algo foi salvo ou
///   removido (aí a lista é buscada de novo).
class ListaCadastro extends StatefulWidget {
  final String titulo;
  final String textoAdicionar;
  final String textoVazio;
  final Future<List<dynamic>> Function() carregar;
  final ItemCadastro Function(Map<String, dynamic> registro) montarItem;
  final Future<bool?> Function(Map<String, dynamic>? registro) abrirFormulario;

  const ListaCadastro({
    super.key,
    required this.titulo,
    required this.textoAdicionar,
    required this.textoVazio,
    required this.carregar,
    required this.montarItem,
    required this.abrirFormulario,
  });

  @override
  State<ListaCadastro> createState() => _ListaCadastroState();
}

class _ListaCadastroState extends State<ListaCadastro> {
  late Future<List<dynamic>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = widget.carregar();
  }

  Future<void> abrir(Map<String, dynamic>? registro) async {
    final mudou = await widget.abrirFormulario(registro);
    if (mudou == true && mounted) setState(() => futuro = widget.carregar());
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrir(null),
        icon: const Icon(Icons.add),
        label: Text(widget.textoAdicionar),
      ),
      body: Column(
        children: [
          CabecalhoTela(titulo: widget.titulo, secao: 'Organizador'),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(textoDoErro(snapshot.error!)));
                }
                final registros = snapshot.data ?? [];
                if (registros.isEmpty) {
                  return Center(child: Text(widget.textoVazio, style: tema.textTheme.bodySmall));
                }
                return ListView(
                  // Espaço embaixo para o botão "Adicionar" não cobrir o
                  // último card.
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                  children: [
                    for (final json in registros)
                      _CardCadastro(
                        item: widget.montarItem(Map<String, dynamic>.from(json)),
                        aoTocar: () => abrir(Map<String, dynamic>.from(json)),
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

class _CardCadastro extends StatelessWidget {
  final ItemCadastro item;
  final VoidCallback aoTocar;

  const _CardCadastro({required this.item, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final imagem = item.imagem;

    return Card(
      child: ListTile(
        onTap: aoTocar,
        leading: imagem == null
            ? null
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ApiService.urlImagem(imagem),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 44, height: 44),
                ),
              ),
        title: Text(item.titulo),
        subtitle: item.detalhe == null
            ? null
            : Text(item.detalhe!, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.edit_outlined, color: cores.onSurfaceVariant),
      ),
    );
  }
}

/// Pergunta antes de apagar um registro. Devolve `true` se a pessoa
/// confirmou.
Future<bool> confirmarRemocao(BuildContext context, String oQue) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text('Excluir $oQue?'),
      content: const Text('Isso não pode ser desfeito.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(contexto, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(contexto, true), child: const Text('Excluir')),
      ],
    ),
  );
  return confirmou == true;
}
