import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/csv_import_service.dart';
import '../services/sample_service.dart';
import '../utils/id_generator.dart';
import 'import_csv_screen.dart';

/// Form to add or edit a single spectrum sample; can also route to CSV batch import.
class AddSampleScreen extends StatefulWidget {
  final SpectrumSample? existing;
  final SpectrumDataset? dataset;
  final UserModel loggedUser;

  const AddSampleScreen({
    super.key,
    this.existing,
    this.dataset,
    required this.loggedUser,
  });

  @override
  State<AddSampleScreen> createState() => _AddSampleScreenState();
}

class _AddSampleScreenState extends State<AddSampleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _batchMode = false;

  late final TextEditingController _siteCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _collectionDate;
  bool _isVerified = false;
  bool _saving = false;

  // CSV anexado (modo individual)
  CsvSampleResult? _attachedSpectrum;
  String? _attachedFileName;
  bool _attaching = false;
  String? _attachError;

  late final TextEditingController _batchSiteCtrl;
  late final TextEditingController _batchCountCtrl;
  late final TextEditingController _batchNotesCtrl;
  bool _batchVerified = false;
  bool _batchSaving = false;

  bool get _editing => widget.existing != null;
  String get _slug => widget.loggedUser.institutionSlug;

  late final String _autoName;

  DataType get _effectiveDataType =>
      widget.dataset?.dataType ?? widget.existing?.dataType ?? DataType.absorbance;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _siteCtrl = TextEditingController(text: e?.collectionSite ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _collectionDate = e?.collectionDate ?? DateTime.now();
    _isVerified = e?.isVerified ?? false;
    _batchSiteCtrl = TextEditingController();
    _batchCountCtrl = TextEditingController(text: '1');
    _batchNotesCtrl = TextEditingController();
    _autoName = _editing
        ? (e?.name ?? '')
        : SampleIdGenerator.generateName(widget.dataset?.name ?? 'Sample');
  }

  @override
  void dispose() {
    _siteCtrl.dispose();
    _notesCtrl.dispose();
    _batchSiteCtrl.dispose();
    _batchCountCtrl.dispose();
    _batchNotesCtrl.dispose();
    super.dispose();
  }

  String _modeLabel(AppLocalizations l, MicroscopeMode m) {
    switch (m) {
      case MicroscopeMode.atr: return l.modeAtr;
      case MicroscopeMode.transmission: return l.modeTransmission;
      case MicroscopeMode.reflection: return l.modeReflection;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _collectionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            onPrimary: Colors.black,
            surface: Color(0xFF111827),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _collectionDate = picked);
  }

  Future<void> _attachCsv() async {
    final l = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (picked == null || picked.files.single.path == null) return;

    setState(() {
      _attaching = true;
      _attachError = null;
      _attachedSpectrum = null;
      _attachedFileName = picked.files.single.name;
    });

    try {
      final results = await CsvImportService.predictFromCsv(
        picked.files.single.path!,
        picked.files.single.name,
      );
      if (results.isEmpty) {
        setState(() => _attachError = l.addSampleAttachInvalid);
        return;
      }
      setState(() => _attachedSpectrum = results.first);
      if (results.length > 1 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.addSampleAttachMultiline(results.length)),
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
        ));
      }
    } catch (e) {
      setState(() => _attachError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _attaching = false);
    }
  }

  void _clearAttachment() => setState(() {
        _attachedSpectrum = null;
        _attachedFileName = null;
        _attachError = null;
      });

  Future<void> _saveSingle() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    if (_editing) {
      final e = widget.existing!;
      e.collectionSite = _siteCtrl.text.trim().isEmpty ? l.notInformed : _siteCtrl.text.trim();
      e.notes = _notesCtrl.text.trim();
      e.isVerified = _isVerified;
      e.verifiedBy = _isVerified ? widget.loggedUser.displayName : '';
      e.collectionDate = _collectionDate;
      await SampleService.update(e, _slug);
      if (!mounted) return;
      Navigator.pop(context, [e]);
      return;
    }

    final attachment = _attachedSpectrum;
    final notes = _notesCtrl.text.trim();
    final fullNotes = attachment == null
        ? notes
        : [
            if (notes.isNotEmpty) notes,
            'CSV: $_attachedFileName (source: ${attachment.originalCsvName})',
          ].join('\n');

    final sample = SpectrumSample(
      id:             SampleIdGenerator.generateInternalId(),
      name:           _autoName,
      collectionSite: _siteCtrl.text.trim().isEmpty ? l.notInformed : _siteCtrl.text.trim(),
      collectionDate: _collectionDate,
      dataType:       _effectiveDataType,
      spectralData:   attachment?.spectralData ?? const [],
      result:         attachment?.identification,
      notes:          fullNotes,
      isVerified:     _isVerified,
      verifiedBy:     _isVerified ? widget.loggedUser.displayName : '',
    );

    final ok = await SampleService.save(
      sample,
      _slug,
      widget.dataset!.id,
      widget.loggedUser.username,
    );
    if (!mounted) return;

    if (!ok) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.addSampleSaveError),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.pop(context, [sample]);
  }

  Future<void> _saveBatch() async {
    final l = AppLocalizations.of(context);
    final count = int.tryParse(_batchCountCtrl.text.trim()) ?? 0;
    if (count < 1 || count > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.addSampleBatchInvalidCount)),
      );
      return;
    }

    setState(() => _batchSaving = true);
    final site = _batchSiteCtrl.text.trim().isEmpty
        ? l.notInformed
        : _batchSiteCtrl.text.trim();
    final notes = _batchNotesCtrl.text.trim();

    final samples = <SpectrumSample>[];
    for (int i = 0; i < count; i++) {
      final s = SpectrumSample(
        id: SampleIdGenerator.generateInternalId(),
        name: SampleIdGenerator.generateName(widget.dataset?.name ?? 'Sample'),
        collectionSite: site,
        collectionDate: DateTime.now(),
        dataType: _effectiveDataType,
        spectralData: const [],
        notes: notes,
        isVerified: _batchVerified,
        verifiedBy: _batchVerified ? widget.loggedUser.displayName : '',
      );
      samples.add(s);
      await SampleService.save(
        s,
        _slug,
        widget.dataset!.id,
        widget.loggedUser.username,
      );
    }

    if (!mounted) return;
    Navigator.pop(context, samples);
  }

  Future<void> _importBatchFromCsv() async {
    final ds = widget.dataset;
    if (ds == null) return;
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ImportCsvScreen(
          dataset:      ds,
          loggedUser:   widget.loggedUser,
          defaultSite:  _batchSiteCtrl.text.trim().isEmpty
              ? null
              : _batchSiteCtrl.text.trim(),
          defaultNotes: _batchNotesCtrl.text.trim().isEmpty
              ? null
              : _batchNotesCtrl.text.trim(),
        ),
      ),
    );
    if (imported == true && mounted) {
      Navigator.pop(context, <SpectrumSample>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ds = widget.dataset;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _editing ? l.addSampleTitleEdit : l.addSampleTitleNew,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (ds != null) ...[
              _SectionLabel(l.addSampleSectionCollection),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ds.name,
                      style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 14, runSpacing: 4, children: [
                    _InfoChip(Icons.biotech_outlined, _modeLabel(l, ds.microscopeMode)),
                    _InfoChip(Icons.memory_outlined, ds.detectorType),
                    _InfoChip(Icons.tune,
                        '${ds.resolution.toInt()} cm⁻¹ · ${ds.numScans} scans'),
                    if (ds.crystalType != '—')
                      _InfoChip(Icons.diamond_outlined, ds.crystalType),
                    _InfoChip(
                        Icons.show_chart,
                        ds.dataType == DataType.absorbance
                            ? l.dataAbsorbance
                            : l.dataTransmittance),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            if (!_editing) ...[
              Row(children: [
                _ModeChip(
                  label: l.addSampleModeIndividual,
                  icon: Icons.science_outlined,
                  selected: !_batchMode,
                  onTap: () => setState(() => _batchMode = false),
                ),
                const SizedBox(width: 10),
                _ModeChip(
                  label: l.addSampleModeBatch,
                  icon: Icons.layers_outlined,
                  selected: _batchMode,
                  onTap: () => setState(() => _batchMode = true),
                ),
              ]),
              const SizedBox(height: 24),
            ],

            if (!_batchMode) ...[
              _SectionLabel(l.addSampleSectionId),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(children: [
                  Icon(Icons.tag, size: 16, color: Colors.cyanAccent.withValues(alpha: 0.7)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.addSampleIdLabel,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(_autoName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l.addSampleIdRandom,
                        style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.7),
                            fontSize: 10)),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              _Field(l.addSampleSiteLabel, _siteCtrl, hint: l.addSampleSiteHint),
              const SizedBox(height: 14),

              _SectionLabel(l.addSampleSectionDate),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.cyanAccent.withValues(alpha: 0.7)),
                    const SizedBox(width: 12),
                    Text(_fmtDate(_collectionDate),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const Spacer(),
                    Text(l.addSampleChangeDate,
                        style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.6),
                            fontSize: 13)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              if (!_editing) ...[
                _SectionLabel(l.addSampleSectionSpectral),
                const SizedBox(height: 10),
                _AttachmentBox(
                  fileName: _attachedFileName,
                  result:   _attachedSpectrum,
                  loading:  _attaching,
                  error:    _attachError,
                  onPick:   _attachCsv,
                  onClear:  _clearAttachment,
                ),
                const SizedBox(height: 20),
              ],

              _SectionLabel(l.addSampleSectionNotes),
              const SizedBox(height: 10),
              _Field(l.addSampleNotesLabel, _notesCtrl,
                  hint: l.addSampleNotesHint, maxLines: 3),
              const SizedBox(height: 24),

              _buildVerificationSection(
                  l, _isVerified, (v) => setState(() => _isVerified = v)),
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
                  onPressed: _saving ? null : _saveSingle,
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : Text(
                          _editing
                              ? l.addSampleSaveBtnEdit
                              : l.addSampleSaveBtn,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8)),
                ),
              ),
            ],

            if (_batchMode) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline,
                      size: 15, color: Colors.blueAccent.withValues(alpha: 0.8)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    l.addSampleBatchInfo,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12, height: 1.4),
                  )),
                ]),
              ),

              _SectionLabel(l.addSampleBatchSectionCount),
              const SizedBox(height: 10),
              _Field(l.addSampleBatchCount, _batchCountCtrl,
                  hint: l.addSampleBatchCountHint,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),

              _SectionLabel(l.addSampleBatchSiteHint),
              const SizedBox(height: 10),
              _Field(l.addSampleBatchSiteLabel, _batchSiteCtrl,
                  hint: l.addSampleBatchSiteHint),
              const SizedBox(height: 14),

              _SectionLabel(l.addSampleSectionNotes),
              const SizedBox(height: 10),
              _Field(l.addSampleBatchNotesLabel, _batchNotesCtrl,
                  hint: l.addSampleBatchNotesHint, maxLines: 2),
              const SizedBox(height: 20),

              _buildVerificationSection(
                  l, _batchVerified, (v) => setState(() => _batchVerified = v)),
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
                  onPressed: _batchSaving ? null : _saveBatch,
                  child: _batchSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : Text(l.addSampleBatchSaveBtn,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _batchSaving ? null : _importBatchFromCsv,
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: Text(l.addSampleBatchImportCsv,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildVerificationSection(
      AppLocalizations l, bool verified, void Function(bool) onToggle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(l.addSampleSectionVerification),
      const SizedBox(height: 12),
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onToggle(!verified),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: verified ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: verified ? Colors.greenAccent : Colors.white30, width: 1.5),
              ),
              child: verified
                  ? const Icon(Icons.check, size: 14, color: Colors.greenAccent)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                l.addSampleVerifiedToggle,
                style: TextStyle(
                  color: verified ? Colors.greenAccent : Colors.white70,
                  fontSize: 14,
                  fontWeight: verified ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (verified) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.person, size: 13, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text(widget.loggedUser.displayName,
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ]),
              ],
            ])),
          ]),
        ),
      ),
    ]);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
  final int maxLines;

  const _Field(this.label, this.controller,
      {this.hint, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
        ),
      );
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? Colors.cyanAccent.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? Colors.cyanAccent.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.cyanAccent : Colors.white38),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  color: selected ? Colors.cyanAccent : Colors.white54,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                )),
          ]),
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.cyanAccent.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
      ]);
}

class _AttachmentBox extends StatelessWidget {
  final String? fileName;
  final CsvSampleResult? result;
  final bool loading;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _AttachmentBox({
    required this.fileName,
    required this.result,
    required this.loading,
    required this.error,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(
            fileName == null
                ? l.addSampleAttachLoading
                : l.addSampleAttachLoadingFile(fileName!),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          )),
        ]),
      );
    }

    if (result != null) {
      final id = result!.identification;
      final color = id.polymer.color;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.check_circle_outline, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              fileName ?? '—',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            )),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: Colors.white.withValues(alpha: 0.5)),
              tooltip: l.addSampleAttachRemoveTooltip,
              onPressed: onClear,
            ),
          ]),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 4, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(id.polymer.label,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            Text(
              l.addSampleAttachConfidenceShort(
                  (id.confidence * 100).toStringAsFixed(1)),
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(l.addSampleAttachPoints(result!.spectralData.length),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ]),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.cyanAccent,
          side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onPressed: onPick,
        icon: const Icon(Icons.upload_file_outlined, size: 18),
        label: Text(l.addSampleAttachCsv,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
      if (error != null) ...[
        const SizedBox(height: 8),
        Text(error!,
            style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.9), fontSize: 12)),
      ] else ...[
        const SizedBox(height: 6),
        Text(
          l.addSampleAttachHelp,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, height: 1.4),
        ),
      ],
    ]);
  }
}
