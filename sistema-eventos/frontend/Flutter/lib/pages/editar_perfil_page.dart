import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/formulario_organizador.dart';

/// Tela "Editar perfil", aberta pelo link abaixo do e-mail no Perfil.
///
/// Deixa a pessoa trocar o nome e o e-mail da própria conta
/// (`PUT /api/usuarios/<id>`, `ApiService.atualizarPerfil`). Usa o mesmo
/// molde dos formulários do organizador (`FormularioOrganizador`): campos
/// no meio e a barra fixa com "Cancelar" e "Salvar".
///
/// O backend confere tudo de novo: só a própria pessoa altera a conta, só
/// nome, e-mail e senha são aceitos (P01) e cada campo passa pelas
/// validações do cadastro. Ainda falta tratar o e-mail que já é de outra
/// conta, que hoje volta como erro genérico (F26, junto da P03). Trocar a
/// senha também fica para a F26.
///
/// Ao salvar, chama `aoSalvar` com os valores novos (o `AppShell` troca o
/// nome e o e-mail no app inteiro) e fecha a tela.
class EditarPerfilPage extends StatefulWidget {
  final int usuarioId;
  final String nome;
  final String email;
  final void Function(String nome, String email) aoSalvar;

  const EditarPerfilPage({
    super.key,
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.aoSalvar,
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late final nome = TextEditingController(text: widget.nome);
  late final email = TextEditingController(text: widget.email);
  bool salvando = false;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    super.dispose();
  }

  void salvar() {
    final novoNome = nome.text.trim();
    final novoEmail = email.text.trim();
    executarEFechar(context, (valor) => setState(() => salvando = valor), () async {
      await ApiService.atualizarPerfil(widget.usuarioId, novoNome, novoEmail);
      widget.aoSalvar(novoNome, novoEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormularioOrganizador(
      titulo: 'Editar perfil',
      secao: 'Perfil · sua conta',
      textoBotao: 'Salvar',
      salvando: salvando,
      aoSalvar: salvar,
      campos: [
        CampoFormulario(rotulo: 'Nome', controller: nome, dica: 'Seu nome completo'),
        CampoFormulario(
          rotulo: 'E-mail',
          controller: email,
          dica: 'seu@email.com',
          teclado: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
