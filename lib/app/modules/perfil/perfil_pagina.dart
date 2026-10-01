import 'package:flutter/material.dart';
import '../../core/theme/tema_app.dart';
import '../../data/repositories/usuario_repository.dart';
import '../home/pagina_inicial.dart';

class PerfilPagina extends StatefulWidget {
  final String? nomeInicial;
  final String? emailInicial;
  final String? cpfInicial;

  const PerfilPagina({
    super.key,
    this.nomeInicial,
    this.emailInicial,
    this.cpfInicial,
  });

  @override
  State<PerfilPagina> createState() => _PerfilPaginaState();
}

class _PerfilPaginaState extends State<PerfilPagina> {
  final _chaveFormulario = GlobalKey<FormState>();

  late TextEditingController _controleNome;
  late TextEditingController _controleEmail;
  late TextEditingController _controleCpf;
  late TextEditingController _controleTelefone;

  bool _notificacoesAtivas = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final usuarioAtual = UsuarioRepository.instance.value;

    // Prioriza os dados do UsuarioRepository, se estiverem vazios usa os parametros passados no cadastro
    _controleNome = TextEditingController(
      text: usuarioAtual.nome.isNotEmpty ? usuarioAtual.nome : (widget.nomeInicial ?? ''),
    );
    _controleEmail = TextEditingController(
      text: usuarioAtual.email.isNotEmpty ? usuarioAtual.email : (widget.emailInicial ?? ''),
    );
    _controleCpf = TextEditingController(
      text: usuarioAtual.cpf.isNotEmpty ? usuarioAtual.cpf : (widget.cpfInicial ?? ''),
    );
    _controleTelefone = TextEditingController(
      text: usuarioAtual.telefone,
    );
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleEmail.dispose();
    _controleCpf.dispose();
    _controleTelefone.dispose();
    super.dispose();
  }

  void _salvarPerfil() async {
    if (_chaveFormulario.currentState!.validate()) {
      setState(() => _salvando = true);

      await Future.delayed(const Duration(milliseconds: 500));

      // Salva globalmente no repositorio
      UsuarioRepository.instance.atualizarPerfil(
        nome: _controleNome.text.trim(),
        email: _controleEmail.text.trim(),
        cpf: _controleCpf.text.trim(),
        telefone: _controleTelefone.text.trim(),
      );

      if (mounted) {
        setState(() => _salvando = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Se veio do fluxo de cadastro (fora do BottomNavigationBar), navega para a Home
        if (Navigator.canPop(context)) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const PaginaInicial(),
            ),
                (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TemaApp.corFundo,
              Color(0xFF8BA5C2),
              Color(0xFF325983),
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Meu Perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: TemaApp.corBotao,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete suas informações para personalizar seu uso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white12,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Avatar / Foto de Perfil
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TemaApp.corBotao,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt, size: 18, color: TemaApp.corBotao),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Alterar foto em breve!')),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo Nome
                  _campoTexto(
                    controller: _controleNome,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo E-mail
                  _campoTexto(
                    controller: _controleEmail,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo CPF
                  _campoTexto(
                    controller: _controleCpf,
                    label: 'CPF',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Campo Telefone / WhatsApp
                  _campoTexto(
                    controller: _controleTelefone,
                    label: 'Telefone / WhatsApp',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Opções de Preferência
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.white,
                      activeTrackColor: TemaApp.corBotao,
                      title: const Text(
                        'Receber alertas de vencimento',
                        style: TextStyle(
                          color: TemaApp.corBotao,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Notificações no app e lembretes',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      value: _notificacoesAtivas,
                      onChanged: (val) {
                        setState(() => _notificacoesAtivas = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Botão Salvar
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemaApp.corBotao,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 4,
                      ),
                      child: _salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'SALVAR PERFIL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: TemaApp.corBotao),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TemaApp.corBotao),
        prefixIcon: Icon(icon, color: TemaApp.corBotao),
        filled: false,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: TemaApp.corBotao),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: TemaApp.corBotao),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}