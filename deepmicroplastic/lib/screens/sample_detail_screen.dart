import 'package:flutter/material.dart';
import '../models/spectrum_model.dart';
import '../models/user_model.dart';
import '../services/mlp_service.dart';
import '../widgets/ftir_chart.dart';
import 'add_sample_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _sample = widget.sample;
  }

  Future<void> _runIdentification() async {
    setState(() => _identifying = true);
    final result = await MlpService.identify(_sample);
    if (!mounted) return;
    if (result != null) {
      setState(() => _sample.result = result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível conectar ao servidor MLP. '
              'Verifique se mlp_server.py está em execução.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover amostra?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'A amostra "${_sample.name}" será removida permanentemente.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => widget.onDelete());
            },
            child: const Text('Remover',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.biotech_outlined, color: Colors.cyanAccent),
                    tooltip: 'Identificar com MLP',
                    onPressed: _runIdentification,
                  ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Remover',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Badge de verificação
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
                    const Text('Amostra Verificada',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    if (_sample.verifiedBy.isNotEmpty)
                      Text('por ${_sample.verifiedBy}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12)),
                  ]),
                ]),
              ),

            // Metadata
            _GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SectionLabel('INFORMAÇÕES DA AMOSTRA'),
                const SizedBox(height: 14),
                _SampleMetaGrid(sample: _sample),
              ]),
            ),

            const SizedBox(height: 16),

            // Calibração do dataset
            _GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SectionLabel('CALIBRAÇÃO DO EQUIPAMENTO'),
                const SizedBox(height: 4),
                Text(widget.dataset.name,
                    style: TextStyle(
                        color: Colors.cyanAccent.withValues(alpha: 0.6),
                        fontSize: 12)),
                const SizedBox(height: 14),
                _CalibrationGrid(dataset: widget.dataset),
              ]),
            ),

            // Resultado de identificação
            if (result != null) ...[
              const SizedBox(height: 20),
              _ResultBanner(result: result),
            ],

            // Botão de identificação (quando há espectro sem resultado)
            if (_sample.spectralData.isNotEmpty && result == null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.12),
                    foregroundColor: Colors.cyanAccent,
                    side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.5)),
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
                    _identifying ? 'IDENTIFICANDO...' : 'IDENTIFICAR COM MLP',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8),
                  ),
                ),
              ),
            ],

            // Espectro FTIR (só se houver dados)
            if (_sample.spectralData.isNotEmpty) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SectionLabel('ESPECTRO FTIR'),
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
                    Icon(Icons.pending_outlined,
                        color: Colors.white.withValues(alpha: 0.3), size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Dados espectrais ainda não importados para esta amostra.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13),
                    ),
                  ]),
                ),
              ),
            ],

            // Análise do modelo
            if (result != null) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SectionLabel('ANÁLISE DO MODELO'),
                  const SizedBox(height: 16),
                  _ModelAnalysisPanel(result: result),
                ]),
              ),
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SectionLabel('BANDAS DIAGNÓSTICAS'),
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

            // Observações
            if (_sample.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              _GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SectionLabel('OBSERVAÇÕES'),
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

// ── Widgets ───────────────────────────────────────────────────────────────────

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
    final date = sample.collectionDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(children: [
      Row(children: [
        Expanded(child: _MetaItem('Local', sample.collectionSite)),
        Expanded(child: _MetaItem('Data de Coleta', dateStr)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _MetaItem(
          'Tipo de Dado',
          sample.dataType == DataType.absorbance ? 'Absorbância' : 'Transmitância',
        )),
        if (sample.isVerified)
          Expanded(child: _MetaItem(
            'Verificado por',
            sample.verifiedBy.isEmpty ? '—' : sample.verifiedBy,
            valueColor: Colors.greenAccent,
          ))
        else
          Expanded(child: _MetaItem('Verificação', 'Pendente',
              valueColor: Colors.white38)),
      ]),
    ]);
  }
}

class _CalibrationGrid extends StatelessWidget {
  final SpectrumDataset dataset;
  const _CalibrationGrid({required this.dataset});
  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          Expanded(child: _MetaItem('Modo', dataset.microscopeMode.label)),
          Expanded(child: _MetaItem('Equipamento',
              dataset.microscopeModel.isEmpty ? 'Não informado' : dataset.microscopeModel)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _MetaItem('Resolução', '${dataset.resolution.toInt()} cm⁻¹')),
          Expanded(child: _MetaItem('Nº de Scans', '${dataset.numScans}')),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _MetaItem('Detector', dataset.detectorType)),
          if (dataset.crystalType != '—')
            Expanded(child: _MetaItem('Cristal ATR', dataset.crystalType))
          else
            const Expanded(child: SizedBox()),
        ]),
      ]);
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
            style:
                TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
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
          Text('Polímero Identificado',
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
          Text('confiança',
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
          Text('Ponto de Decisão',
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
