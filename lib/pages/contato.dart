import 'package:flutter/material.dart';

class ContatoPage extends StatelessWidget {
  const ContatoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contato'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 16),
              Text(
                'Quem é Helô Coelho?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Sou Administradora, mentora, consultora e palestrante com uma sólida trajetória de 30 anos no empreendedorismo e na gestão empresarial. Atuei como idealizadora de ações e de eventos que impulsionaram empreendedores e líderes, contribuindo para o fortalecimento e visibilidade de novos negócios no mercado.\n\n'
                'Minha paixão pela comunicação me levou a expandir minha atuação no segmento de TV. Além de exercer a função de CEO nacional da TV Padrão Brasil, ao longo dessa jornada me dediquei a conectar histórias, inspirar pessoas e líderes e iniciativas que fazem a diferença no mundo dos negócios.\n\n'
                'Atualmente, também sou Pós-graduada em Neurociências do Comportamento e Desenvolvimento Humano, idealizadora da Espiritualidade na Prática Clínica, Inovação da Espiritualidade nas Relações e Brancas. Acredito que a espiritualidade é um pilar essencial para o desenvolvimento humano nas pautas do autoconhecimento, autogestão e propósito de vida, em ambientes organizacionais e na vida pessoal.\n\n'
                'Minha missão é inspirar pessoas a encontrarem sentido e propósito em suas jornadas, promovendo a dedicação e estudo da influência da espiritualidade nas relações humanas e no ambiente de trabalho, para que haja mais integração, bem-estar e felicidade.\n\n'
                'Através dos meus projetos, cursos, mentorias e palestras, busco compartilhar conhecimento e experiências que auxiliem na construção de um mundo melhor.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'Contatos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'E-mail   Instagram   Whatsapp\nYoutube   Linkedin',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
