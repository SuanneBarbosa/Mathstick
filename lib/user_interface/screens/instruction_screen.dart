import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instruções de Uso"),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
           _buildInstructionItem(
              title: 'Movimentando o Personagem',
              description:
                  'Arraste o personagem pela tela para movimentá-lo. Utilize o joystick na parte inferior da tela para mover o personagem nas quatro direções: cima, baixo, esquerda e direita. O joystick pode ser desativado no menu lateral.',
              semanticsDescription:
                  'Arraste para mover ou use o joystick.',
            ),
           _buildInstructionItem(
              title: 'Adicionando Palitos',
              description:
                  'Toque nos botões correspondentes aos tipos de palitos para adicioná-los à tela (Palito V - Palito Vertical, Palito DD - Palito Diagonal Direita, Palito DE - Palito Diagonal Esquerda, Palito H - Palito Horizontal ) .',
              semanticsDescription:
                  'Toque nos botões para adicionar palitos.',
            ),
                       _buildInstructionItem(
              title: 'Removendo Palitos',
              description:
                  'Toque em um palito na tela para removê-lo. Uma caixa de diálogo de confirmação será exibida.',
              semanticsDescription: 'Toque no palito para removê-lo.',
            ),
            _buildInstructionItem(
              title: 'Limpando a Tela',
              description:
                  'Abra o menu lateral (ícone de menu no canto superior esquerdo) e toque em "Limpar Tela" para remover todos os palitos da tela.',
              semanticsDescription: 'Use a opção "Limpar Tela" no menu lateral',
            ),

           _buildInstructionItem(
              title: 'Ajustando o Tamanho do Palito',
              description:
                  'Abra o menu lateral (ícone de menu no canto superior esquerdo) e utilize o controle deslizante "Tamanho do Palito" para ajustar o tamanho dos palitos.',
              semanticsDescription:
                  'Use o controle deslizante Tamanho do Palito no menu lateral.',
            ),
           _buildInstructionItem(
              title: 'Criando Histórias',
              description:
                  'Abra o menu lateral (ícone de menu no canto superior esquerdo) e toque em "Criar História". Selecione as ações (movimentos e palitos) e o número de repetições para cada conjunto de ações. Toque em "Fazer História" para executar a sequência. Utilize o botão "Novo" para adicionar um novo conjunto de ações e repetições e o botão "Excluir" para remover um conjunto específico.  Ative a narração para que cada ação executada durante a história seja narrada.',
              semanticsDescription:
                  'Use a opção "Criar História" no menu lateral.',
            ),
            _buildInstructionItem(
              title: 'Velocidade da Narração',
              description:
                  'Abra o menu lateral (ícone de menu no canto superior esquerdo) e ajuste a velocidade da narração da história no menu lateral utilizando o controle deslizante "Velocidade da Narração".',
              semanticsDescription:
                  'Use o controle deslizante "Velocidade da Narração" no menu lateral .',
            ),
             _buildInstructionItem(
              title: 'Contador de Palitos',
              description:
                  'Abra o menu lateral (ícone de menu no canto superior esquerdo) e toque em "Contador de Palitos" para exibir a quantidade de palitos na tela.',
              semanticsDescription:
                  'Use a opção "Contador de Palitos" no menu lateral.',
            ),
            _buildInstructionItem(
              title: 'Narração',
              description:
                  'Ative o interruptor \'Narração\' na barra superior para receber feedback por voz. Quando ativada, a narração informa: (1) a posição do personagem (linha e coluna) a cada salto; (2) a localização de um palito recém-adicionado; (3) cada ação executada durante a criação de uma história; e (4) a posição do personagem ao tocar sobre ele.',
              semanticsDescription:
                  'Ative "Narração" para ouvir posição do personagem, localização de palitos e ações da história.',
            ),
             _buildInstructionItem(
              title: 'Salto Automático',
              description:
                  'Ative o interruptor \'Salto Automático\' na barra superior para que o personagem salte automaticamente após cada palito adicionado exceto com o Palito Diagonal à Esquerda. Mapeamento dos saltos: Palito Horizontal → salta para direita; Palito Vertical → salta para cima; Palito Diagonal à Direita → salta para direita; Palito Diagonal à Esquerda → não salta.',
              semanticsDescription:
                  'Ative "Salto Automático" para saltar após adicionar palitos (H: direita, V: cima, DD: direita; DE: sem salto).',
            ),
             _buildInstructionItem(
              title: 'Localizar Palitos',
              description:
                  'No menu lateral, toque na opção \'Localizar Palitos\'. O aplicativo narrará a posição (coluna e linha) de todos os palitos que estão atualmente na tela.',
              semanticsDescription:
                  'Use a opção "Localizar Palitos" no menu lateral para ouvir a localização de todos os palitos na tela.',
            ),
            _buildInstructionItem(
              title: 'Sair',
              description:
                  'Na barra superior, toque em \'Sair\' para fechar o aplicativo.',
              semanticsDescription: 'Toque em "Sair" para fechar o aplicativo.',
            ), 
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
      {required String title,
      required String description,
      required String semanticsDescription}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: title,
          header: false,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueAccent,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: semanticsDescription,
          child: Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 20,
        ),
      ],
    );
  }
}