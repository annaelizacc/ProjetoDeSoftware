import 'package:flutter/material.dart';

import '../models/palestra.dart';
import '../services/api_service.dart';
import '../widgets/cabecalho_tela.dart';
import '../widgets/estrelas.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Avaliar palestra" (F06 e F07: RF15 e RF16).
///
/// A pessoa escolhe de 1 a 5 estrelas e pode escrever um comentário. A
/// tela tem dois modos, decididos por `palestra.minhaAvaliacao`:
/// - **nova avaliação**: "Enviar avaliação" chama `POST /api/avaliacoes`;
/// - **edição**: já vem com a nota e o comentário preenchidos; "Salvar"
///   chama `PUT /api/avaliacoes/<id>`, e "Excluir avaliação" chama
///   `DELETE`, depois de uma confirmação.
///
/// Quem pode avaliar (inscrito e palestra já começada) é decidido no
/// backend. A tela de detalhes só abre esta tela quando `podeAvaliar` é
/// verdadeiro ou quando a pessoa já tem uma avaliação, e, se mesmo assim o backend recusar, a mensagem dele
/// aparece num SnackBar.
///
/// Ao terminar, fecha devolvendo `true`, para os detalhes recarregarem a
/// média e os comentários.
class AvaliarPage extends StatefulWidget {
  final Palestra palestra;

  const AvaliarPage({super.key, required this.palestra});

  @override
  State<AvaliarPage> createState() => _AvaliarPageState();
}

class _AvaliarPageState extends State<AvaliarPage> {
  /// Legenda de cada nota (a posição 0 é a de "nenhuma nota ainda").
  static const legendas = ['Toque nas estrelas para dar uma nota', 'Ruim', 'Regular', 'Boa', 'Muito boa', 'Excelente'];

  final comentario = TextEditingController();
  int nota = 0;

  /// Evita enviar duas vezes com um toque duplo no botão.
  bool enviando = false;

  bool get editando => widget.palestra.minhaAvaliacao != null;

  @override
  void initState() {
    super.initState();
    final minha = widget.palestra.minhaAvaliacao;
    if (minha != null) {
      nota = minha.nota;
      comentario.text = minha.comentario ?? '';
    }
  }

  /// Executa a chamada à API, fecha a tela se der certo ou mostra a
  /// mensagem do backend se der errado.
  Future<void> executar(Future<void> Function() acao) async {
    setState(() => enviando = true);
    try {
      await acao();
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (mounted) {
        setState(() => enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void enviar() {
    // Comentário vazio vai como `null`: a avaliação fica só com as estrelas.
    final texto = comentario.text.trim().isEmpty ? null : comentario.text.trim();
    final minha = widget.palestra.minhaAvaliacao;
    executar(() => minha == null
        ? ApiService.criarAvaliacao(widget.palestra.id, nota, texto)
        : ApiService.atualizarAvaliacao(minha.id, nota, texto));
  }

  Future<void> excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir avaliação?'),
        content: const Text('A nota e o comentário serão apagados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contexto, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(contexto, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmou == true) executar(() => ApiService.excluirAvaliacao(widget.palestra.minhaAvaliacao!.id));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final p = widget.palestra;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabecalhoTela(titulo: editando ? 'Editar avaliação' : 'Avaliar palestra', secao: 'Palestra'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              children: [
                // Resumo da palestra avaliada.
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.horario} · ${p.sala ?? 'Local a definir'}'.toUpperCase(), style: tema.textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(p.titulo, style: tema.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text('Como foi a palestra?', style: tema.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Estrelas(nota: nota.toDouble(), tamanho: 28, aoEscolher: (n) => setState(() => nota = n)),
                const SizedBox(height: 12),
                Text(
                  (nota == 0 ? legendas[0] : '$nota/5 · ${legendas[nota]}').toUpperCase(),
                  style: tema.textTheme.labelMedium,
                ),
                const SizedBox(height: 22),
                const RotuloSecao('Comentário (opcional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: comentario,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Conte o que achou da palestra'),
                ),
              ],
            ),
          ),
          // Barra de baixo, como no canvas: fundo de card e linha fina.
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: cores.surface,
              border: Border(top: BorderSide(color: cores.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: nota == 0 || enviando ? null : enviar,
                    child: Text(editando ? 'Salvar alterações' : 'Enviar avaliação'),
                  ),
                  if (editando) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: enviando ? null : excluir,
                      style: TextButton.styleFrom(foregroundColor: cores.error),
                      child: const Text('Excluir avaliação'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    comentario.dispose();
    super.dispose();
  }
}
