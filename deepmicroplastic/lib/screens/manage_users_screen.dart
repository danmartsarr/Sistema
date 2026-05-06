import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'user_form_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  final UserModel loggedUser;
  const ManageUsersScreen({super.key, required this.loggedUser});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> _users = [];
  bool _loading = true;

  String get _slug => widget.loggedUser.institutionSlug;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await AuthService.listUsers(_slug);
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _deleteUser(UserModel user) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.manageUsersRemoveTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l.manageUsersRemoveBody(user.displayName),
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
    await AuthService.deleteUser(_slug, user.username);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.manageUsersTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l.manageUsersNew,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    UserFormScreen(institutionSlug: _slug)),
          );
          if (created == true) _load();
        },
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent))
          : RefreshIndicator(
              onRefresh: _load,
              color: Colors.cyanAccent,
              backgroundColor: const Color(0xFF111827),
              child: _users.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(l.manageUsersEmpty,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4))),
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: _users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final user = _users[i];
                        final isSelf =
                            user.username == widget.loggedUser.username;
                        return _UserCard(
                          user: user,
                          isSelf: isSelf,
                          onEdit: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UserFormScreen(
                                        institutionSlug: _slug,
                                        existing: user,
                                      )),
                            );
                            if (updated == true) _load();
                          },
                          onDelete: isSelf ? null : () => _deleteUser(user),
                        );
                      },
                    ),
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  const _UserCard(
      {required this.user,
      required this.isSelf,
      required this.onEdit,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final roleColor =
        user.isAdmin ? Colors.amberAccent : Colors.cyanAccent;
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
            color: roleColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: roleColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: roleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(user.displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              if (isSelf) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(l.manageUsersYou,
                      style: const TextStyle(
                          color: Colors.greenAccent, fontSize: 10)),
                ),
              ],
            ]),
            const SizedBox(height: 3),
            Text('@${user.username}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: roleColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                user.isAdmin ? l.manageUsersRoleAdmin : l.manageUsersRoleResearcher,
                style: TextStyle(
                    color: roleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.cyanAccent, size: 20),
            tooltip: l.manageUsersTooltipEdit,
            onPressed: onEdit,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              tooltip: l.manageUsersTooltipRemove,
              onPressed: onDelete,
            ),
        ]),
      ]),
    );
  }
}
