import 'package:flutter/material.dart';

import 'agenda_page.dart';
import 'favoritos_page.dart';
import 'home_page.dart';
import 'notificacoes_page.dart';

/// Casca (shell) do app após o login: contém a barra de navegação inferior
/// e alterna entre as quatro telas principais — Início, Agenda, Favoritos
/// e Avisos — sem perder o estado de cada uma (elas ficam todas
/// construídas, apenas escondidas via índice, o que é suficiente para o
/// tamanho deste app).
///
/// Recebe `usuarioId`/`nomeUsuario` uma única vez (vindos do login) e os
/// repassa para cada tela filha, evitando que cada tela precise refazer a
/// autenticação ou buscar esses dados de novo.
class AppShell extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;

  const AppShell({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
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
      AgendaPage(usuarioId: widget.usuarioId),
      FavoritosPage(usuarioId: widget.usuarioId),
      NotificacoesPage(usuarioId: widget.usuarioId),
    ];
    return Scaffold(
      body: telas[aba],
      // As cores/tipografia da barra vêm do NavigationBarTheme centralizado
      // em `theme/app_theme.dart` — nada de estilo é definido aqui.
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba,
        onDestinationSelected: (index) => setState(() => aba = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Avisos',
          ),
        ],
      ),
    );
  }
}
