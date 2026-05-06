import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/sample_service.dart';
import 'import_csv_screen.dart';
import 'sample_detail_screen.dart';
import 'add_sample_screen.dart';

class DatasetDetailScreen extends StatefulWidget {
  final SpectrumDataset dataset;
  final UserModel loggedUser;
  const DatasetDetailScreen(
      {super.key, required this.dataset, required this.loggedUser});

  @override
  State<DatasetDetailScreen> createState() => _DatasetDetailScreenState();
}

class _DatasetDetailScreenState extends State<DatasetDetailScreen> {
  String _filter = '__all__';
  bool _loading = true;
  late final SpectrumDataset _dataset;

  String get _slug => widget.loggedUser.institutionSlug;

  @override
  void initState() {
    super.initState();
    _dataset = widget.dataset;
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    setState(() => _loading = true);
    final samples = await SampleService.loadForDataset(_slug, _dataset.id);
    if (!mounted) return;
    setState(() {
      _dataset.samples
        ..clear()
        ..addAll(samples);
      _loading = false;
    });
  }

  List<SpectrumSample> get _filtered {
    if (_filter == '__all__') return _dataset.samples;
    if (_filter == '__pending__') {
      return _dataset.samples.where((s) => s.result == null).toList();
    }
    return _dataset.samples
        .where((s) => s.result?.polymer.label == _filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filterLabels = <(String, String)>[
      ('__all__', l.datasetDetailFilterAll),
      ('PE', 'PE'),
      ('PP', 'PP'),
      ('PET', 'PET'),
      ('PS', 'PS'),
      ('Desconhecido', 'Unknown'),
      ('__pending__', l.datasetDetailFilterPending),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_dataset.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined,
                color: Colors.cyanAccent),
            tooltip: l.datasetDetailUploadCsvTooltip,
            onPressed: () async {
              final imported = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ImportCsvScreen(
                    dataset: _dataset,
                    loggedUser: widget.loggedUser,
                  ),
                ),
              );
              if (imported == true) await _loadSamples();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(l.datasetDetailNewSample,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final newSamples = await Navigator.push<List<SpectrumSample>>(
            context,
            MaterialPageRoute(
                builder: (_) => AddSampleScreen(
                      dataset: _dataset,
                      loggedUser: widget.loggedUser,
                    )),
          );
          if (newSamples == null) return;
          // Lista vazia = importou via CSV no modo lote (ou veio do CSV path);
          // sempre recarregamos do Firebase para manter coerência total.
          await _loadSamples();
        },
      ),
      body: Column(
        children: [
          _DatasetHeader(dataset: _dataset),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: filterLabels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (key, label) = filterLabels[i];
                final active = _filter == key;
                return GestureDetector(
                  onTap: () => setState(() => _filter = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.cyanAccent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? Colors.cyanAccent.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          color: active ? Colors.cyanAccent : Colors.white54,
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(flex: 3, child: _ColHeader(l.datasetDetailColSample)),
              Expanded(flex: 2, child: _ColHeader(l.datasetDetailColLocation)),
              Expanded(flex: 2, child: _ColHeader(l.datasetDetailColPolymer)),
              Expanded(flex: 2, child: _ColHeader(l.datasetDetailColConfidence)),
            ]),
          ),
          const SizedBox(height: 6),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Colors.cyanAccent))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.science_outlined,
                              color: Colors.white.withValues(alpha: 0.2),
                              size: 40),
                          const SizedBox(height: 12),
                          Text(
                            _dataset.samples.isEmpty
                                ? l.datasetDetailEmpty
                                : l.datasetDetailEmptyFiltered,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSamples,
                        color: Colors.cyanAccent,
                        backgroundColor: const Color(0xFF111827),
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) => Divider(
                            color: Colors.white.withValues(alpha: 0.05),
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (_, i) => _SampleRow(
                            sample: _filtered[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SampleDetailScreen(
                                  sample: _filtered[i],
                                  dataset: _dataset,
                                  loggedUser: widget.loggedUser,
                                  onDelete: () async {
                                    await SampleService.delete(
                                      _slug,
                                      _dataset.id,
                                      _filtered[i].id,
                                    );
                                    setState(() => _dataset.samples
                                        .remove(_filtered[i]));
                                    if (mounted) Navigator.pop(context);
                                  },
                                ),
                              ),
                            ).then((_) async {
                              // Recarrega ao voltar para refletir alterações
                              // (identificação, edição, etc).
                              await _loadSamples();
                            }),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _DatasetHeader extends StatelessWidget {
  final SpectrumDataset dataset;
  const _DatasetHeader({required this.dataset});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dist     = dataset.polymerDistribution;
    final analyzed = dataset.analyzedCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(dataset.description,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _MetaChip(Icons.location_on_outlined, dataset.location),
          _MetaChip(Icons.calendar_today_outlined, _fmtDate(dataset.createdAt)),
          _MetaChip(Icons.science_outlined, l.datasetSamples(dataset.samples.length)),
          _MetaChip(Icons.biotech_outlined, _modeLabel(l, dataset.microscopeMode)),
          _MetaChip(Icons.memory_outlined, dataset.detectorType),
          _MetaChip(Icons.tune,
              '${dataset.resolution.toInt()} cm⁻¹ · ${dataset.numScans} scans'),
          if (dataset.crystalType != '—')
            _MetaChip(Icons.diamond_outlined, dataset.crystalType),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatBadge('${dataset.analyzedCount}/${dataset.samples.length}',
              l.datasetDetailStatAnalyzed, Colors.cyanAccent),
          const SizedBox(width: 12),
          _StatBadge('${dataset.verifiedCount}/${dataset.samples.length}',
              l.datasetDetailStatVerified, Colors.purpleAccent),
          if (dataset.avgConfidence > 0) ...[
            const SizedBox(width: 12),
            _StatBadge('${(dataset.avgConfidence * 100).toStringAsFixed(1)}%',
                l.datasetDetailStatAvgConf, Colors.greenAccent),
          ],
        ]),
        if (dist.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l.datasetDetailPolymerDistribution,
              style: TextStyle(
                color: Colors.cyanAccent.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              )),
          const SizedBox(height: 10),
          ...dist.entries.map((e) {
            final frac = analyzed > 0 ? e.value / analyzed : 0.0;
            final color = e.key.color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(
                  width: 70,
                  child: Text(e.key.label,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Stack(children: [
                    Container(height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(3),
                        )),
                    FractionallySizedBox(
                      widthFactor: frac,
                      child: Container(height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4)],
                          )),
                    ),
                  ]),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: Text('${e.value}/$analyzed  ${(frac * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: color, fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
              ]),
            );
          }),
        ],
      ]),
    );
  }

  String _modeLabel(AppLocalizations l, MicroscopeMode m) {
    switch (m) {
      case MicroscopeMode.atr: return l.modeAtr;
      case MicroscopeMode.transmission: return l.modeTransmission;
      case MicroscopeMode.reflection: return l.modeReflection;
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: Colors.white38),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
  ]);
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBadge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
    ]),
  );
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 6),
    child: Text(text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        )),
  );
}

class _SampleRow extends StatelessWidget {
  final SpectrumSample sample;
  final VoidCallback onTap;
  const _SampleRow({required this.sample, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result  = sample.result;
    final polymer = result?.polymer;
    final conf    = result?.confidence ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(sample.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
                if (sample.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified,
                      size: 13, color: Colors.greenAccent),
                ],
              ]),
              const SizedBox(height: 2),
              Text(_fmtDate(sample.collectionDate),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ])),
            Expanded(flex: 2, child: Text(
              sample.collectionSite,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
            Expanded(flex: 2, child: polymer != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: polymer.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: polymer.color.withValues(alpha: 0.35)),
                    ),
                    child: Text(polymer.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: polymer.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  )
                : Text(l.sampleMetaPending,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12))),
            Expanded(flex: 2, child: result != null
                ? Row(children: [
                    _ConfBar(conf),
                    const SizedBox(width: 8),
                    Text('${(conf * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _confColor(conf),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                  ])
                : Text('—',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3)))),
          ]),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Color _confColor(double c) {
    if (c >= 0.9) return Colors.greenAccent;
    if (c >= 0.75) return Colors.yellowAccent;
    return Colors.orangeAccent;
  }
}

class _ConfBar extends StatelessWidget {
  final double value;
  const _ConfBar(this.value);

  Color get _color {
    if (value >= 0.9) return Colors.greenAccent;
    if (value >= 0.75) return Colors.yellowAccent;
    return Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    child: Stack(children: [
      Container(height: 4,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2))),
      FractionallySizedBox(
        widthFactor: value,
        child: Container(height: 4,
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(2))),
      ),
    ]),
  );
}
