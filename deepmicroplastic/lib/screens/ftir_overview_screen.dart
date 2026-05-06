import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/dataset_service.dart';
import '../services/sample_service.dart';
import 'add_dataset_screen.dart';
import 'dataset_detail_screen.dart';
import 'login_screen.dart';
import 'manage_institutions_screen.dart';
import 'manage_users_screen.dart';

class FtirOverviewScreen extends StatefulWidget {
  final UserModel loggedUser;
  const FtirOverviewScreen({super.key, required this.loggedUser});

  @override
  State<FtirOverviewScreen> createState() => _FtirOverviewScreenState();
}

class _FtirOverviewScreenState extends State<FtirOverviewScreen> {
  List<SpectrumDataset> _datasets = [];
  bool _loading = true;
  String? _error;

  String get _slug => widget.loggedUser.institutionSlug;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final datasets = await DatasetService.loadAll(_slug);
      // Carrega contagens de amostras (para os KPIs e cards) — sem espectro,
      // só metadados.
      for (final ds in datasets) {
        final samples = await SampleService.loadForDataset(_slug, ds.id);
        ds.samples
          ..clear()
          ..addAll(samples);
      }
      if (!mounted) return;
      setState(() {
        _datasets = datasets;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (mounted) {
          _error = AppLocalizations.of(context).homeLoadError;
        }
        _loading = false;
      });
    }
  }

  void _onMenuSelected(String value) async {
    if (value == 'users') {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ManageUsersScreen(loggedUser: widget.loggedUser)),
      );
    } else if (value == 'institutions') {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ManageInstitutionsScreen(loggedUser: widget.loggedUser)),
      );
    } else if (value == 'logout') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else if (value.startsWith('lang:')) {
      final code = value.split(':').last;
      await localeService.setLocale(Locale(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final allSamples = _datasets.expand((d) => d.samples).toList();
    final analyzed = allSamples.where((s) => s.result != null).toList();
    final dist = <PolymerType, int>{};
    for (final s in analyzed) {
      dist[s.result!.polymer] = (dist[s.result!.polymer] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.homeTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: Colors.greenAccent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(widget.loggedUser.displayName,
                  style: const TextStyle(
                      color: Colors.greenAccent, fontSize: 12)),
            ]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF111827),
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              if (widget.loggedUser.isAdmin)
                PopupMenuItem(
                  value: 'users',
                  child: Row(children: [
                    const Icon(Icons.people_outline,
                        color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(l.homeMenuUsers,
                        style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              if (widget.loggedUser.isAdmin)
                PopupMenuItem(
                  value: 'institutions',
                  child: Row(children: [
                    const Icon(Icons.account_balance_outlined,
                        color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(l.homeMenuInstitutions,
                        style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              PopupMenuItem(
                enabled: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.language,
                        color: Colors.white38, size: 16),
                    const SizedBox(width: 8),
                    Text(l.homeMenuLanguage,
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ]),
                ),
              ),
              _langItem('en', l.languageEnglish),
              _langItem('pt', l.languagePortuguese),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout, color: Colors.white54, size: 18),
                  const SizedBox(width: 10),
                  Text(l.homeMenuLogout,
                      style: const TextStyle(color: Colors.white54)),
                ]),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l.homeNewCollection,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final newDataset = await Navigator.push<SpectrumDataset>(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AddDatasetScreen(loggedUser: widget.loggedUser)),
          );
          if (newDataset != null) {
            // Recarrega completo do Firebase para garantir consistência
            // (em vez de só inserir em memória).
            await _loadDatasets();
          }
        },
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadDatasets)
              : RefreshIndicator(
                  onRefresh: _loadDatasets,
                  color: Colors.cyanAccent,
                  backgroundColor: const Color(0xFF111827),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: _KpiCard(
                            label: l.homeKpiTotalSamples,
                            value: '${allSamples.length}',
                            icon: Icons.biotech,
                            color: Colors.cyanAccent,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _KpiCard(
                            label: l.homeKpiCollections,
                            value: '${_datasets.length}',
                            icon: Icons.folder_special,
                            color: Colors.orangeAccent,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _KpiCard(
                            label: l.homeKpiVerified,
                            value: '${allSamples.where((s) => s.isVerified).length}',
                            icon: Icons.verified,
                            color: Colors.greenAccent,
                          )),
                        ]),
                        const SizedBox(height: 28),
                        if (dist.isNotEmpty) ...[
                          _SectionTitle(l.homePolymerDistribution),
                          const SizedBox(height: 14),
                          _GlassCard(
                            child: Column(
                              children: dist.entries.map((e) {
                                final pct = e.value / analyzed.length;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _PolymerBar(
                                    polymer: e.key,
                                    count: e.value,
                                    total: analyzed.length,
                                    fraction: pct,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                        _SectionTitle(l.homeRegisteredCollections),
                        const SizedBox(height: 14),
                        if (_datasets.isEmpty)
                          _GlassCard(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              child: Column(children: [
                                Icon(Icons.folder_open_outlined,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  l.homeNoCollections,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      fontSize: 13,
                                      height: 1.5),
                                ),
                              ]),
                            ),
                          )
                        else
                          ..._datasets.map((ds) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _DatasetCard(
                                  dataset: ds,
                                  loggedUser: widget.loggedUser,
                                  onUpdate: _loadDatasets,
                                  onDelete: () async {
                                    await DatasetService.delete(_slug, ds.id);
                                    _loadDatasets();
                                  },
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }

  PopupMenuItem<String> _langItem(String code, String label) {
    final selected = localeService.locale.languageCode == code;
    return PopupMenuItem(
      value: 'lang:$code',
      child: Row(children: [
        Icon(selected ? Icons.check_circle : Icons.circle_outlined,
            size: 16, color: selected ? Colors.cyanAccent : Colors.white38),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
        const SizedBox(height: 16),
        Text(message,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l.homeRetry),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1));
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: child,
      );
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        ]),
      );
}

class _PolymerBar extends StatelessWidget {
  final PolymerType polymer;
  final int count;
  final int total;
  final double fraction;
  const _PolymerBar(
      {required this.polymer,
      required this.count,
      required this.total,
      required this.fraction});
  @override
  Widget build(BuildContext context) {
    final color = polymer.color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(polymer.fullName,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
        Text('$count/$total  (${(fraction * 100).toStringAsFixed(0)}%)',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 7),
      Stack(children: [
        Container(
            height: 8,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4))),
        FractionallySizedBox(
          widthFactor: fraction,
          child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.5), blurRadius: 6)
                ],
              )),
        ),
      ]),
    ]);
  }
}

class _DatasetCard extends StatelessWidget {
  final SpectrumDataset dataset;
  final UserModel loggedUser;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  const _DatasetCard(
      {required this.dataset,
      required this.loggedUser,
      required this.onUpdate,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DatasetDetailScreen(
                      dataset: dataset,
                      loggedUser: loggedUser,
                    )),
          );
          onUpdate();
        },
        onLongPress:
            loggedUser.isAdmin ? () => _confirmDelete(context, l) : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(dataset.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ]),
            const SizedBox(height: 4),
            Text(dataset.location,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.science_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              Text(l.datasetSamples(dataset.samples.length),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              Text(_fmtDate(dataset.createdAt),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.datasetRemoveTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l.datasetRemoveBody(dataset.name),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel,
                  style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(l.actionRemove,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
