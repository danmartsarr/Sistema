import 'package:flutter/material.dart';
// IMPORTANTE: Adicione o import da tela de analytics aqui
import 'dataset_analytics_screen.dart'; 

class DatasetViewerScreen extends StatelessWidget {
  const DatasetViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Repositório de Datasets', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Card 1: Base RAVI (Com navegação)
          _buildDatasetCard(
            context, // Passamos o context para a navegação funcionar
            title: 'Base Multimodal Ravi',
            subtitle: 'Raman & FTIR Spectra',
            samples: '12.450 assinaturas',
            tags: ['PE', 'PP', 'PET', 'PS'],
            maintainers: 'Lucas e Pedro',
            color: Colors.orangeAccent,
            destination: const DatasetAnalyticsScreen(), // Tela de destino
          ),
          
          // Card 2: Kaggle (Exemplo sem navegação ou indo para a mesma tela)
          _buildDatasetCard(
            context,
            title: 'Kaggle Microplastics Open',
            subtitle: 'Imagens Ópticas',
            samples: '5.200 imagens',
            tags: ['Visão Computacional', 'YOLOv8'],
            maintainers: 'Comunidade',
            color: Colors.blueAccent,
            destination: const DatasetAnalyticsScreen(), // Opcional: pode criar outra tela depois
          ),
        ],
      ),
    );
  }

  // Atualizamos o método para receber o BuildContext e o Widget de destino
  Widget _buildDatasetCard(
    BuildContext context, {
    required String title, 
    required String subtitle, 
    required String samples, 
    required List<String> tags, 
    required String maintainers, 
    required Color color,
    required Widget destination, // Nova variável para a tela destino
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        // Adicionamos uma leve sombra para dar profundidade
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent, // Necessário para o InkWell funcionar com as bordas
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Aqui acontece a mágica da navegação
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => destination)
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Icon(Icons.storage, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: tags.map((tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(tag, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(samples, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Gerenciado por: $maintainers', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}