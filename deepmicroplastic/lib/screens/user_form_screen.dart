import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserFormScreen extends StatefulWidget {
  final String institutionSlug;
  final UserModel? existing;
  const UserFormScreen({
    super.key,
    required this.institutionSlug,
    this.existing,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _pass2Ctrl;

  String _role = 'researcher';
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _usernameCtrl = TextEditingController(text: e?.username ?? '');
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _departmentCtrl = TextEditingController(text: e?.department ?? '');
    _passCtrl = TextEditingController();
    _pass2Ctrl = TextEditingController();
    _role = e?.role ?? 'researcher';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _departmentCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing) {
      if (_passCtrl.text.length < 6) {
        setState(() => _error = l.userFormPasswordTooShort);
        return;
      }
      if (_passCtrl.text != _pass2Ctrl.text) {
        setState(() => _error = l.userFormPasswordsMismatch);
        return;
      }
    } else if (_passCtrl.text.isNotEmpty) {
      if (_passCtrl.text.length < 6) {
        setState(() => _error = l.userFormPasswordTooShort);
        return;
      }
      if (_passCtrl.text != _pass2Ctrl.text) {
        setState(() => _error = l.userFormPasswordsMismatch);
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    bool ok;
    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        department: _departmentCtrl.text.trim(),
        role: _role,
      );
      ok = await AuthService.updateUser(updated);
      if (ok && _passCtrl.text.isNotEmpty) {
        await AuthService.changePassword(
            widget.institutionSlug, updated.username, _passCtrl.text);
      }
    } else {
      final username = _usernameCtrl.text.trim().toLowerCase();
      final exists = await AuthService.usernameExists(
          widget.institutionSlug, username);
      if (exists) {
        setState(() {
          _saving = false;
          _error = l.userFormUsernameTaken;
        });
        return;
      }
      final user = UserModel(
        institutionSlug: widget.institutionSlug,
        username: username,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        department: _departmentCtrl.text.trim(),
        role: _role,
        passwordHash: UserModel.hashPassword(_passCtrl.text),
        createdAt: DateTime.now(),
      );
      ok = await AuthService.createUser(user);
    }

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _saving = false;
        _error = l.userFormSaveError;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? l.userFormTitleEdit : l.userFormTitleNew,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel(l.userFormSectionId),
            const SizedBox(height: 14),

            if (!_isEditing) ...[
              _Field(
                l.userFormUsername,
                _usernameCtrl,
                hint: l.userFormUsernameHint,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.addDatasetRequired : null,
              ),
              const SizedBox(height: 14),
            ],

            _Field(
              l.userFormFullName,
              _nameCtrl,
              hint: l.userFormFullNameHint,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.addDatasetRequired : null,
            ),
            const SizedBox(height: 14),
            _Field(l.userFormEmail, _emailCtrl,
                hint: l.userFormEmailHint,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _Field(l.userFormDepartment, _departmentCtrl,
                hint: l.userFormDepartmentHint),

            const SizedBox(height: 28),
            _SectionLabel(l.userFormSectionRole),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _RoleChip(
                  label: l.userFormRoleResearcher,
                  icon: Icons.science_outlined,
                  selected: _role == 'researcher',
                  onTap: () => setState(() => _role = 'researcher'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleChip(
                  label: l.userFormRoleAdmin,
                  icon: Icons.admin_panel_settings_outlined,
                  selected: _role == 'admin',
                  onTap: () => setState(() => _role = 'admin'),
                ),
              ),
            ]),

            const SizedBox(height: 28),
            _SectionLabel(_isEditing
                ? l.userFormSectionPasswordEdit
                : l.userFormSectionPasswordNew),
            const SizedBox(height: 14),
            _Field(
              l.userFormPassword,
              _passCtrl,
              hint: _isEditing
                  ? l.userFormPasswordHintEdit
                  : l.userFormPasswordHintNew,
              isPassword: true,
              validator: _isEditing
                  ? null
                  : (v) => (v == null || v.isEmpty)
                      ? l.addDatasetRequired : null,
            ),
            const SizedBox(height: 14),
            _Field(
              l.userFormPasswordConfirm,
              _pass2Ctrl,
              hint: l.userFormPasswordConfirmHint,
              isPassword: true,
              validator: _isEditing
                  ? null
                  : (v) => (v == null || v.isEmpty)
                      ? l.addDatasetRequired : null,
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
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Text(
                        _isEditing
                            ? l.userFormSaveBtnEdit
                            : l.userFormSaveBtnNew,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8),
                      ),
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
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  const _Field(this.label, this.controller,
      {this.hint,
      this.keyboardType,
      this.isPassword = false,
      this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        keyboardType: keyboardType,
        maxLines: isPassword ? 1 : null,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          hintText: hint,
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
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
        ),
      );
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? Colors.cyanAccent.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.cyanAccent.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: selected ? Colors.cyanAccent : Colors.white38,
                size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  color: selected ? Colors.cyanAccent : Colors.white54,
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                )),
          ]),
        ),
      );
}
