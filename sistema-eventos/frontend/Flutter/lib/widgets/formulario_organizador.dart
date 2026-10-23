import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'cabecalho_tela.dart';

/// Componente compartilhado: o molde dos formulários do organizador (F14).
///
/// Segue a prancha "Componente: formulário do organizador" do canvas,
/// usada por todos os cadastros (evento, local, palestrante, palestra e
/// patrocinador):
///
/// - no topo, o `CabecalhoTela` com o rótulo `ORGANIZADOR · CADASTRO`;
/// - no meio, os campos, que rolam se não couberem na tela;
/// - embaixo, uma barra fixa com "Cancelar" e o botão principal. Enquanto
///   salva, o botão mostra um indicador de carregamento e fica desativado
///   (assim um toque duplo não cria dois registros).
///
/// Cada tela só monta a lista de campos e diz o que fazer ao salvar.
/// Com `aoExcluir` (ao editar um registro), aparece no fim dos campos o
/// botão "Excluir", na cor de atenção. `secao` troca o rótulo do topo
/// (ex.: `Organizador · participantes`, no envio de comunicado).
class FormularioOrganizador extends StatelessWidget {
  final String titulo;
  final String textoBotao;
  final List<Widget> campos;
  final VoidCallback aoSalvar;
  final bool salvando;
  final VoidCallback? aoExcluir;
  final String secao;

  const FormularioOrganizador({
    super.key,
    required this.titulo,
    required this.textoBotao,
    required this.campos,
    required this.aoSalvar,
    this.salvando = false,
    this.aoExcluir,
    this.secao = 'Organizador · cadastro',
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          CabecalhoTela(titulo: titulo, secao: secao),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                for (final campo in campos) ...[campo, const SizedBox(height: 14)],
                if (aoExcluir != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: salvando ? null : aoExcluir,
                      style: TextButton.styleFrom(foregroundColor: cores.error),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Excluir'),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: cores.surface,
              border: Border(top: BorderSide(color: cores.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(64, 50)),
                    onPressed: salvando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: salvando ? null : aoSalvar,
                      child: salvando
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: cores.onPrimary, strokeWidth: 2),
                            )
                          : Text(textoBotao),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Um campo do formulário: o rótulo em JetBrains Mono maiúsculo (como
/// no canvas) e, embaixo, o que for passado em `child`, ou um campo de
/// texto quando `child` não é informado.
class CampoFormulario extends StatelessWidget {
  final String rotulo;
  final TextEditingController? controller;
  final String? dica;
  final int linhas;
  final TextInputType? teclado;

  /// Conteúdo próprio do campo (ex.: uma lista de opções ou uma imagem).
  final Widget? child;

  const CampoFormulario({
    super.key,
    required this.rotulo,
    this.controller,
    this.dica,
    this.linhas = 1,
    this.teclado,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        child ??
            TextField(
              controller: controller,
              minLines: linhas,
              maxLines: linhas == 1 ? 1 : linhas + 4,
              keyboardType: linhas > 1 ? TextInputType.multiline : teclado,
              decoration: InputDecoration(hintText: dica),
            ),
      ],
    );
  }
}

/// Mostra uma mensagem rápida no rodapé da tela (ex.: o erro do backend).
void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

/// Tira o "Exception: " que o Dart coloca antes da mensagem do backend.
String textoDoErro(Object erro) => erro.toString().replaceFirst('Exception: ', '');

/// Roda a ação de um formulário (salvar ou excluir) e fecha a tela
/// devolvendo `true`, para a lista ser buscada de novo. Se o backend
/// recusar, mostra a mensagem dele e a tela continua aberta.
///
/// `marcarSalvando` liga e desliga o carregamento do botão (o `setState`
/// da tela).
Future<void> executarEFechar(
  BuildContext context,
  void Function(bool) marcarSalvando,
  Future<void> Function() acao,
) async {
  marcarSalvando(true);
  try {
    await acao();
    if (context.mounted) Navigator.pop(context, true);
  } catch (erro) {
    if (context.mounted) {
      mostrarMensagem(context, textoDoErro(erro));
      marcarSalvando(false);
    }
  }
}

/// Campo que mostra um valor escolhido numa janela (data, horário) em
/// JetBrains Mono, como datas e horários no canvas, e abre a janela ao
/// ser tocado. `texto` nulo mostra o `vazio` (ex.: `dd/mm/aaaa`).
class CampoEscolha extends StatelessWidget {
  final String rotulo;
  final String? texto;
  final String vazio;
  final IconData icone;
  final VoidCallback aoTocar;

  const CampoEscolha({
    super.key,
    required this.rotulo,
    required this.texto,
    required this.vazio,
    required this.icone,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return CampoFormulario(
      rotulo: rotulo,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(suffixIcon: Icon(icone, size: 18)),
          child: Text(
            texto ?? vazio,
            style: tema.textTheme.bodyLarge?.copyWith(
              fontFamily: AppFontes.mono,
              color: texto == null ? tema.colorScheme.onSurfaceVariant : null,
            ),
          ),
        ),
      ),
    );
  }
}

String _doisDigitos(int numero) => numero.toString().padLeft(2, '0');

/// Data no formato que o backend espera (`2026-10-22`).
String dataIso(DateTime data) => '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';

/// Data como se escreve no Brasil (`22/10/2026`).
String dataBr(DateTime data) => '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

/// Horário com dois dígitos (`09:00`).
String horaTexto(TimeOfDay hora) => '${_doisDigitos(hora.hour)}:${_doisDigitos(hora.minute)}';
