import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/campo_imagem.dart';
import '../widgets/formulario_organizador.dart';
import '../widgets/lista_cadastro.dart';

/// Tela "Patrocinadores" do organizador (F14, com os dados da F10).
///
/// Lista os patrocinadores do evento (`GET /api/patrocinadores?id_evento=`,
/// a mesma rota da tela dos participantes) e abre o formulário para criar
/// ou editar. O logo é enviado pelo `CampoImagem`.
class OrganizadorPatrocinadoresPage extends StatelessWidget {
  final int eventoId;

  const OrganizadorPatrocinadoresPage({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return ListaCadastro(
      titulo: 'Patrocinadores',
      textoAdicionar: 'Adicionar patrocinador',
      textoVazio: 'Nenhum patrocinador cadastrado.',
      carregar: () => ApiService.patrocinadores(eventoId),
      montarItem: (p) => ItemCadastro(
        titulo: p['nome_empresa'] ?? '',
        detalhe: p['site'],
        imagem: p['logo'],
      ),
      abrirFormulario: (p) => Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => _FormularioPatrocinador(eventoId: eventoId, patrocinador: p),
        ),
      ),
    );
  }
}

/// Formulário "Patrocinador" (prancha do canvas): logo, empresa, site e
/// descrição.
class _FormularioPatrocinador extends StatefulWidget {
  final int eventoId;
  final Map<String, dynamic>? patrocinador;

  const _FormularioPatrocinador({required this.eventoId, this.patrocinador});

  @override
  State<_FormularioPatrocinador> createState() => _FormularioPatrocinadorState();
}

class _FormularioPatrocinadorState extends State<_FormularioPatrocinador> {
  late final empresa = TextEditingController(text: widget.patrocinador?['nome_empresa']);
  late final site = TextEditingController(text: widget.patrocinador?['site']);
  late final descricao = TextEditingController(text: widget.patrocinador?['descricao']);
  late String? logo = widget.patrocinador?['logo'];
  bool salvando = false;

  int? get id => widget.patrocinador?['id_patrocinador'];

  void salvar() {
    if (empresa.text.trim().isEmpty) {
      mostrarMensagem(context, 'Digite o nome da empresa.');
      return;
    }
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.salvarCadastro('patrocinadores', id, {
        'id_evento': widget.eventoId,
        'nome_empresa': empresa.text.trim(),
        'logo': logo,
        'site': site.text.trim(),
        'descricao': descricao.text.trim(),
      }),
    );
  }

  Future<void> excluir() async {
    if (!await confirmarRemocao(context, 'este patrocinador')) return;
    if (!mounted) return;
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.removerCadastro('patrocinadores', id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Patrocinador',
      textoBotao: 'Salvar patrocinador',
      salvando: salvando,
      aoSalvar: salvar,
      aoExcluir: id == null ? null : excluir,
      campos: [
        CampoImagem(
          rotulo: 'Logo',
          textoBotao: 'Enviar logo',
          imagem: logo,
          aoMudar: (nome) => setState(() => logo = nome),
        ),
        CampoFormulario(rotulo: 'Nome da empresa', controller: empresa),
        CampoFormulario(
          rotulo: 'Site',
          controller: site,
          dica: 'Ex.: nuvemazul.com',
          teclado: TextInputType.url,
        ),
        CampoFormulario(rotulo: 'Descrição', controller: descricao, linhas: 3),
      ],
    );
  }

  @override
  void dispose() {
    empresa.dispose();
    site.dispose();
    descricao.dispose();
    super.dispose();
  }
}
