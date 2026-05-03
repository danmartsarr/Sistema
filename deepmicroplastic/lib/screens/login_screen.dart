import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'ftir_overview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _checkingDb = true;
  bool _firstRun = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final hasUsers = await AuthService.hasAnyUser();
    if (!mounted) return;
    setState(() {
      _firstRun = !hasUsers;
      _checkingDb = false;
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Preencha usuário e senha.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final user = await AuthService.login(username, password);
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Usuário ou senha incorretos.';
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => FtirOverviewScreen(loggedUser: user)),
    );
  }

  Future<void> _createFirstAdmin() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Preencha usuário e senha para o admin.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMsg = 'Senha deve ter ao menos 6 caracteres.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final admin = UserModel(
      username: username,
      name: 'Administrador',
      email: '',
      institution: '',
      role: 'admin',
      passwordHash: UserModel.hashPassword(password),
      createdAt: DateTime.now(),
    );
    final ok = await AuthService.createUser(admin);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Erro ao criar conta. Verifique a conexão.';
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => FtirOverviewScreen(loggedUser: admin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020818),
                  Color(0xFF041830),
                  Color(0xFF062040),
                  Color(0xFF041830),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.cyanAccent.withValues(alpha: 0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -120, right: -80,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.blueAccent.withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Center(
            child: _checkingDb
                ? const CircularProgressIndicator(color: Colors.cyanAccent)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B35),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 40,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.cyanAccent.withValues(alpha: 0.1),
                              border: Border.all(
                                color:
                                    Colors.cyanAccent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(Icons.water_drop,
                                color: Colors.cyanAccent, size: 40),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'RAVI SYSTEM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AcronymLabel(),
                          const SizedBox(height: 6),
                          const Text(
                            'Identificação de Microplásticos por FTIR',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),

                          if (_firstRun) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    Colors.amberAccent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amberAccent
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(children: [
                                Icon(Icons.admin_panel_settings,
                                    color: Colors.amberAccent
                                        .withValues(alpha: 0.8),
                                    size: 18),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Primeira execução — crie o usuário administrador.',
                                    style: TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 12),
                                  ),
                                ),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 32),

                          _buildTextField(
                            controller: _userCtrl,
                            icon: Icons.person_outline,
                            label: 'Usuário',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passCtrl,
                            icon: Icons.lock_outline,
                            label: 'Senha',
                            isPassword: true,
                          ),

                          if (_errorMsg != null) ...[
                            const SizedBox(height: 14),
                            Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(_errorMsg!,
                                    style: const TextStyle(
                                        color: Colors.redAccent, fontSize: 13)),
                              ),
                            ]),
                          ],

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 8,
                                shadowColor:
                                    Colors.cyanAccent.withValues(alpha: 0.4),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : (_firstRun ? _createFirstAdmin : _login),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.black, strokeWidth: 2),
                                    )
                                  : Text(
                                      _firstRun
                                          ? 'CRIAR CONTA ADMIN'
                                          : 'ENTRAR',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      onFieldSubmitted: (_) =>
          _firstRun ? _createFirstAdmin() : _login(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
    );
  }
}

class _AcronymLabel extends StatelessWidget {
  static const _parts = [
    ('R', 'econhecimento'),
    ('A', 'utomatizado'),
    ('V', 'ia'),
    ('I', 'nfravermelho'),
  ];

  const _AcronymLabel();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: _parts
          .map((p) => RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: p.$1,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: p.$2,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ]),
              ))
          .toList(),
    );
  }
}
