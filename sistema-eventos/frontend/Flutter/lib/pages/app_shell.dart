import 'package:flutter/material.dart';

import '../services/lembrete_service.dart';
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

  /// E-mail da conta, mostrado no Perfil. Vem do login, como o nome.
  final String emailUsuario;

  /// Se a pessoa logada é organizadora (`tipo_usuario` do login). Só
  /// decide o que aparece na tela: quem protege as rotas é o backend.
  final bool ehOrganizador;

  const AppShell({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.ehOrganizador,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int aba = 0;

  /// Evento escolhido no Início (tela Escolher evento), usado também pela aba
  /// Programação. Fica aqui porque as telas são montadas de novo a cada
  /// troca de aba.
  int? eventoInicio;

  /// Nome e e-mail mostrados no app. Começam com os do login e mudam
  /// quando a pessoa salva em "Editar perfil", sem precisar entrar de novo.
  late String nome = widget.nomeUsuario;
  late String email = widget.emailUsuario;

  /// Logo depois do login, refaz os avisos de início das palestras no
  /// celular a partir dos lembretes ativos (F02).
  @override
  void initState() {
    super.initState();
    LembreteService.sincronizar(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      HomePage(
        usuarioId: widget.usuarioId,
        nomeUsuario: nome,
        // "Ver agenda" do Início troca para a aba Agenda (índice 2).
        aoVerAgenda: () => setState(() => aba = 2),
        eventoId: eventoInicio,
        aoTrocarEvento: (id) => setState(() => eventoInicio = id),
      ),
      ProgramacaoAbaPage(usuarioId: widget.usuarioId, eventoId: eventoInicio),
      AgendaPage(usuarioId: widget.usuarioId),
      NotificacoesPage(usuarioId: widget.usuarioId),
      PerfilPage(
        usuarioId: widget.usuarioId,
        nomeUsuario: nome,
        emailUsuario: email,
        ehOrganizador: widget.ehOrganizador,
        aoEditarPerfil: (novoNome, novoEmail) => setState(() {
          nome = novoNome;
          email = novoEmail;
        }),
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
