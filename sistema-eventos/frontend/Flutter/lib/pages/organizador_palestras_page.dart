import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/formulario_organizador.dart';
import '../widgets/lista_cadastro.dart';

/// Tela "Palestras" do organizador (F14).
///
/// Lista as palestras do evento (`GET /api/palestras?id_evento=`, a mesma
/// rota da programação) e abre o formulário para criar ou editar.
///
/// O formulário busca os locais e os palestrantes do evento para as duas
/// listas de escolha. Por isso, no painel, "Locais" e "Palestrantes" vêm
/// antes de "Palestras": a palestra só aponta para o que já existe.
class OrganizadorPalestrasPage extends StatelessWidget {
  final int eventoId;

  const OrganizadorPalestrasPage({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return ListaCadastro(
      titulo: 'Palestras',
      textoAdicionar: 'Adicionar palestra',
      textoVazio: 'Nenhuma palestra cadastrada.',
      carregar: () => ApiService.programacao(eventoId),
      montarItem: (p) => ItemCadastro(titulo: p['titulo'] ?? '', detalhe: _resumoHorario(p)),
      abrirFormulario: (p) => Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => _FormularioPalestra(eventoId: eventoId, palestra: p)),
      ),
    );
  }
}

/// Linha do card: `05/11 · 09:00—10:00 · Sala A1 · 30 vagas`.
String _resumoHorario(Map<String, dynamic> p) {
  final inicio = DateTime.tryParse(p['horario_inicio'] ?? '');
  final fim = DateTime.tryParse(p['horario_fim'] ?? '');
  return [
    if (inicio != null) dataBr(inicio).substring(0, 5),
    if (inicio != null)
      horaTexto(TimeOfDay.fromDateTime(inicio)) +
          (fim == null ? '' : '—${horaTexto(TimeOfDay.fromDateTime(fim))}'),
    if (p['sala'] != null) p['sala'],
    '${p['vagas_total']} vagas',
  ].join(' · ');
}

/// Formulário "Palestra" (prancha do canvas): título, resumo, tema, dia,
/// horários, local, vagas e palestrante.
class _FormularioPalestra extends StatefulWidget {
  final int eventoId;
  final Map<String, dynamic>? palestra;

  const _FormularioPalestra({required this.eventoId, this.palestra});

  @override
  State<_FormularioPalestra> createState() => _FormularioPalestraState();
}

class _FormularioPalestraState extends State<_FormularioPalestra> {
  late final titulo = TextEditingController(text: widget.palestra?['titulo']);
  late final resumo = TextEditingController(text: widget.palestra?['resumo']);
  late final tema = TextEditingController(text: widget.palestra?['tema']);
  late final vagas = TextEditingController(text: '${widget.palestra?['vagas_total'] ?? 50}');
  DateTime? dia;
  TimeOfDay? inicio;
  TimeOfDay? fim;
  int? localId;
  int? palestranteId;
  bool salvando = false;

  /// Opções das listas de escolha, buscadas ao abrir a tela.
  List<dynamic> locais = [];
  List<dynamic> palestrantes = [];

  int? get id => widget.palestra?['id_palestra'];

  @override
  void initState() {
    super.initState();
    final p = widget.palestra;
    if (p != null) {
      final comeco = DateTime.tryParse(p['horario_inicio'] ?? '');
      final termino = DateTime.tryParse(p['horario_fim'] ?? '');
      dia = comeco;
      inicio = comeco == null ? null : TimeOfDay.fromDateTime(comeco);
      fim = termino == null ? null : TimeOfDay.fromDateTime(termino);
      localId = p['id_localizacao'];
      palestranteId = p['id_palestrante'];
    }
    carregarOpcoes();
  }

  Future<void> carregarOpcoes() async {
    try {
      final resultados = await Future.wait([
        ApiService.locais(widget.eventoId),
        ApiService.palestrantes(widget.eventoId),
      ]);
      if (!mounted) return;
      setState(() {
        locais = resultados[0];
        palestrantes = resultados[1];
      });
    } catch (erro) {
      if (mounted) mostrarMensagem(context, textoDoErro(erro));
    }
  }

  Future<void> escolherDia() async {
    final escolhido = await showDatePicker(
      context: context,
      initialDate: dia ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhido != null) setState(() => dia = escolhido);
  }

  Future<void> escolherHora({required bool ehInicio}) async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: (ehInicio ? inicio : fim) ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (escolhida == null) return;
    setState(() => ehInicio ? inicio = escolhida : fim = escolhida);
  }

  /// Junta o dia e o horário no texto ISO que o backend espera
  /// (`2026-11-05T09:00:00`).
  String? juntar(TimeOfDay? hora) =>
      dia == null || hora == null ? null : '${dataIso(dia!)}T${horaTexto(hora)}:00';

  String? validar() {
    if (titulo.text.trim().isEmpty) return 'Digite o título da palestra.';
    if (dia == null || inicio == null || fim == null) {
      return 'Escolha o dia e os horários de início e fim.';
    }
    final minutosInicio = inicio!.hour * 60 + inicio!.minute;
    final minutosFim = fim!.hour * 60 + fim!.minute;
    if (minutosFim <= minutosInicio) return 'O fim precisa ser depois do início.';
    final total = int.tryParse(vagas.text.trim());
    if (total == null || total < 1) return 'Digite o total de vagas (1 ou mais).';
    return null;
  }

  void salvar() {
    final problema = validar();
    if (problema != null) {
      mostrarMensagem(context, problema);
      return;
    }
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.salvarCadastro('palestras', id, {
        'id_evento': widget.eventoId,
        'titulo': titulo.text.trim(),
        'resumo': resumo.text.trim(),
        'tema': tema.text.trim(),
        'horario_inicio': juntar(inicio),
        'horario_fim': juntar(fim),
        'id_localizacao': localId,
        'id_palestrante': palestranteId,
        'vagas_total': int.parse(vagas.text.trim()),
      }),
    );
  }

  Future<void> excluir() async {
    if (!await confirmarRemocao(context, 'esta palestra')) return;
    if (!mounted) return;
    executarEFechar(
      context,
      (valor) => setState(() => salvando = valor),
      () => ApiService.removerCadastro('palestras', id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Palestra',
      textoBotao: 'Salvar palestra',
      salvando: salvando,
      aoSalvar: salvar,
      aoExcluir: id == null ? null : excluir,
      campos: [
        CampoFormulario(rotulo: 'Título', controller: titulo),
        CampoFormulario(rotulo: 'Resumo', controller: resumo, linhas: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CampoFormulario(rotulo: 'Tema', controller: tema, dica: 'Ex.: Tecnologia'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CampoEscolha(
                rotulo: 'Dia',
                texto: dia == null ? null : dataBr(dia!),
                vazio: 'dd/mm/aaaa',
                icone: Icons.calendar_today_outlined,
                aoTocar: escolherDia,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CampoEscolha(
                rotulo: 'Início',
                texto: inicio == null ? null : horaTexto(inicio!),
                vazio: '--:--',
                icone: Icons.schedule,
                aoTocar: () => escolherHora(ehInicio: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CampoEscolha(
                rotulo: 'Fim',
                texto: fim == null ? null : horaTexto(fim!),
                vazio: '--:--',
                icone: Icons.schedule,
                aoTocar: () => escolherHora(ehInicio: false),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Escolha(
                rotulo: 'Local',
                valor: localId,
                opcoes: {for (final l in locais) l['id_localizacao'] as int: l['nome_local'] ?? ''},
                aoMudar: (valor) => setState(() => localId = valor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CampoFormulario(
                rotulo: 'Vagas',
                controller: vagas,
                teclado: TextInputType.number,
              ),
            ),
          ],
        ),
        _Escolha(
          rotulo: 'Palestrante',
          valor: palestranteId,
          opcoes: {for (final p in palestrantes) p['id_palestrante'] as int: p['nome'] ?? ''},
          aoMudar: (valor) => setState(() => palestranteId = valor),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titulo.dispose();
    resumo.dispose();
    tema.dispose();
    vagas.dispose();
    super.dispose();
  }
}

/// Lista de escolha (local ou palestrante), com a opção "Nenhum": os dois
/// são opcionais na palestra.
class _Escolha extends StatelessWidget {
  final String rotulo;
  final int? valor;
  final Map<int, String> opcoes;
  final ValueChanged<int?> aoMudar;

  const _Escolha({
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    // Enquanto as opções não chegam, o valor salvo ainda não está na
    // lista; o campo mostra vazio em vez de dar erro.
    final valorNaLista = opcoes.containsKey(valor) ? valor : null;
    return CampoFormulario(
      rotulo: rotulo,
      child: DropdownButtonFormField<int?>(
        initialValue: valorNaLista,
        // A `key` muda quando as opções chegam, para o campo redesenhar
        // com o valor salvo.
        key: ValueKey('$rotulo-${opcoes.length}'),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text('Nenhum')),
          for (final opcao in opcoes.entries)
            DropdownMenuItem(
              value: opcao.key,
              child: Text(opcao.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: aoMudar,
      ),
    );
  }
}
