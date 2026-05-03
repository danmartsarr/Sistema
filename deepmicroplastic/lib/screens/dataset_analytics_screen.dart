import 'package:flutter/material.dart';
import 'dart:ui';

class DatasetAnalyticsScreen extends StatelessWidget {
  const DatasetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Analytics: Base RAVI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: () {}),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Imersivo
          Image.network(
            'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
            color: const Color(0xFF0A0E21).withOpacity(0.85),
            colorBlendMode: BlendMode.darken,
          ),
          
          // Conteúdo do Dashboard
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KPIs Principais
                  Row(
                    children: [
                      Expanded(child: _buildKpiCard('Amostras', '12.4K', Icons.science, Colors.cyanAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Confiabilidade', '94.8%', Icons.verified_user, Colors.greenAccent)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Gráfico de Distribuição de Substâncias
                  _buildGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Distribuição de Polímeros", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Icon(Icons.pie_chart_outline, color: Colors.white54),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildCustomBarChart('Polietileno (PE)', 0.45, '45%', Colors.cyanAccent),
                        const SizedBox(height: 16),
                        _buildCustomBarChart('Polipropileno (PP)', 0.28, '28%', Colors.purpleAccent),
                        const SizedBox(height: 16),
                        _buildCustomBarChart('Polietileno Tereftalato (PET)', 0.15, '15%', Colors.orangeAccent),
                        const SizedBox(height: 16),
                        _buildCustomBarChart('Poliestireno (PS)', 0.12, '12%', Colors.pinkAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Confiabilidade do Modelo de IA
                  _buildGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Métricas do Modelo (Raman + FTIR)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCircularMetric(0.96, 'Precisão', Colors.greenAccent),
                            _buildCircularMetric(0.92, 'Recall', Colors.blueAccent),
                            _buildCircularMetric(0.94, 'F1-Score', Colors.cyanAccent),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Text(
                            "O modelo apresenta maior confiança na detecção de partículas de PE (>50µm) sob excitação de laser 785nm.",
                            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Fluxo de Ingestão de Dados
                  _buildGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Fluxo de Pipeline", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _buildPipelineStep(Icons.upload_file, 'Ingestão Bruta', 'Espectrômetro', true),
                        _buildPipelineStep(Icons.filter_alt, 'Pré-processamento', 'Remoção de Ruído & Baseline', true),
                        _buildPipelineStep(Icons.memory, 'Inferência Multimodal', 'Rede Neural Convolucional 1D', true),
                        _buildPipelineStep(Icons.storage, 'Indexação RAVI', 'Disponível para Consulta', false, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Espaço no final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES VISUAIS PERSONALIZADOS ---

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 10)])),
        ],
      ),
    );
  }

  Widget _buildCustomBarChart(String label, double percentage, String percentageText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(percentageText, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularMetric(double value, String label, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: color,
              ),
              Center(
                child: Text(
                  "${(value * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildPipelineStep(IconData icon, String title, String subtitle, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? Colors.cyanAccent : Colors.white24),
              ),
              child: Icon(icon, size: 20, color: isCompleted ? Colors.cyanAccent : Colors.white54),
            ),
            if (!isLast)
              Container(
                height: 30,
                width: 2,
                color: isCompleted ? Colors.cyanAccent.withOpacity(0.5) : Colors.white12,
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isCompleted ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );
  }
}