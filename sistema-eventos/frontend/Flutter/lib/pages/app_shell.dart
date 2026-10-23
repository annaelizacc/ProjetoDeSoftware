import 'package:flutter/material.dart';

import '../widgets/barra_navegacao.dart';
import 'agenda_page.dart';
import 'home_page.dart';
import 'notificacoes_page.dart';
import 'perfil_page.dart';
import 'programacao_aba_page.dart';

/// Casca (shell) do app após o login: contém a barra de navegação inferior
/// e alterna entre as cinco telas principais — Início, Programação,
/// Agenda, Avisos e Perfil — sem perder o estado de cada uma (elas ficam
/// todas construídas, apenas escondidas via índice, o que é suficiente para
/// o tamanho deste app). Os Favoritos saíram da barra na F20 e agora são
/// abertos pelo Perfil, como no canvas.
///
/// Recebe `usuarioId`/`nomeUsuario`/`ehOrganizador` uma única vez (vindos
/// do login) e os repassa para cada tela filha, evitando que cada tela
/// precise refazer a autenticação ou buscar esses dados de novo.
class AppShell extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;

  /// Se a pessoa logada é organizadora (`tipo_usuario` do login). Só
  /// decide o que aparece na tela: quem protege as rotas é o backend.
  final bool ehOrganizador;

  const AppShell({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.ehOrganizador,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int aba = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      HomePage(usuarioId: widget.usuarioId, nomeUsuario: widget.nomeUsuario),
      ProgramacaoAbaPage(usuarioId: widget.usuarioId),
      AgendaPage(usuarioId: widget.usuarioId),
      NotificacoesPage(usuarioId: widget.usuarioId),
      PerfilPage(
        usuarioId: widget.usuarioId,
        nomeUsuario: widget.nomeUsuario,
        ehOrganizador: widget.ehOrganizador,
      ),
    ];
    return Scaffold(
      body: telas[aba],
      // O visual da barra fica no componente compartilhado
      // `widgets/barra_navegacao.dart`; aqui só se decide a tela.
      bottomNavigationBar: BarraNavegacao(
        abaAtual: aba,
        aoTrocarAba: (indice) => setState(() => aba = indice),
      ),
    );
  }
}
