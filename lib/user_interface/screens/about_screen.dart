import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0), // Cor de fundo do app
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Mathsticks',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Versão 1.2',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const Divider(height: 30),
            _buildSectionTitle('O que é o App?'),
            const Text(
              'O Mathsticks é uma ferramenta educacional interativa, projetada para explorar conceitos de geometria. Permite aos usuários mover um personagem e posicionar palitos em uma tela digital para criar desenhos, padrões e histórias automatizadas.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(
              Icons.drag_handle,
              'Movimentação Livre:',
              'Arraste o personagem pássaro pela tela ou utilize o joystick para uma exploração precisa do espaço de criação.',
            ),
            _buildFeatureItem(
              Icons.architecture,
              'Criação com Palitos:',
              'Adicione palitos verticais, horizontais e diagonais para construir figuras e criar padrões geométricos.',
            ),
            _buildFeatureItem(
              Icons.list_alt,
              'Criador de Histórias:',
              'Desenvolva sequências de ações (movimentos e palitos) com repetições para automatizar desenhos e contar histórias visuais.',
            ),
             _buildFeatureItem(
              Icons.record_voice_over,
              'Narração:',
              'Ative a narração para que cada passo da sua história seja descrito por voz.',
            ),
            _buildFeatureItem(
              Icons.tune,
              'Controles Personalizáveis:',
              'Ajuste o tamanho dos palitos, a velocidade da narração e ative ou desative o joystick para adaptar a experiência às suas necessidades.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSectionTitle('Apoio Institucional'),
            const SizedBox(height: 15),
            Semantics(
              label:
                  'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/IFSP_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/CNPQ_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/RUMO_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $description'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}