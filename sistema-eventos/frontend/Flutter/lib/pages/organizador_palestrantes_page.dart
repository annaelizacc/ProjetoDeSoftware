import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/campo_imagem.dart';
import '../widgets/formulario_organizador.dart';
import '../widgets/lista_cadastro.dart';

/// Tela "Palestrantes" do organizador (F14, com os dados da F05).
///
/// Lista os palestrantes do evento (`GET /api/palestrantes?id_evento=`) e
/// abre o formulário para criar ou editar. O palestrante é cadastrado
/// uma vez no evento e depois indicado nas palestras (formulário da
/// palestra). A foto é enviada pelo `CampoImagem`.
class OrganizadorPalestrantesPage extends StatelessWidget {
  final int eventoId;

  const OrganizadorPalestrantesPage({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return ListaCadastro(
      titulo: 'Palestrantes',
      textoAdicionar: 'Adicionar palestrante',
      textoVazio: 'Nenhum palestrante cadastrado.',
      carregar: () => ApiService.palestrantes(eventoId),
      montarItem: (p) => ItemCadastro(
        titulo: p['nome'] ?? '',
        detalhe: p['descricao'],
        imagem: p['foto'],
      ),
      abrirFormulario: (p) => Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => _FormularioPalestrante(eventoId: eventoId, palestrante: p),
        ),
      ),
    );
  }
}

/// Formulário "Palestrante" (prancha do canvas): foto, nome, descrição e
/// rede social.
class _FormularioPalestrante extends StatefulWidget {
  final int eventoId;
  final Map<String, dynamic>? palestrante;

  const _FormularioPalestrante({required this.eventoId, this.palestrante});

  @override
  State<_FormularioPalestrante> createState() => _FormularioPalestranteState();
}

class _FormularioPalestranteState extends State<_FormularioPalestrante> {
  late final nome = TextEditingController(text: widget.palestrante?['nome']);
  late final descricao = TextEditingController(text: widget.palestrante?['descricao']);
  late final redeSocial = TextEditingController(text: widget.palestrante?['rede_social']);
  late String? foto = widget.palestrante?['foto'];
  bool salvando = false;

  int? get id => widget.palestrante?['id_palestrante'];

  void salvar() {
    if (nome.text.trim().isEmpty) {
      mostrarMensagem(context, 'Digite o nome do palestrante.');
      return;
    }
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.salvarCadastro('palestrantes', id, {
        'id_evento': widget.eventoId,
        'nome': nome.text.trim(),
        'foto': foto,
        'descricao': descricao.text.trim(),
        'rede_social': redeSocial.text.trim(),
      }),
    );
  }

  Future<void> excluir() async {
    if (!await confirmarRemocao(context, 'este palestrante')) return;
    if (!mounted) return;
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.removerCadastro('palestrantes', id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Palestrante',
      textoBotao: 'Salvar palestrante',
      salvando: salvando,
      aoSalvar: salvar,
      aoExcluir: id == null ? null : excluir,
      campos: [
        CampoImagem(
          rotulo: 'Foto',
          textoBotao: 'Enviar foto',
          imagem: foto,
          aoMudar: (nome) => setState(() => foto = nome),
        ),
        CampoFormulario(rotulo: 'Nome', controller: nome, dica: 'Ex.: Carla Souza'),
        CampoFormulario(rotulo: 'Descrição', controller: descricao, linhas: 4),
        CampoFormulario(
          rotulo: 'Rede social',
          controller: redeSocial,
          dica: 'Ex.: linkedin.com/in/carlasouza',
          teclado: TextInputType.url,
        ),
      ],
    );
  }

  @override
  void dispose() {
    nome.dispose();
    descricao.dispose();
    redeSocial.dispose();
    super.dispose();
  }
}
