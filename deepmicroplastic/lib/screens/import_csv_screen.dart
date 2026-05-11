import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/csv_import_service.dart';
import '../services/sample_service.dart';
import '../utils/id_generator.dart';

/// Batch-imports samples from a CSV file via the MLP server's `/predict_csv` endpoint.
class ImportCsvScreen extends StatefulWidget {
  final SpectrumDataset dataset;
  final UserModel loggedUser;

  final String? defaultSite;

  final String? defaultNotes;

  const ImportCsvScreen({
    super.key,
    required this.dataset,
    required this.loggedUser,
    this.defaultSite,
    this.defaultNotes,
  });

  @override
  State<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  String? _filePath;
  String? _fileName;
  bool _loading = false;
  String? _errorMsg;
  List<CsvSampleResult> _results = [];
  bool _saving = false;

  String get _slug => widget.loggedUser.institutionSlug;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _filePath  = result.files.single.path;
      _fileName  = result.files.single.name;
      _results   = [];
      _errorMsg  = null;
    });
  }

  Future<void> _runPrediction() async {
    if (_filePath == null) return;
    setState(() { _loading = true; _errorMsg = null; _results = []; });
    try {
      final results = await CsvImportService.predictFromCsv(_filePath!, _fileName!);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _importSamples() async {
    final l = AppLocalizations.of(context);
    if (_results.isEmpty) return;
    setState(() => _saving = true);

    final site  = widget.defaultSite?.trim().isNotEmpty == true
        ? widget.defaultSite!.trim()
        : 'Imported via CSV';
    final extra = widget.defaultNotes?.trim();
    int saved = 0;

    for (final r in _results) {
      final id          = SampleIdGenerator.generateInternalId();
      final displayName = SampleIdGenerator.generateName(widget.dataset.name);
      final traceLine   = 'CSV row ${r.row + 1} • source: ${r.originalCsvName}';
      final notes       = extra == null || extra.isEmpty
          ? traceLine
          : '$extra\n$traceLine';

      final sample = SpectrumSample(
        id:             id,
        name:           displayName,
        collectionSite: site,
        collectionDate: DateTime.now(),
        dataType:       widget.dataset.dataType,
        spectralData:   r.spectralData,
        result:         r.identification,
        notes:          notes,
      );

      final ok = await SampleService.save(
        sample,
        _slug,
        widget.dataset.id,
        widget.loggedUser.username,
      );
      if (ok) {
        widget.dataset.samples.add(sample);
        saved++;
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l.importCsvImportedToast(saved)),
      backgroundColor: Colors.greenAccent.withValues(alpha: 0.9),
    ));
    Navigator.pop(context, saved > 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.importCsvTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel(l.importCsvSectionFormat),
            const SizedBox(height: 10),
            _InfoLine(Icons.table_chart_outlined, l.importCsvFormat1),
            const SizedBox(height: 6),
            _InfoLine(Icons.tag, l.importCsvFormat2),
            const SizedBox(height: 6),
            _InfoLine(Icons.auto_fix_high_outlined, l.importCsvFormat3),
            const SizedBox(height: 6),
            _InfoLine(Icons.biotech_outlined, l.importCsvFormat4),
          ])),
          const SizedBox(height: 16),
          _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel(l.importCsvSectionFile),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _fileName == null
                    ? Text(l.importCsvNoFile,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 13))
                    : Row(children: [
                        const Icon(Icons.description_outlined,
                            color: Colors.cyanAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_fileName!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.cyanAccent,
                  side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _loading ? null : _pickFile,
                icon: const Icon(Icons.folder_open_outlined, size: 16),
                label: Text(l.importCsvChoose),
              ),
            ]),
          ])),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed:
                  (_filePath == null || _loading) ? null : _runPrediction,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.biotech_outlined, size: 20),
              label: Text(
                _loading
                    ? l.importCsvIdentifying(
                        _results.isNotEmpty ? '(${_results.length})' : '')
                    : l.importCsvIdentify,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
            ),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_errorMsg!,
                      style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.4)),
                ),
              ]),
            ),
          ],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _SectionLabel(l.importCsvResults(_results.length)),
              Text(
                l.importCsvHighConf(_results
                    .where((r) => r.identification.confidence >= 0.9)
                    .length),
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ]),
            const SizedBox(height: 10),
            ..._results.map((r) => _ResultRow(result: r)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withValues(alpha: 0.15),
                  foregroundColor: Colors.greenAccent,
                  side: BorderSide(
                      color: Colors.greenAccent.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _importSamples,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.greenAccent))
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _saving
                      ? l.importCsvSaving
                      : l.importCsvImport(_results.length),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6),
                ),
              ),
            ),
          ],
        ]),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
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

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.cyanAccent.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.4)),
          ),
        ],
      );
}

class _ResultRow extends StatelessWidget {
  final CsvSampleResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final id    = result.identification;
    final color = id.polymer.color;
    final conf  = id.confidence;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: Text('${result.row + 1}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11)),
        ),
        Expanded(
          flex: 3,
          child: Text(result.originalCsvName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(id.polymer.label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Text(
          '${(conf * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: _confColor(conf),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }

  Color _confColor(double c) {
    if (c >= 0.90) return Colors.greenAccent;
    if (c >= 0.75) return Colors.yellowAccent;
    return Colors.orangeAccent;
  }
}
