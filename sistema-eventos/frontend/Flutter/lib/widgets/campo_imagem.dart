import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import 'formulario_organizador.dart';

/// Componente compartilhado: campo de imagem dos cadastros (F14).
///
/// Usado na planta do evento (F03), na foto do palestrante (F05) e no
/// logo do patrocinador (F10). Segue a área de envio do canvas: um
/// quadro com o ícone de imagem, o texto do botão e, embaixo, um aviso
/// pequeno com os tipos aceitos (`ApiService.tiposDeImagem`).
///
/// Ao tocar, abre a galeria (no celular) ou a janela de arquivos (na
/// web) com o pacote `image_picker`. A imagem escolhida é enviada na
/// hora (`ApiService.enviarImagem`), e o campo avisa a tela pelo
/// `aoMudar` com o nome que o backend devolveu. Se o backend recusar
/// (tipo errado, mais de 5 MB), a mensagem dele aparece num SnackBar.
///
/// Com uma imagem escolhida, o quadro mostra a imagem e um botão
/// "Remover", que deixa o cadastro sem imagem (`aoMudar(null)`).
class CampoImagem extends StatefulWidget {
  final String rotulo;
  final String textoBotao;

  /// Nome do arquivo já salvo no backend, ou `null` se ainda não tem.
  final String? imagem;
  final ValueChanged<String?> aoMudar;

  const CampoImagem({
    super.key,
    required this.rotulo,
    required this.textoBotao,
    required this.imagem,
    required this.aoMudar,
  });

  @override
  State<CampoImagem> createState() => _CampoImagemState();
}

class _CampoImagemState extends State<CampoImagem> {
  bool enviando = false;

  Future<void> escolher() async {
    final arquivo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (arquivo == null) return; // A pessoa fechou sem escolher.

    setState(() => enviando = true);
    try {
      widget.aoMudar(await ApiService.enviarImagem(arquivo));
    } catch (erro) {
      if (mounted) mostrarMensagem(context, textoDoErro(erro));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final imagem = widget.imagem;

    Widget conteudo;
    if (enviando) {
      conteudo = const CircularProgressIndicator();
    } else if (imagem != null) {
      conteudo = Image.network(
        ApiService.urlImagem(imagem),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text('Não foi possível mostrar a imagem.'),
      );
    } else {
      conteudo = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, color: cores.primary),
          const SizedBox(height: 6),
          Text(widget.textoBotao, style: tema.textTheme.titleSmall),
        ],
      );
    }

    return CampoFormulario(
      rotulo: widget.rotulo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: cores.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: cores.outline, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enviando ? null : escolher,
              child: SizedBox(
                height: imagem == null ? 110 : 160,
                child: Center(child: conteudo),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text(ApiService.tiposDeImagem, style: tema.textTheme.labelSmall)),
              if (imagem != null && !enviando) ...[
                TextButton(onPressed: escolher, child: const Text('Trocar')),
                TextButton(onPressed: () => widget.aoMudar(null), child: const Text('Remover')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
