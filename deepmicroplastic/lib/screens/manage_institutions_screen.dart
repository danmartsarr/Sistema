import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/institution_model.dart';
import '../models/user_model.dart';
import '../services/institution_service.dart';
import 'new_institution_screen.dart';

class ManageInstitutionsScreen extends StatefulWidget {
  final UserModel loggedUser;
  const ManageInstitutionsScreen({super.key, required this.loggedUser});

  @override
  State<ManageInstitutionsScreen> createState() =>
      _ManageInstitutionsScreenState();
}

class _ManageInstitutionsScreenState extends State<ManageInstitutionsScreen> {
  List<InstitutionModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await InstitutionService.listAll();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(InstitutionModel inst) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.manageInstitutionsRemoveTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l.manageInstitutionsRemoveBody(inst.name),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.actionCancel,
                  style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionRemove,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await InstitutionService.delete(inst.slug);
    _load();
  }

  Future<void> _create() async {
    final created = await Navigator.push<InstitutionModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewInstitutionScreen(firstRun: false),
      ),
    );
    if (created != null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = widget.loggedUser.isAdmin;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.manageInstitutionsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_business_outlined),
              label: Text(l.manageInstitutionsNew,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _create,
            )
          : null,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent))
          : RefreshIndicator(
              onRefresh: _load,
              color: Colors.cyanAccent,
              backgroundColor: const Color(0xFF111827),
              child: _items.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 80),
                      Center(
                          child: Text(l.manageInstitutionsEmpty,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4)))),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _Card(
                        institution: _items[i],
                        canDelete: isAdmin &&
                            _items[i].slug != widget.loggedUser.institutionSlug,
                        onDelete: () => _confirmDelete(_items[i]),
                      ),
                    ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  final InstitutionModel institution;
  final bool canDelete;
  final VoidCallback onDelete;
  const _Card({
    required this.institution,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.account_balance_outlined,
              color: Colors.cyanAccent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(institution.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text('@${institution.slug}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            const SizedBox(height: 4),
            Text(l.manageInstitutionsCreatedAt(_fmt(institution.createdAt)),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11)),
          ]),
        ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
      ]),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
