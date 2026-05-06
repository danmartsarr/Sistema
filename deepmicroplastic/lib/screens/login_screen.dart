import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/institution_model.dart';
import '../services/auth_service.dart';
import '../services/institution_service.dart';
import '../widgets/language_menu.dart';
import 'ftir_overview_screen.dart';
import 'new_institution_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Stage { loading, firstRun, askInstitution, askCredentials }

class _LoginScreenState extends State<LoginScreen> {
  final _instCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  _Stage _stage = _Stage.loading;
  InstitutionModel? _institution;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final any = await InstitutionService.hasAny();
    if (!mounted) return;
    setState(() => _stage = any ? _Stage.askInstitution : _Stage.firstRun);
  }

  @override
  void dispose() {
    _instCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkInstitution() async {
    final l = AppLocalizations.of(context);
    final slug = InstitutionModel.slugify(_instCtrl.text);
    if (slug.isEmpty) {
      setState(() => _error = l.loginFillAll);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final inst = await InstitutionService.get(slug);
    if (!mounted) return;
    if (inst == null) {
      setState(() {
        _busy = false;
        _error = l.loginInstitutionNotFound;
      });
      return;
    }
    setState(() {
      _busy = false;
      _institution = inst;
      _stage = _Stage.askCredentials;
    });
  }

  Future<void> _login() async {
    final l = AppLocalizations.of(context);
    final inst = _institution;
    if (inst == null) return;
    final username = _userCtrl.text.trim().toLowerCase();
    final password = _passCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = l.loginFillAll);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final user = await AuthService.login(inst.slug, username, password);
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _busy = false;
        _error = l.loginUserNotFound;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => FtirOverviewScreen(loggedUser: user)),
    );
  }

  Future<void> _openNewInstitution() async {
    final l = AppLocalizations.of(context);
    final created = await Navigator.push<InstitutionModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewInstitutionScreen(firstRun: true),
      ),
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.newInstitutionSuccess(created.name)),
        backgroundColor: Colors.greenAccent.withValues(alpha: 0.9),
      ));
      setState(() {
        _instCtrl.text = created.slug;
        _stage = _Stage.askInstitution;
      });
    }
  }

  void _backToInstitution() => setState(() {
        _stage = _Stage.askInstitution;
        _institution = null;
        _userCtrl.clear();
        _passCtrl.clear();
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Faded background image
          Image.asset('assets/login_bg.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF020818).withValues(alpha: 0.88),
                  const Color(0xFF041830).withValues(alpha: 0.82),
                  const Color(0xFF062040).withValues(alpha: 0.82),
                  const Color(0xFF041830).withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
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
          // Language menu
          Positioned(
            top: 12, right: 12,
            child: SafeArea(child: const LanguageMenu()),
          ),

          Center(
            child: _stage == _Stage.loading
                ? const CircularProgressIndicator(color: Colors.cyanAccent)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B35).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 40,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LogoBlock(localizations: l),
                            const SizedBox(height: 30),
                            ..._buildStageContent(l),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStageContent(AppLocalizations l) {
    if (_stage == _Stage.firstRun) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amberAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.admin_panel_settings,
                color: Colors.amberAccent.withValues(alpha: 0.85), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l.loginFirstRunBanner,
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: _primaryBtnStyle(),
            onPressed: _busy ? null : _openNewInstitution,
            child: Text(l.loginCreateFirstAdmin,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          ),
        ),
      ];
    }

    if (_stage == _Stage.askInstitution) {
      return [
        _Field(
          controller: _instCtrl,
          icon: Icons.account_balance_outlined,
          label: l.loginInstitution,
          hint: l.loginInstitutionHint,
          onSubmit: _checkInstitution,
        ),
        if (_error != null) _ErrorBox(message: _error!),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: _primaryBtnStyle(),
            onPressed: _busy ? null : _checkInstitution,
            child: _busy
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2))
                : Text(l.loginInstitutionContinue,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8)),
          ),
        ),
      ];
    }

    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.account_balance_outlined,
              color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_institution?.name ?? '',
                style: const TextStyle(
                    color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: _busy ? null : _backToInstitution,
            child: Text(l.loginChangeInstitution,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ),
        ]),
      ),
      const SizedBox(height: 18),
      _Field(
        controller: _userCtrl,
        icon: Icons.person_outline,
        label: l.loginUsername,
        onSubmit: _login,
      ),
      const SizedBox(height: 14),
      _Field(
        controller: _passCtrl,
        icon: Icons.lock_outline,
        label: l.loginPassword,
        isPassword: true,
        onSubmit: _login,
      ),
      if (_error != null) _ErrorBox(message: _error!),
      const SizedBox(height: 22),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: _primaryBtnStyle(),
          onPressed: _busy ? null : _login,
          child: _busy
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2))
              : Text(l.loginEnter,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
        ),
      ),
    ];
  }

  ButtonStyle _primaryBtnStyle() => ElevatedButton.styleFrom(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
      );
}

class _LogoBlock extends StatelessWidget {
  final AppLocalizations localizations;
  const _LogoBlock({required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.cyanAccent.withValues(alpha: 0.1),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
        ),
        child: const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 40),
      ),
      const SizedBox(height: 22),
      const Text(
        'RAVI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
        ),
      ),
      const SizedBox(height: 10),
      _AcronymLabel(localizations: localizations),
      const SizedBox(height: 6),
      Text(
        localizations.appTagline,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    ]);
  }
}

class _AcronymLabel extends StatelessWidget {
  final AppLocalizations localizations;
  const _AcronymLabel({required this.localizations});

  @override
  Widget build(BuildContext context) {
    final parts = [
      ('R', localizations.appAcronymR),
      ('A', localizations.appAcronymA),
      ('V', localizations.appAcronymV),
      ('I', localizations.appAcronymI),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: parts
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String? hint;
  final bool isPassword;
  final VoidCallback onSubmit;

  const _Field({
    required this.controller,
    required this.icon,
    required this.label,
    this.hint,
    this.isPassword = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      onFieldSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
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

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ),
      ]),
    );
  }
}
