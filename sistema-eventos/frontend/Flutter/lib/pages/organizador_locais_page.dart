import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/formulario_organizador.dart';
import '../widgets/lista_cadastro.dart';

/// Tela "Locais e rotas" do organizador (F14, com a rota da F04).
///
/// Lista os locais do evento (`GET /api/locais?id_evento=`) e abre o
/// formulário para criar ou editar um local. A "rota" é o passo a passo,
/// em texto, de como chegar ao local a partir da entrada do evento
/// (decisão da F04), guardado no campo `descricao`.
class OrganizadorLocaisPage extends StatelessWidget {
  final int eventoId;

  const OrganizadorLocaisPage({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return ListaCadastro(
      titulo: 'Locais e rotas',
      textoAdicionar: 'Adicionar local',
      textoVazio: 'Nenhum local cadastrado.',
      carregar: () => ApiService.locais(eventoId),
      montarItem: (local) => ItemCadastro(
        titulo: local['nome_local'] ?? '',
        detalhe: local['descricao'],
      ),
      abrirFormulario: (local) => Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => _FormularioLocal(eventoId: eventoId, local: local)),
      ),
    );
  }
}

/// Formulário "Local e rota" (prancha do canvas): nome e passo a passo.
class _FormularioLocal extends StatefulWidget {
  final int eventoId;
  final Map<String, dynamic>? local;

  const _FormularioLocal({required this.eventoId, this.local});

  @override
  State<_FormularioLocal> createState() => _FormularioLocalState();
}

class _FormularioLocalState extends State<_FormularioLocal> {
  late final nome = TextEditingController(text: widget.local?['nome_local']);
  late final rota = TextEditingController(text: widget.local?['descricao']);
  bool salvando = false;

  int? get id => widget.local?['id_localizacao'];

  void salvar() {
    if (nome.text.trim().isEmpty) {
      mostrarMensagem(context, 'Digite o nome do local.');
      return;
    }
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.salvarCadastro('locais', id, {
        'id_evento': widget.eventoId,
        'nome_local': nome.text.trim(),
        'descricao': rota.text.trim(),
      }),
    );
  }

  Future<void> excluir() async {
    if (!await confirmarRemocao(context, 'este local')) return;
    if (!mounted) return;
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.removerCadastro('locais', id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Local e rota',
      textoBotao: 'Salvar local',
      salvando: salvando,
      aoSalvar: salvar,
      aoExcluir: id == null ? null : excluir,
      campos: [
        CampoFormulario(rotulo: 'Nome do local', controller: nome, dica: 'Ex.: Sala A1'),
        CampoFormulario(
          rotulo: 'Como chegar (a partir da entrada)',
          controller: rota,
          linhas: 5,
          dica: '1. Entre pelo hall principal.\n2. Suba a escada à direita.\n3. Primeira porta à esquerda.',
        ),
      ],
    );
  }

  @override
  void dispose() {
    nome.dispose();
    rota.dispose();
    super.dispose();
  }
}
