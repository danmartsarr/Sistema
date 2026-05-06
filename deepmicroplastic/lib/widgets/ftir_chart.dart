import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/spectrum_model.dart';

//Constants 
const double _leftPad   = 66;  
const double _rightPad  = 16;
const double _topPad    = 16;
const double _bottomPad = 44;
const double _wnMin     = 400;
const double _wnMax     = 4000;

//Coordinate helpers 
double _wnToX(double wn, double chartW) =>
    _leftPad + (_wnMax - wn) / (_wnMax - _wnMin) * chartW;

double _intToY(double intensity, double maxI, double chartH) =>
    _topPad + chartH - (intensity / maxI) * chartH;

//Painter
class _FtirPainter extends CustomPainter {
  final List<SpectralPoint> spectralData;
  final List<AttentionPoint>? attentionMap;
  final double? decisionWavenumber;
  final Color polymerColor;
  final Offset? crosshair;
  final String yLabel;

  const _FtirPainter({
    required this.spectralData,
    required this.polymerColor,
    required this.yLabel,
    this.attentionMap,
    this.decisionWavenumber,
    this.crosshair,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spectralData.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;
    final maxI   = spectralData.map((p) => p.intensity).reduce((a, b) => a > b ? a : b);

    // 1. Attention heatmap
    if (attentionMap != null && attentionMap!.length > 1) {
      for (int i = 0; i < attentionMap!.length - 1; i++) {
        final ap  = attentionMap![i];
        final apN = attentionMap![i + 1];
        final att = (ap.attention + apN.attention) / 2;
        if (att < 0.01) continue;
        final x1 = _wnToX(ap.wavenumber, chartW);
        final x2 = _wnToX(apN.wavenumber, chartW);
        final rect = Rect.fromLTRB(
          x1.clamp(_leftPad, _leftPad + chartW),
          _topPad,
          x2.clamp(_leftPad, _leftPad + chartW),
          _topPad + chartH,
        );
        canvas.drawRect(
          rect,
          Paint()..color = const Color(0xFFFF6D00).withValues(alpha: (att * 0.45).clamp(0.0, 0.45)),
        );
      }
    }

    // 2. Grid lines 
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final tickStyle = TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10);

    const wnTicks = [500, 1000, 1500, 2000, 2500, 3000, 3500];
    for (final wn in wnTicks) {
      final x = _wnToX(wn.toDouble(), chartW);
      canvas.drawLine(Offset(x, _topPad), Offset(x, _topPad + chartH), gridPaint);
      _drawText(canvas, '$wn', Offset(x, _topPad + chartH + 6), tickStyle, center: true);
    }

    final ySteps = maxI > 1 ? 6 : 5;
    for (int i = 0; i <= ySteps; i++) {
      final val = maxI * i / ySteps;
      final y   = _intToY(val, maxI, chartH);
      canvas.drawLine(Offset(_leftPad, y), Offset(_leftPad + chartW, y), gridPaint);
      final numTp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(2), style: tickStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      numTp.paint(canvas, Offset(_leftPad - 4 - numTp.width, y - 6));
    }

    _drawText(
      canvas, 'Wavenumber (cm⁻¹)',
      Offset(_leftPad + chartW / 2, size.height - 6),
      TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
      center: true,
    );
    _drawRotatedText(
      canvas, yLabel,
      Offset(8, _topPad + chartH / 2),
      TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
    );

    // 3. Clip to chart area 
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH));

    // 4. Spectrum fill 
    final fillPath = Path();
    bool firstFill = true;
    for (final p in spectralData) {
      final x = _wnToX(p.wavenumber, chartW);
      final y = _intToY(p.intensity, maxI, chartH);
      if (firstFill) { fillPath.moveTo(x, y); firstFill = false; }
      else { fillPath.lineTo(x, y); }
    }
    final lastX  = _wnToX(spectralData.last.wavenumber, chartW);
    final firstX = _wnToX(spectralData.first.wavenumber, chartW);
    final baseY  = _topPad + chartH;
    fillPath
      ..lineTo(lastX, baseY)
      ..lineTo(firstX, baseY)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, _topPad),
          Offset(0, baseY),
          [
            polymerColor.withValues(alpha: 0.25),
            polymerColor.withValues(alpha: 0.02),
          ],
        ),
    );

    // 5. Spectrum line 
    final linePath = Path();
    bool firstLine = true;
    for (final p in spectralData) {
      final x = _wnToX(p.wavenumber, chartW);
      final y = _intToY(p.intensity, maxI, chartH);
      if (firstLine) { linePath.moveTo(x, y); firstLine = false; }
      else { linePath.lineTo(x, y); }
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = polymerColor
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 6. Decision marker 
    if (decisionWavenumber != null) {
      final dx = _wnToX(decisionWavenumber!, chartW);
      _drawDashedLine(
        canvas, Offset(dx, _topPad), Offset(dx, _topPad + chartH),
        Paint()..color = Colors.amber.withValues(alpha: 0.9)..strokeWidth = 1.5,
      );
      _drawText(
        canvas,
        '${decisionWavenumber!.toInt()} cm⁻¹',
        Offset(dx + 4, _topPad + 4),
        const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
        center: false,
      );
    }

    canvas.restore();

    // 7. Crosshair + tooltip 
    if (crosshair != null) {
      final cx = crosshair!.dx.clamp(_leftPad, _leftPad + chartW);
      canvas.drawLine(
        Offset(cx, _topPad),
        Offset(cx, _topPad + chartH),
        Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 1,
      );
      final wn = _wnMax - (cx - _leftPad) / chartW * (_wnMax - _wnMin);
      SpectralPoint? closest;
      double minDist = double.infinity;
      for (final p in spectralData) {
        final d = (p.wavenumber - wn).abs();
        if (d < minDist) { minDist = d; closest = p; }
      }
      if (closest != null) {
        final py = _intToY(closest.intensity, maxI, chartH);
        canvas.drawCircle(Offset(cx, py), 4,
          Paint()..color = polymerColor..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, py), 4,
          Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke);
        final label = '${closest.wavenumber.toStringAsFixed(0)} cm⁻¹  |  '
            '${closest.intensity.toStringAsFixed(4)} ${yLabel.split(' ').first}';
        _drawTooltip(canvas, label, Offset(cx, py - 28), size);
      }
    }

    // 8. Axes border 
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(_leftPad, _topPad), Offset(_leftPad, _topPad + chartH), axisPaint);
    canvas.drawLine(Offset(_leftPad, _topPad + chartH), Offset(_leftPad + chartW, _topPad + chartH), axisPaint);
  }

  void _drawText(Canvas c, String text, Offset pos, TextStyle style, {required bool center}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center ? pos.translate(-tp.width / 2, 0) : pos);
  }

  void _drawTooltip(Canvas c, String text, Offset pos, Size size) {
    const style = TextStyle(color: Colors.white, fontSize: 10.5);
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    double dx = pos.dx - tp.width / 2;
    dx = dx.clamp(_leftPad, size.width - _rightPad - tp.width);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(dx - 8, pos.dy - 4, tp.width + 16, tp.height + 8),
      const Radius.circular(6),
    );
    c.drawRRect(rect, Paint()..color = const Color(0xFF1E293B));
    c.drawRRect(rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(c, Offset(dx, pos.dy));
  }

  void _drawRotatedText(Canvas c, String text, Offset center, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(-1.5708);
    tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
    c.restore();
  }

  void _drawDashedLine(Canvas c, Offset p1, Offset p2, Paint paint) {
    const dashLen = 6.0;
    const gapLen  = 4.0;
    final total = (p2 - p1).distance;
    final dir   = (p2 - p1) / total;
    double dist = 0;
    bool drawing = true;
    while (dist < total) {
      final segLen = drawing ? dashLen : gapLen;
      final end = (dist + segLen).clamp(0.0, total);
      if (drawing) c.drawLine(p1 + dir * dist, p1 + dir * end, paint);
      dist += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_FtirPainter old) =>
      old.spectralData != spectralData ||
      old.crosshair != crosshair ||
      old.decisionWavenumber != decisionWavenumber;
}

// Public Widget 
class FtirChart extends StatefulWidget {
  final SpectrumSample sample;
  final bool showAttention;

  const FtirChart({super.key, required this.sample, this.showAttention = true});

  @override
  State<FtirChart> createState() => _FtirChartState();
}

class _FtirChartState extends State<FtirChart> {
  Offset? _crosshair;
  bool _showTransmittance = false;

  List<SpectralPoint> get _data =>
      _showTransmittance ? widget.sample.asTransmittance : widget.sample.asAbsorbance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sample = widget.sample;
    final color  = sample.result?.polymer.color ?? Colors.cyanAccent;
    final yLabel = _showTransmittance
        ? '${l.chartTransmittance} (%)'
        : '${l.chartAbsorbance} (a.u.)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ChipToggle(
              label: l.chartAbsorbance,
              active: !_showTransmittance,
              onTap: () => setState(() => _showTransmittance = false),
            ),
            const SizedBox(width: 8),
            _ChipToggle(
              label: l.chartTransmittance,
              active: _showTransmittance,
              onTap: () => setState(() => _showTransmittance = true),
            ),
            if (widget.showAttention) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF6D00).withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.blur_on, size: 12, color: Color(0xFFFF6D00)),
                  const SizedBox(width: 4),
                  Text(l.chartAttention,
                      style: const TextStyle(color: Color(0xFFFF6D00), fontSize: 11)),
                ]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Chart
        GestureDetector(
          onPanUpdate: (d) => setState(() => _crosshair = d.localPosition),
          onPanEnd:    (_) => setState(() => _crosshair = null),
          onTapDown:   (d) => setState(() => _crosshair = d.localPosition),
          onTapUp:     (_) => setState(() => _crosshair = null),
          child: SizedBox(
            height: 260,
            child: CustomPaint(
              painter: _FtirPainter(
                spectralData:       _data,
                attentionMap:       widget.showAttention ? sample.result?.attentionMap : null,
                decisionWavenumber: sample.result?.decisionWavenumber,
                polymerColor:       color,
                crosshair:          _crosshair,
                yLabel:             yLabel,
              ),
            ),
          ),
        ),

        // Legend
        if (sample.result != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const SizedBox(width: _leftPad),
              Container(width: 12, height: 3,
                color: Colors.amber.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(l.chartLegendDecision,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              const SizedBox(width: 16),
              Container(
                width: 12, height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(l.chartLegendAttention,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            ]),
          ),
      ],
    );
  }
}

class _ChipToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ChipToggle({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.cyanAccent : Colors.white54,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
