import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/formulario_organizador.dart';

/// Tela "Enviar comunicado" (F09, RF18).
///
/// Aberta pelo painel do organizador. Segue a prancha "Enviar comunicado"
/// do canvas, com o mesmo molde dos cadastros (`FormularioOrganizador`):
///
/// - **Para:** lista suspensa com "Todos os participantes do evento" (quem
///   está inscrito em pelo menos uma palestra) ou uma palestra do evento
///   (só os inscritos nela). Cada palestra mostra quantos inscritos tem;
///   as que não têm nenhum aparecem desativadas. As palestras vêm do
///   painel, que já as buscou;
/// - **Mensagem:** até 500 caracteres, com o contador embaixo (o mesmo
///   limite que o backend confere).
///
/// O envio não pode ser desfeito, então o botão ("Enviar para todos" ou
/// "Enviar para os inscritos") pede uma confirmação antes. Depois de enviar, mostra para quantas pessoas o
/// comunicado foi e volta ao painel.
class OrganizadorComunicadoPage extends StatefulWidget {
  final int eventoId;

  /// Palestras do evento, como vêm do painel (com `total_inscritos`).
  final List<dynamic> palestras;

  const OrganizadorComunicadoPage({
    super.key,
    required this.eventoId,
    required this.palestras,
  });

  @override
  State<OrganizadorComunicadoPage> createState() => _OrganizadorComunicadoPageState();
}

class _OrganizadorComunicadoPageState extends State<OrganizadorComunicadoPage> {
  /// Mesmo limite do `EnviarComunicadoService` no backend.
  static const tamanhoMaximo = 500;

  final mensagem = TextEditingController();
  bool enviando = false;

  /// Palestra escolhida em "Para"; `null` = todos os participantes.
  int? palestraId;

  /// Título da palestra escolhida, usado no texto da confirmação.
  String get tituloEscolhido =>
      widget.palestras.firstWhere((p) => p['id_palestra'] == palestraId)['titulo'] ?? '';

  Future<void> enviar() async {
    final texto = mensagem.text.trim();
    if (texto.isEmpty) {
      mostrarMensagem(context, 'Escreva a mensagem do comunicado.');
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Enviar comunicado?'),
        content: Text(
          '${palestraId == null ? 'Todos os participantes do evento' : 'Os inscritos em "$tituloEscolhido"'} '
          'vão receber este aviso. Depois de enviado, ele não pode ser desfeito.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => enviando = true);
    try {
      final total = await ApiService.enviarComunicado(
        widget.eventoId,
        texto,
        palestraId: palestraId,
      );
      if (!mounted) return;
      // A mensagem aparece no painel, porque esta tela fecha em seguida.
      mostrarMensagem(
        context,
        total == 1
            ? 'Comunicado enviado para 1 pessoa.'
            : 'Comunicado enviado para $total pessoas.',
      );
      Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;
      mostrarMensagem(context, textoDoErro(erro));
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Enviar comunicado',
      secao: 'Organizador · participantes',
      textoBotao: palestraId == null ? 'Enviar para todos' : 'Enviar para os inscritos',
      salvando: enviando,
      aoSalvar: enviar,
      campos: [
        CampoFormulario(
          rotulo: 'Para',
          child: DropdownButtonFormField<int?>(
            initialValue: palestraId,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Todos os participantes do evento'),
              ),
              for (final p in widget.palestras)
                DropdownMenuItem(
                  value: p['id_palestra'] as int,
                  // Sem inscritos, não há para quem enviar.
                  enabled: (p['total_inscritos'] ?? 0) > 0,
                  child: Text(
                    '${p['titulo']} · ${_inscritos(p['total_inscritos'] ?? 0)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: enviando ? null : (id) => setState(() => palestraId = id),
          ),
        ),
        CampoFormulario(
          rotulo: 'Mensagem',
          // `maxLength` mostra o contador ("12/500") e não deixa passar
          // do limite.
          child: TextField(
            controller: mensagem,
            minLines: 6,
            maxLines: 10,
            maxLength: tamanhoMaximo,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Ex.: Credenciamento aberto no hall principal até as 10h.',
            ),
          ),
        ),
      ],
    );
  }

  static String _inscritos(int total) => total == 1 ? '1 inscrito' : '$total inscritos';

  @override
  void dispose() {
    mensagem.dispose();
    super.dispose();
  }
}
