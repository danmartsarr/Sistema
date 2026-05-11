import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/mlp_service.dart';
import '../services/sample_service.dart';
import '../widgets/ftir_chart.dart';
import 'add_sample_screen.dart';

/// Shows the FTIR chart, MLP identification result, and metadata for a sample.
///
/// Triggers spectrum hydration on load if [SpectrumSample.spectralData] is empty,
/// and allows re-running the MLP analysis.
class SampleDetailScreen extends StatefulWidget {
  final SpectrumSample sample;
  final SpectrumDataset dataset;
  final UserModel loggedUser;
  final VoidCallback onDelete;

  const SampleDetailScreen({
    super.key,
    required this.sample,
    required this.dataset,
    required this.loggedUser,
    required this.onDelete,
  });

  @override
  State<SampleDetailScreen> createState() => _SampleDetailScreenState();
}

class _SampleDetailScreenState extends State<SampleDetailScreen> {
  late SpectrumSample _sample;
  bool _identifying = false;
  bool _loadingSpectrum = false;

  String get _slug => widget.loggedUser.institutionSlug;

  @override
  void initState() {
    super.initState();
    _sample = widget.sample;
    if (_sample.spectralData.isEmpty) _hydrate();
  }

  Future<void> _hydrate() async {
    setState(() => _loadingSpectrum = true);
    await SampleService.hydrateSpectrum(_sample, _slug, widget.dataset.id);
    if (!mounted) return;
    setState(() => _loadingSpectrum = false);
  }

  Future<void> _runIdentification() async {
    final l = AppLocalizations.of(context);
    setState(() => _identifying = true);
    final result = await MlpService.identify(_sample);
    if (!mounted) return;
    if (result != null) {
      setState(() => _sample.result = result);
      await SampleService.update(_sample, _slug);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.sampleNoServer),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _identifying = false);
  }

  void _openEdit() async {
    final result = await Navigator.push<List<SpectrumSample>>(
      context,
      MaterialPageRoute(
          builder: (_) => AddSampleScreen(
                existing: _sample,
                dataset: widget.dataset,
                loggedUser: widget.loggedUser,
              )),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _sample = result.first);
    }
  }

  void _confirmDelete() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.sampleRemoveTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l.sampleRemoveBody(_sample.name),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel,
                style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => widget.onDelete());
            },
            child: Text(l.actionRemove,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result = _sample.result;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_sample.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          if (_sample.spectralData.isNotEmpty)
            _identifying
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.cyanAccent),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.biotech_outlined,
                        color: Colors.cyanAccent),
                    tooltip: l.sampleIdentifyTooltip,
                    onPressed: _runIdentification,
                  ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.actionEdit,
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: l.actionRemove,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_sample.isVerified)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.verified,
                      color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.sampleVerified,
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    if (_sample.verifiedBy.isNotEmpty)
                      Text(l.sampleVerifiedBy(_sample.verifiedBy),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12)),
                  ]),
                ]),
              ),

            _GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionLabel(l.sampleSectionInfo),
                const SizedBox(height: 14),
                _SampleMetaGrid(sample: _sample),
              ]),
            ),
            const SizedBox(height: 16),

            _GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionLabel(l.sampleSectionCalibration),
                const SizedBox(height: 4),
                Text(widget.dataset.name,
                    style: TextStyle(
                        color: Colors.cyanAccent.withValues(alpha: 0.6),
                        fontSize: 12)),
                const SizedBox(height: 14),
                _CalibrationGrid(dataset: widget.dataset),
              ]),
            ),

            if (result != null) ...[
              const SizedBox(height: 20),
              _ResultBanner(result: result),
            ],

            if (_sample.spectralData.isNotEmpty && result == null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.12),
                    foregroundColor: Colors.cyanAccent,
                    side: BorderSide(
                        color: Colors.cyanAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _identifying ? null : _runIdentification,
                  icon: _identifying
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.cyanAccent))
                      : const Icon(Icons.biotech_outlined, size: 20),
                  label: Text(
                    _identifying ? l.sampleIdentifying : l.sampleIdentifyMlp,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8),
                  ),
                ),
              ),
            ],

            if (_sample.spectralData.isNotEmpty) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel(l.sampleSpectrumTitle),
                  const SizedBox(height: 16),
                  FtirChart(sample: _sample, showAttention: result != null),
                ]),
              ),
            ] else ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    if (_loadingSpectrum) ...[
                      const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.cyanAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.sampleNoSpectrumLoading(_sample.id),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13),
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.pending_outlined,
                          color: Colors.white.withValues(alpha: 0.3), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.sampleNoSpectrum,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],

            if (result != null) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel(l.sampleSectionResult),
                  const SizedBox(height: 16),
                  _ModelAnalysisPanel(result: result),
                ]),
              ),
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel(l.sampleSectionPeaks),
                  const SizedBox(height: 14),
                  ...result.keyPeaks.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                            color: result.polymer.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(p,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontFamily: 'monospace')),
                    ]),
                  )),
                ]),
              ),
            ],

            if (_sample.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel(l.sampleSectionNotes),
                  const SizedBox(height: 10),
                  Text(_sample.notes,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.5)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
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

class _SampleMetaGrid extends StatelessWidget {
  final SpectrumSample sample;
  const _SampleMetaGrid({required this.sample});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final date = sample.collectionDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(children: [
      Row(children: [
        Expanded(child: _MetaItem(l.sampleMetaSite, sample.collectionSite)),
        Expanded(child: _MetaItem(l.sampleMetaCollectionDate, dateStr)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _MetaItem(
          l.sampleMetaDataType,
          sample.dataType == DataType.absorbance
              ? l.dataAbsorbance : l.dataTransmittance,
        )),
        if (sample.isVerified)
          Expanded(child: _MetaItem(
            l.sampleMetaVerifiedBy,
            sample.verifiedBy.isEmpty ? '—' : sample.verifiedBy,
            valueColor: Colors.greenAccent,
          ))
        else
          Expanded(child: _MetaItem(l.sampleMetaVerification, l.sampleMetaPending,
              valueColor: Colors.white38)),
      ]),
    ]);
  }
}

class _CalibrationGrid extends StatelessWidget {
  final SpectrumDataset dataset;
  const _CalibrationGrid({required this.dataset});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String modeLabel(MicroscopeMode m) {
      switch (m) {
        case MicroscopeMode.atr: return l.modeAtr;
        case MicroscopeMode.transmission: return l.modeTransmission;
        case MicroscopeMode.reflection: return l.modeReflection;
      }
    }
    return Column(children: [
      Row(children: [
        Expanded(child: _MetaItem(l.sampleCalMode, modeLabel(dataset.microscopeMode))),
        Expanded(child: _MetaItem(l.sampleCalEquipment,
            dataset.microscopeModel.isEmpty ? l.notInformed : dataset.microscopeModel)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _MetaItem(l.sampleCalResolution, '${dataset.resolution.toInt()} cm⁻¹')),
        Expanded(child: _MetaItem(l.sampleCalScans, '${dataset.numScans}')),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _MetaItem(l.sampleCalDetector, dataset.detectorType)),
        if (dataset.crystalType != '—')
          Expanded(child: _MetaItem(l.sampleCalAtrCrystal, dataset.crystalType))
        else
          const Expanded(child: SizedBox()),
      ]),
    ]);
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _MetaItem(this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ]);
}

class _ResultBanner extends StatelessWidget {
  final IdentificationResult result;
  const _ResultBanner({required this.result});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = result.polymer.color;
    final isUnknown = result.polymer == PolymerType.unknown;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(
            isUnknown ? Icons.help_outline : Icons.check_circle_outline,
            color: color, size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.sampleResultLabel,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 2),
          Text(result.polymer.fullName,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${(result.confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 12)],
              )),
          Text(l.sampleConfidence,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _ModelAnalysisPanel extends StatelessWidget {
  final IdentificationResult result;
  const _ModelAnalysisPanel({required this.result});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = result.polymer.color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.psychology_outlined,
              color: Colors.cyanAccent.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(result.reasoning,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.5))),
        ]),
      ),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.sampleDecisionPoint,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 4),
          Row(children: [
            Container(width: 14, height: 3, color: Colors.amber.withValues(alpha: 0.9)),
            const SizedBox(width: 8),
            Text('${result.decisionWavenumber.toInt()} cm⁻¹',
                style: const TextStyle(
                    color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ]),
        SizedBox(
          width: 64, height: 64,
          child: Stack(fit: StackFit.expand, children: [
            CircularProgressIndicator(
              value: result.confidence,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              color: color,
            ),
            Center(child: Text(
              '${(result.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14),
            )),
          ]),
        ),
      ]),
    ]);
  }
}
