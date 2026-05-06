import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/institution_model.dart';
import '../models/user_model.dart';
import '../services/institution_service.dart';

/// Registers a new institution + the initial admin.
///
/// `firstRun: true` is used by the login screen when no institution exists yet.
/// Otherwise, this screen is accessible only via an authenticated admin's
/// menu in `ManageInstitutionsScreen`.
class NewInstitutionScreen extends StatefulWidget {
  final bool firstRun;
  const NewInstitutionScreen({super.key, this.firstRun = false});

  @override
  State<NewInstitutionScreen> createState() => _NewInstitutionScreenState();
}

class _NewInstitutionScreenState extends State<NewInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _instNameCtrl   = TextEditingController();
  final _slugCtrl       = TextEditingController();
  final _adminUserCtrl  = TextEditingController();
  final _adminNameCtrl  = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  final _adminPassCtrl  = TextEditingController();

  bool _saving = false;
  String? _error;
  bool _slugAutoFilled = true;

  @override
  void initState() {
    super.initState();
    _instNameCtrl.addListener(_autoFillSlug);
  }

  void _autoFillSlug() {
    if (!_slugAutoFilled) return;
    _slugCtrl.text = InstitutionModel.slugify(_instNameCtrl.text);
  }

  @override
  void dispose() {
    _instNameCtrl.removeListener(_autoFillSlug);
    _instNameCtrl.dispose();
    _slugCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_adminPassCtrl.text.length < 6) {
      setState(() => _error = l.loginPasswordMin);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final slug = InstitutionModel.slugify(_slugCtrl.text);
    if (slug.isEmpty) {
      setState(() {
        _saving = false;
        _error = l.loginFillAll;
      });
      return;
    }

    final existing = await InstitutionService.get(slug);
    if (!mounted) return;
    if (existing != null) {
      setState(() {
        _saving = false;
        _error = l.loginInstitutionAlreadyExists;
      });
      return;
    }

    final institution = InstitutionModel(
      slug:      slug,
      name:      _instNameCtrl.text.trim(),
      createdBy: _adminUserCtrl.text.trim().toLowerCase(),
      createdAt: DateTime.now(),
    );
    final admin = UserModel(
      institutionSlug: slug,
      username:        _adminUserCtrl.text.trim().toLowerCase(),
      name:            _adminNameCtrl.text.trim(),
      email:           _adminEmailCtrl.text.trim(),
      role:            'admin',
      passwordHash:    UserModel.hashPassword(_adminPassCtrl.text),
      createdAt:       DateTime.now(),
    );

    final ok = await InstitutionService.createWithAdmin(
      institution: institution,
      admin: admin,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _saving = false;
        _error = l.loginCreateError;
      });
      return;
    }
    Navigator.pop(context, institution);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.newInstitutionTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel(l.newInstitutionInstitution),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionInstName,
              hint: l.newInstitutionInstNameHint,
              controller: _instNameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.addDatasetRequired
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionSlug,
              hint: l.newInstitutionSlugHint,
              controller: _slugCtrl,
              onChanged: (_) => _slugAutoFilled = false,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.addDatasetRequired
                  : null,
            ),

            const SizedBox(height: 28),
            _SectionLabel(l.newInstitutionAdminSection),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionAdminUsername,
              hint: l.newInstitutionAdminUsernameHint,
              controller: _adminUserCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.addDatasetRequired
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionAdminFullName,
              hint: l.userFormFullNameHint,
              controller: _adminNameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.addDatasetRequired
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionAdminEmail,
              hint: l.userFormEmailHint,
              controller: _adminEmailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _Field(
              label: l.newInstitutionAdminPassword,
              hint: l.userFormPasswordHintNew,
              controller: _adminPassCtrl,
              isPassword: true,
              validator: (v) => (v == null || v.isEmpty)
                  ? l.addDatasetRequired
                  : null,
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Flexible(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 13))),
              ]),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : Text(l.newInstitutionCreate,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2));
}

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          hintStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.cyanAccent, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
        ),
      );
}
