# Como Adicionar Áudios das Cartas

## Estrutura de Arquivos de Áudio

Para que a funcionalidade de áudio funcione corretamente, você precisa adicionar os arquivos de áudio nas seguintes pastas:

### Cartas do Dia
- **Pasta**: `assets/audios_cartas_dia/`
- **Arquivos**: 50 arquivos de áudio (carta_1.mp3 até carta_50.mp3)

### Cartas da Organização
- **Pasta**: `assets/audios_cartas_org/`
- **Arquivos**: 50 arquivos de áudio (carta_1.mp3 até carta_50.mp3)

## Formatos de Nome Suportados

O sistema procura pelos arquivos de áudio nos seguintes formatos (em ordem de prioridade):

1. `carta_X.mp3` (onde X é o número da carta)
2. `cartaX.mp3`
3. `Carta_X.mp3`
4. `CartaX.mp3`
5. `audio_X.mp3`
6. `audioX.mp3`
7. `Audio_X.mp3`
8. `AudioX.mp3`
9. `X.mp3`
10. `carta_0X.mp3` (com zero à esquerda)
11. `audio_0X.mp3` (com zero à esquerda)

## Formatos de Áudio Suportados

- **MP3** (recomendado)
- **M4A**
- **WAV**
- **AAC**

## Exemplo de Estrutura de Pastas

```
assets/
  audios_cartas_dia/
    carta_1.mp3
    carta_2.mp3
    carta_3.mp3
    ...
    carta_50.mp3
  audios_cartas_org/
    carta_1.mp3
    carta_2.mp3
    carta_3.mp3
    ...
    carta_50.mp3
```

## Como Funciona

1. Quando o usuário seleciona uma carta, o sistema automaticamente:
   - Procura pelo arquivo de áudio correspondente
   - Inicia a reprodução automaticamente se o arquivo for encontrado
   - Exibe controles de áudio (play/pause/stop)
   - Mostra uma mensagem se o áudio não estiver disponível

2. **Controles de Áudio**:
   - **Play/Pause**: Controla a reprodução do áudio
   - **Stop**: Para completamente o áudio
   - **Status**: Mostra se está reproduzindo, pausado ou parado

3. **Recursos**:
   - Reprodução automática ao abrir a carta
   - Controles visuais intuitivos
   - Suporte a múltiplos formatos de áudio
   - Cache inteligente para melhor performance
   - Para automaticamente outros áudios quando uma nova carta é aberta

## Recomendações

- **Qualidade de Áudio**: Use MP3 com qualidade de 128-192 kbps para equilibrar qualidade e tamanho do arquivo
- **Duração**: Recomenda-se áudios de 1-5 minutos para melhor experiência do usuário
- **Nomeação**: Use o formato `carta_X.mp3` para consistência
- **Teste**: Teste todos os áudios antes de publicar o aplicativo

## Exemplo de Implementação

Se você tiver os arquivos de texto das cartas, pode usar serviços de text-to-speech como:
- Google Text-to-Speech
- Amazon Polly
- Azure Speech Services
- Microsoft Speech Platform

Para criar áudios naturais e de qualidade das mensagens das cartas.