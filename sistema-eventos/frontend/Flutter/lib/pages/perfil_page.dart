import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/controle_tema.dart';
import '../widgets/avatar_iniciais.dart';
import 'favoritos_page.dart';
import 'login_page.dart';
import 'organizador_painel_page.dart';

/// Tela de perfil (aba Perfil da barra de navegação).
///
/// Segue as pranchas "Perfil — participante (RF20, F17)" e "Perfil —
/// organizador (F08)" do canvas. Por enquanto mostra o nome da pessoa, o
/// acesso aos Favoritos (que saíram da barra de navegação na F20), a
/// "Área do organizador" (F08, só para organizadores), o interruptor do
/// modo escuro (F11, RF20) e o botão "Sair" (F17).
/// Não consome a API: os dados vêm do login, pelo `AppShell`. Certificados
/// e estatísticas entram quando existirem.
class PerfilPage extends StatelessWidget {
  final int usuarioId;
  final String nomeUsuario;
  final bool ehOrganizador;

  const PerfilPage({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.ehOrganizador,
  });

  /// Sai da conta (F17): apaga o token e volta para o login.
  /// `pushAndRemoveUntil` tira todas as telas da pilha, então o botão
  /// "voltar" do celular não reabre o app logado.
  void sair(BuildContext context) {
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
              AvatarIniciais(nomeUsuario,
                  raio: 36, estilo: tema.textTheme.headlineSmall),
              const SizedBox(width: 16),
              Expanded(
                child: Text(nomeUsuario, style: tema.textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          // Só aparece para organizadores. Esconder a opção não é a
          // proteção: se um participante chamar as rotas, a API responde 403.
          if (ehOrganizador) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.dashboard_outlined, color: cores.primary),
              title: const Text('Área do organizador'),
              subtitle: const Text('Painel do evento e inscrições'),
              trailing:
                  Icon(Icons.chevron_right, color: cores.onSurfaceVariant),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OrganizadorPainelPage()),
              ),
            ),
            const Divider(),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.star_border, color: cores.primary),
            title: const Text('Favoritos'),
            trailing: Icon(Icons.chevron_right, color: cores.onSurfaceVariant),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritosPage(usuarioId: usuarioId),
              ),
            ),
          ),
          const Divider(),
          // Ouve o `ControleTema.modo` para o interruptor acompanhar o tema
          // em uso. Ao tocar, a escolha é aplicada e salva no celular.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ControleTema.modo,
            builder: (context, modo, _) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.dark_mode_outlined, color: cores.primary),
              title: const Text('Modo escuro'),
              value: modo == ThemeMode.dark,
              onChanged: ControleTema.definirEscuro,
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout, color: cores.primary),
            title: const Text('Sair'),
            onTap: () => sair(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
