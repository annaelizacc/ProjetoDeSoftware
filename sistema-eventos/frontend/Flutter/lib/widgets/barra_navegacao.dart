import 'package:flutter/material.dart';

import 'marca_texto.dart';

/// Componente compartilhado: barra de navegação inferior do app.
///
/// Tem as cinco abas do canvas ("Componente: barra de navegação"): Início,
/// Programação, Agenda, Avisos e Perfil. A aba atual fica com o texto em
/// negrito e o marca-texto; a aba Avisos mostra um contador quando há
/// avisos novos.
///
/// A barra só desenha as abas e avisa qual foi tocada (`aoTrocarAba`):
/// quem decide qual tela mostrar é o `AppShell` (`pages/app_shell.dart`).
class BarraNavegacao extends StatelessWidget {
  /// Posição da aba atual, de 0 (Início) a 4 (Perfil).
  final int abaAtual;
  final ValueChanged<int> aoTrocarAba;

  /// Quantidade de avisos novos. Com 0, o contador não aparece. (A
  /// contagem real depende da F21, que marca os avisos como lidos.)
  final int avisosNovos;

  const BarraNavegacao({
    super.key,
    required this.abaAtual,
    required this.aoTrocarAba,
    this.avisosNovos = 0,
  });

  /// Índice da aba Avisos, a única que tem contador.
  static const _abaAvisos = 3;

  static const _abas = [
    (icone: Icons.home_outlined, nome: 'Início'),
    (icone: Icons.format_list_bulleted, nome: 'Programação'),
    (icone: Icons.calendar_today_outlined, nome: 'Agenda'),
    (icone: Icons.notifications_none, nome: 'Avisos'),
    (icone: Icons.person_outline, nome: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        border: Border(top: BorderSide(color: cores.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              for (var i = 0; i < _abas.length; i++)
                Expanded(child: _item(context, i)),
            ],
          ),
        ),
      ),
    );
  }

  /// Monta uma aba: ícone, nome e, na aba Avisos, o contador.
  Widget _item(BuildContext context, int indice) {
    final cores = Theme.of(context).colorScheme;
    final aba = _abas[indice];
    final selecionada = indice == abaAtual;
    final cor = selecionada ? cores.onSurface : cores.onSurfaceVariant;
    final mostrarContador = indice == _abaAvisos && avisosNovos > 0;

    Widget icone = Icon(aba.icone, size: 22, color: cor);
    if (mostrarContador) {
      // `Badge` é o componente do Flutter para contadores sobre ícones.
      icone = Badge(
        label: Text('$avisosNovos'),
        backgroundColor: cores.error,
        textColor: cores.onError,
        child: icone,
      );
    }

    // `Semantics` descreve a aba para leitores de tela (acessibilidade),
    // por exemplo "Avisos, 2 novos".
    return Semantics(
      button: true,
      selected: selecionada,
      label: mostrarContador ? '${aba.nome}, $avisosNovos novos' : aba.nome,
      // Como `excludeSemantics` esconde o toque do `InkWell` abaixo, o
      // toque do leitor de tela é repassado aqui.
      onTap: () => aoTrocarAba(indice),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => aoTrocarAba(indice),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icone,
              const SizedBox(height: 6),
              // Em telas estreitas, "Programação" não cabe em 12px: o
              // `FittedBox` diminui o texto só o necessário, em vez de
              // quebrar a palavra em duas linhas.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: MarcaTexto(
                  aba.nome,
                  ativo: selecionada,
                  estilo: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selecionada ? FontWeight.w700 : FontWeight.w500,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
