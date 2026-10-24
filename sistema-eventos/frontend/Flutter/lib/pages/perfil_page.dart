import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/controle_tema.dart';
import '../widgets/avatar_iniciais.dart';
import 'editar_perfil_page.dart';
import 'favoritos_page.dart';
import 'login_page.dart';
import 'organizador_painel_page.dart';

/// Os números do card do Perfil: quantas inscrições e quantas favoritas.
typedef _Numeros = ({int inscricoes, int favoritas});

/// Tela de perfil (aba Perfil da barra de navegação).
///
/// Segue as pranchas "Perfil — participante (RF20, F17)" e "Perfil —
/// organizador (F08)" do canvas, de cima para baixo:
/// - o avatar com as iniciais, o nome e o e-mail (em JetBrains Mono);
/// - um card com quantas inscrições e quantas palestras favoritas a
///   pessoa tem (`GET /api/eventos/<id>/agenda` e
///   `GET /api/favoritos/usuario/<id>`, buscados ao mesmo tempo);
/// - a lista: Favoritos (que saíram da barra de navegação na F20),
///   Certificados ("Em breve" até a F12), o interruptor do modo escuro
///   (F11, RF20), a "Área do organizador" (F08, só para organizadores) e
///   "Sair" (F17), na cor de atenção.
///
/// O nome e o e-mail vêm do login, pelo `AppShell`. "Editar perfil", abaixo
/// do e-mail, abre a tela de edição; ao salvar, o `AppShell` troca o nome
/// e o e-mail em todo o app. O número de certificados, que está na
/// prancha, entra com a F12.
class PerfilPage extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;
  final String emailUsuario;
  final bool ehOrganizador;

  /// Chamado com o nome e o e-mail novos depois que a edição foi salva.
  final void Function(String nome, String email) aoEditarPerfil;

  const PerfilPage({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.ehOrganizador,
    required this.aoEditarPerfil,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late Future<_Numeros> futuro;

  @override
  void initState() {
    super.initState();
    futuro = carregar();
  }

  Future<_Numeros> carregar() async {
    final respostas = await Future.wait([
      ApiService.agenda(widget.usuarioId),
      ApiService.favoritos(widget.usuarioId),
    ]);
    return (inscricoes: respostas[0].length, favoritas: respostas[1].length);
  }

  /// Abre os Favoritos e, ao voltar, conta de novo: a pessoa pode ter
  /// tirado uma palestra dos favoritos lá dentro.
  Future<void> abrirFavoritos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritosPage(usuarioId: widget.usuarioId)),
    );
    if (!mounted) return;
    setState(() {
      futuro = carregar();
    });
  }

  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPerfilPage(
          usuarioId: widget.usuarioId,
          nome: widget.nomeUsuario,
          email: widget.emailUsuario,
          aoSalvar: widget.aoEditarPerfil,
        ),
      ),
    );
  }

  /// Sai da conta (F17): apaga o token e volta para o login.
  /// `pushAndRemoveUntil` tira todas as telas da pilha, então o botão
  /// "voltar" do celular não reabre o app logado.
  void sair() {
    ApiService.sair();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        children: [
          Row(
            children: [
              AvatarIniciais(widget.nomeUsuario, raio: 36, estilo: tema.textTheme.headlineSmall),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.nomeUsuario, style: tema.textTheme.headlineSmall),
                    if (widget.emailUsuario.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.emailUsuario,
                        style: tema.textTheme.labelMedium?.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Link "Editar perfil" da prancha. Sem margem à esquerda,
                    // para alinhar com o nome; 44px de altura para o toque.
                    TextButton(
                      onPressed: abrirEdicao,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 44),
                        textStyle: tema.textTheme.labelLarge?.copyWith(fontSize: 13),
                      ),
                      child: const Text('Editar perfil'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<_Numeros>(
            future: futuro,
            builder: (context, snapshot) {
              // Enquanto carrega (ou se der erro), mostra um traço no lugar
              // do número, para o card não pular de tamanho.
              final numeros = snapshot.data;
              return _CardNumeros(
                inscricoes: numeros?.inscricoes,
                favoritas: numeros?.favoritas,
              );
            },
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: cores.outlineVariant),
          _ItemPerfil(
            icone: Icons.star_border,
            titulo: 'Favoritos',
            aoTocar: abrirFavoritos,
          ),
          // Sem `aoTocar`: a linha aparece apagada, com "Em breve" (F12).
          const _ItemPerfil(icone: Icons.workspace_premium_outlined, titulo: 'Certificados'),
          // Ouve o `ControleTema.modo` para o interruptor acompanhar o tema
          // em uso. Ao tocar, a escolha é aplicada e salva no celular.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ControleTema.modo,
            builder: (context, modo, _) => _ItemPerfil(
              icone: Icons.dark_mode_outlined,
              titulo: 'Modo escuro',
              aDireita: Switch(value: modo == ThemeMode.dark, onChanged: ControleTema.definirEscuro),
              aoTocar: () => ControleTema.definirEscuro(modo != ThemeMode.dark),
            ),
          ),
          // Só aparece para organizadores. Esconder a opção não é a
          // proteção: se um participante chamar as rotas, a API responde 403.
          if (widget.ehOrganizador)
            _ItemPerfil(
              icone: Icons.dashboard_outlined,
              titulo: 'Área do organizador',
              aoTocar: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrganizadorPainelPage()),
              ),
            ),
          // "Sair" na cor de atenção (Brasa), como na prancha, e sem linha
          // embaixo: é o último item.
          _ItemPerfil(
            icone: Icons.logout,
            titulo: 'Sair',
            cor: cores.error,
            comLinha: false,
            semSeta: true,
            aoTocar: sair,
          ),
        ],
      ),
    );
  }
}

/// Card com os números da pessoa, em duas colunas separadas por uma linha
/// fina: o número grande em Bricolage e o nome embaixo.
class _CardNumeros extends StatelessWidget {
  final int? inscricoes;
  final int? favoritas;

  const _CardNumeros({required this.inscricoes, required this.favoritas});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    Widget coluna(int? valor, String um, String varios) {
      final textos = Theme.of(context).textTheme;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor?.toString() ?? '–', style: textos.headlineSmall),
              const SizedBox(height: 2),
              Text(valor == 1 ? um : varios, style: textos.bodySmall),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cores.outlineVariant),
      ),
      // `IntrinsicHeight` deixa a linha do meio com a altura das colunas.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            coluna(inscricoes, 'inscrição', 'inscrições'),
            VerticalDivider(width: 1, color: cores.outlineVariant),
            coluna(favoritas, 'favorita', 'favoritas'),
          ],
        ),
      ),
    );
  }
}

/// Uma linha da lista do Perfil: 56px de altura, ícone na cor principal,
/// o título, e à direita uma seta (ou outro widget, como o interruptor do
/// modo escuro). Linha fina embaixo, menos no último item.
///
/// Sem `aoTocar`, a função ainda não existe: a linha fica apagada, não
/// responde ao toque e mostra "Em breve" no lugar da seta, como os
/// atalhos do Início.
class _ItemPerfil extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback? aoTocar;

  /// Widget no fim da linha, no lugar da seta (ex.: o interruptor).
  final Widget? aDireita;

  /// Cor do ícone e do texto (padrão: principal e texto normal).
  final Color? cor;
  final bool comLinha;
  final bool semSeta;

  const _ItemPerfil({
    required this.icone,
    required this.titulo,
    this.aoTocar,
    this.aDireita,
    this.cor,
    this.comLinha = true,
    this.semSeta = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final ativo = aoTocar != null;
    final corItem = ativo ? cor : cores.onSurfaceVariant;

    return InkWell(
      onTap: aoTocar,
      child: Container(
        height: 56,
        decoration: comLinha ? BoxDecoration(border: Border(bottom: BorderSide(color: cores.outlineVariant))) : null,
        child: Row(children: [
          Icon(icone, color: corItem ?? cores.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              titulo,
              style: textos.bodyLarge?.copyWith(
                fontWeight: cor == null ? FontWeight.w500 : FontWeight.w600,
                color: corItem,
              ),
            ),
          ),
          if (!ativo)
            Text('Em breve', style: textos.bodySmall)
          else if (aDireita != null)
            aDireita!
          else if (!semSeta)
            Icon(Icons.chevron_right, color: cores.onSurfaceVariant),
        ]),
      ),
    );
  }
}
