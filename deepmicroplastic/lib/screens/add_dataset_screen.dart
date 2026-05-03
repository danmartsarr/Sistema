import 'package:flutter/material.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/dataset_service.dart';

class AddDatasetScreen extends StatefulWidget {
  final UserModel loggedUser;
  const AddDatasetScreen({super.key, required this.loggedUser});

  @override
  State<AddDatasetScreen> createState() => _AddDatasetScreenState();
}

class _AddDatasetScreenState extends State<AddDatasetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl     = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _modelCtrl    = TextEditingController();
  final _resCtrl      = TextEditingController(text: '4');
  final _scansCtrl    = TextEditingController(text: '64');

  MicroscopeMode _mode    = MicroscopeMode.atr;
  String _detector        = 'MCT';
  String _crystal         = 'Diamante';
  DataType _dataType      = DataType.absorbance;
  bool _saving            = false;

  final _detectors = ['MCT', 'DTGS', 'InGaAs'];
  final _crystals  = ['Diamante', 'ZnSe', 'Ge', 'Si'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _locationCtrl.dispose();
    _modelCtrl.dispose(); _resCtrl.dispose(); _scansCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final dataset = SpectrumDataset(
      id:            '',
      name:          _nameCtrl.text.trim(),
      description:   _descCtrl.text.trim().isEmpty
                         ? 'Sem descrição.'
                         : _descCtrl.text.trim(),
      location:      _locationCtrl.text.trim(),
      createdAt:     DateTime.now(),
      samples:       [],
      microscopeMode:  _mode,
      microscopeModel: _modelCtrl.text.trim().isEmpty
                         ? 'Não informado'
                         : _modelCtrl.text.trim(),
      resolution:    double.tryParse(_resCtrl.text) ?? 4,
      numScans:      int.tryParse(_scansCtrl.text) ?? 64,
      detectorType:  _detector,
      crystalType:   _mode == MicroscopeMode.atr ? _crystal : '—',
      dataType:      _dataType,
    );

    final id = await DatasetService.save(dataset, widget.loggedUser.username);
    if (!mounted) return;

    if (id == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar. Verifique a conexão.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Return the saved dataset with the real Firebase ID
    final saved = SpectrumDataset(
      id:            id,
      name:          dataset.name,
      description:   dataset.description,
      location:      dataset.location,
      createdAt:     dataset.createdAt,
      samples:       [],
      microscopeMode:  dataset.microscopeMode,
      microscopeModel: dataset.microscopeModel,
      resolution:    dataset.resolution,
      numScans:      dataset.numScans,
      detectorType:  dataset.detectorType,
      crystalType:   dataset.crystalType,
      dataType:      dataset.dataType,
    );
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nova Coleta',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _SectionLabel('IDENTIFICAÇÃO'),
            const SizedBox(height: 14),
            _Field('Nome da Coleta', _nameCtrl,
              hint: 'Ex: Praia do Futuro — Abr/2024',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null),
            const SizedBox(height: 14),
            _Field('Descrição', _descCtrl,
              hint: 'Ex: Sedimento superficial em 5 pontos amostrais',
              maxLines: 2),
            const SizedBox(height: 14),
            _Field('Localização', _locationCtrl,
              hint: 'Ex: Fortaleza, CE'),

            const SizedBox(height: 28),

            _SectionLabel('EQUIPAMENTO E CALIBRAÇÃO'),
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 15, color: Colors.cyanAccent.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Parâmetros compartilhados por todas as amostras desta coleta.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, height: 1.4),
                )),
              ]),
            ),
            _Field('Modelo do Espectrômetro', _modelCtrl,
              hint: 'Ex: Bruker Vertex 70 + Hyperion 3000'),
            const SizedBox(height: 14),

            _Label('Modo de Aquisição'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: MicroscopeMode.values.map((m) => _ChoiceChip(
              label: m.label,
              selected: _mode == m,
              onTap: () => setState(() => _mode = m),
            )).toList()),

            const SizedBox(height: 14),

            if (_mode == MicroscopeMode.atr) ...[
              _Label('Cristal ATR'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: _crystals.map((c) => _ChoiceChip(
                label: c,
                selected: _crystal == c,
                onTap: () => setState(() => _crystal = c),
              )).toList()),
              const SizedBox(height: 14),
            ],

            _Label('Detector'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _detectors.map((d) => _ChoiceChip(
              label: d,
              selected: _detector == d,
              onTap: () => setState(() => _detector = d),
            )).toList()),

            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Resolução (cm⁻¹)', _resCtrl,
                hint: '4', keyboardType: TextInputType.number)),
              const SizedBox(width: 14),
              Expanded(child: _Field('Nº de Scans', _scansCtrl,
                hint: '64', keyboardType: TextInputType.number)),
            ]),

            const SizedBox(height: 24),

            _SectionLabel('TIPO DE DADO PADRÃO'),
            const SizedBox(height: 8),
            Wrap(spacing: 10, children: [
              _ChoiceChip(
                label: 'Absorbância',
                selected: _dataType == DataType.absorbance,
                onTap: () => setState(() => _dataType = DataType.absorbance),
              ),
              _ChoiceChip(
                label: 'Transmitância',
                selected: _dataType == DataType.transmittance,
                onTap: () => setState(() => _dataType = DataType.transmittance),
              ),
            ]),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('SALVAR COLETA',
                        style: TextStyle(
                          color: Colors.black, fontSize: 14,
                          fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Widgets locais ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13));
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field(this.label, this.controller, {
    this.hint, this.keyboardType, this.maxLines = 1, this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent)),
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? Colors.cyanAccent.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? Colors.cyanAccent : Colors.white54,
        fontSize: 13,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      )),
    ),
  );
}
