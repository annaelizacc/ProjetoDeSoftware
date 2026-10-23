import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/campo_imagem.dart';
import '../widgets/formulario_organizador.dart';

/// O que a tela do evento devolve ao fechar, para o painel saber o que
/// recarregar.
enum ResultadoEvento { salvo, removido }

/// Tela "Evento" do organizador (F14, com a planta da F03).
///
/// Aberta pelo painel do organizador em dois casos:
/// - "Novo evento" (`evento` nulo): cria o evento (`POST /api/eventos`);
/// - "Evento e planta" (`evento` preenchido): edita o evento escolhido
///   (`PUT /api/eventos/<id>`) e mostra o botão "Excluir evento".
///
/// A planta faz parte do mesmo formulário (prancha "Cadastro do evento e
/// planta" do canvas). Ao salvar, o evento é gravado primeiro e a planta
/// depois (`PUT /api/eventos/<id>/planta`), porque a planta precisa do
/// `id_evento`, que um evento novo só ganha ao ser criado.
///
/// Excluir apaga o evento com as palestras e inscrições. Por isso pede a
/// senha do app da pessoa logada, que o backend confere.
class OrganizadorEventoPage extends StatefulWidget {
  final Map<String, dynamic>? evento;

  const OrganizadorEventoPage({super.key, this.evento});

  @override
  State<OrganizadorEventoPage> createState() => _OrganizadorEventoPageState();
}

class _OrganizadorEventoPageState extends State<OrganizadorEventoPage> {
  final nome = TextEditingController();
  final descricao = TextEditingController();
  final local = TextEditingController();
  final descricaoPlanta = TextEditingController();
  DateTime? inicio;
  DateTime? fim;
  String? imagemPlanta;
  // A planta só é gravada se o evento já tinha uma ou se a pessoa
  // preencheu algo: assim um evento novo sem planta não ganha uma vazia.
  bool temPlanta = false;
  bool salvando = false;

  /// Id do evento já gravado: o que veio para edição ou o que acabou de
  /// ser criado. Se a planta falhar depois de criar o evento, um novo
  /// toque em "Salvar" altera esse evento em vez de criar outro igual.
  late int? eventoId = widget.evento?['id_evento'];

  bool get editando => widget.evento != null;

  @override
  void initState() {
    super.initState();
    final evento = widget.evento;
    if (evento != null) {
      nome.text = evento['nome'] ?? '';
      descricao.text = evento['descricao'] ?? '';
      local.text = evento['local'] ?? '';
      inicio = DateTime.tryParse(evento['data_inicio'] ?? '');
      fim = DateTime.tryParse(evento['data_fim'] ?? '');
      carregarPlanta(evento['id_evento']);
    }
  }

  Future<void> carregarPlanta(int eventoId) async {
    try {
      final planta = await ApiService.planta(eventoId);
      if (!mounted || planta == null) return;
      setState(() {
        temPlanta = true;
        imagemPlanta = planta['imagem_mapa'];
        descricaoPlanta.text = planta['descricao'] ?? '';
      });
    } catch (_) {
      // Sem a planta, o formulário continua funcionando: o organizador
      // pode enviar a imagem de novo.
    }
  }

  Future<void> escolherData({required bool ehInicio}) async {
    final atual = (ehInicio ? inicio : fim) ?? inicio ?? DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhida == null) return;
    setState(() => ehInicio ? inicio = escolhida : fim = escolhida);
  }

  /// Confere os campos antes de enviar. O backend confere de novo.
  String? validar() {
    if (nome.text.trim().isEmpty) return 'Digite o nome do evento.';
    if (inicio == null || fim == null) return 'Escolha as datas de início e fim.';
    if (fim!.isBefore(inicio!)) return 'A data de fim não pode ser antes do início.';
    return null;
  }

  Future<void> salvar() async {
    final problema = validar();
    if (problema != null) {
      mostrarMensagem(context, problema);
      return;
    }

    final dados = {
      'nome': nome.text.trim(),
      'descricao': descricao.text.trim(),
      'data_inicio': dataIso(inicio!),
      'data_fim': dataIso(fim!),
      'local': local.text.trim(),
    };

    setState(() => salvando = true);
    try {
      if (eventoId == null) {
        eventoId = (await ApiService.criarEvento(dados))['id_evento'];
      } else {
        await ApiService.atualizarEvento(eventoId!, dados);
      }
      if (temPlanta || imagemPlanta != null || descricaoPlanta.text.trim().isNotEmpty) {
        await ApiService.salvarPlanta(eventoId!, imagemPlanta, descricaoPlanta.text.trim());
      }
      if (mounted) Navigator.pop(context, ResultadoEvento.salvo);
    } catch (erro) {
      if (mounted) {
        mostrarMensagem(context, textoDoErro(erro));
        setState(() => salvando = false);
      }
    }
  }

  /// Pede a senha numa janela e, se a pessoa confirmar, apaga o evento.
  Future<void> excluir() async {
    final digitada = await showDialog<String>(
      context: context,
      builder: (_) => const _JanelaSenha(),
    );
    if (digitada == null || !mounted) return;

    setState(() => salvando = true);
    try {
      await ApiService.removerEvento(widget.evento!['id_evento'], digitada);
      if (mounted) Navigator.pop(context, ResultadoEvento.removido);
    } catch (erro) {
      if (mounted) {
        mostrarMensagem(context, textoDoErro(erro));
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return FormularioOrganizador(
      titulo: editando ? 'Evento' : 'Novo evento',
      textoBotao: 'Salvar evento',
      salvando: salvando,
      aoSalvar: salvar,
      campos: [
        CampoFormulario(rotulo: 'Nome do evento', controller: nome, dica: 'Ex.: Semana de Tecnologia'),
        CampoFormulario(rotulo: 'Descrição', controller: descricao, linhas: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CampoEscolha(
                rotulo: 'Início',
                texto: inicio == null ? null : dataBr(inicio!),
                vazio: 'dd/mm/aaaa',
                icone: Icons.calendar_today_outlined,
                aoTocar: () => escolherData(ehInicio: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CampoEscolha(
                rotulo: 'Fim',
                texto: fim == null ? null : dataBr(fim!),
                vazio: 'dd/mm/aaaa',
                icone: Icons.calendar_today_outlined,
                aoTocar: () => escolherData(ehInicio: false),
              ),
            ),
          ],
        ),
        CampoFormulario(rotulo: 'Local', controller: local, dica: 'Ex.: Centro de Convenções'),
        CampoImagem(
          rotulo: 'Planta baixa',
          textoBotao: 'Enviar imagem da planta',
          imagem: imagemPlanta,
          aoMudar: (nome) => setState(() => imagemPlanta = nome),
        ),
        CampoFormulario(
          rotulo: 'Descrição da planta',
          controller: descricaoPlanta,
          dica: 'Ex.: Mapa do térreo e do 1º andar',
        ),
        if (editando)
          TextButton.icon(
            onPressed: salvando ? null : excluir,
            style: TextButton.styleFrom(foregroundColor: cores.error),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir evento'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    nome.dispose();
    descricao.dispose();
    local.dispose();
    descricaoPlanta.dispose();
    super.dispose();
  }
}

/// Janela "Excluir evento?" com o campo de senha. Devolve a senha
/// digitada ao confirmar, ou `null` ao cancelar.
///
/// É um widget com estado próprio porque o campo de senha precisa de um
/// `TextEditingController`, que só pode ser descartado (`dispose`) depois
/// que a janela some da tela, inclusive da animação de fechar.
class _JanelaSenha extends StatefulWidget {
  const _JanelaSenha();

  @override
  State<_JanelaSenha> createState() => _JanelaSenhaState();
}

class _JanelaSenhaState extends State<_JanelaSenha> {
  final senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir evento?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O evento será apagado com todas as palestras, inscrições, '
            'locais e patrocinadores. Isso não pode ser desfeito.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: senha,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite sua senha do app'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, senha.text), child: const Text('Excluir')),
      ],
    );
  }

  @override
  void dispose() {
    senha.dispose();
    super.dispose();
  }
}
