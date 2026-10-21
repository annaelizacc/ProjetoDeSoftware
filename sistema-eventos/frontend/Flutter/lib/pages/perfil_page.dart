import 'package:flutter/material.dart';

import '../theme/controle_tema.dart';
import 'favoritos_page.dart';

/// Tela de perfil do participante (aba Perfil da barra de navegação).
///
/// Segue a prancha "Perfil — participante (RF20, F17)" do canvas. Por
/// enquanto mostra o nome da pessoa, o acesso aos Favoritos (que saíram da
/// barra de navegação na F20) e o interruptor do modo escuro (F11, RF20).
/// Não consome a API: os dados vêm do login, pelo `AppShell`. O botão
/// "Sair" entra na F17, e certificados e estatísticas quando existirem.
class PerfilPage extends StatelessWidget {
  final int usuarioId;
  final String nomeUsuario;

  const PerfilPage({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
  });

  /// Até duas iniciais do nome, para o círculo do avatar ("Ana Silva" → "AS").
  String get _iniciais {
    final partes =
        nomeUsuario.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (partes.isEmpty) return '?';
    final letras = [partes.first, if (partes.length > 1) partes.last]
        // `characters.first` pega a primeira letra "visível", mesmo quando
        // ela ocupa mais de um código no texto (ex.: emoji).
        .map((p) => p.characters.first.toUpperCase());
    return letras.join();
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
              CircleAvatar(
                radius: 36,
                backgroundColor: cores.secondaryContainer,
                foregroundColor: cores.onSecondaryContainer,
                child: Text(
                  _iniciais,
                  style: tema.textTheme.headlineSmall
                      ?.copyWith(color: cores.onSecondaryContainer),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(nomeUsuario, style: tema.textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
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
        ],
      ),
    );
  }
}
