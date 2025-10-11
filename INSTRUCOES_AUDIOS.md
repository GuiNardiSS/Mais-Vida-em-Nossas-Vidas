# Instruções para Organizar os Áudios Manualmente

## Passo a Passo:

### 1. Estrutura dos seus áudios:
- Você tem 100 arquivos de áudio numerados de 1 a 100
- Arquivos 1-50: Para as "Cartas do Dia"
- Arquivos 51-100: Para as "Cartas da Organização"

### 2. Como organizar:

#### Para Cartas do Dia (arquivos 1-50):
- Copie os arquivos numerados de 1 a 50 para: `assets/audios_cartas_dia/`
- Renomeie para: `carta_1.mp3`, `carta_2.mp3`, ..., `carta_50.mp3`

#### Para Cartas da Organização (arquivos 51-100):
- Copie os arquivos numerados de 51 a 100 para: `assets/audios_cartas_org/`
- Renomeie para: `carta_1.mp3`, `carta_2.mp3`, ..., `carta_50.mp3`
  - Exemplo: arquivo "51.mp3" vira "carta_1.mp3"
  - Exemplo: arquivo "52.mp3" vira "carta_2.mp3"
  - ...
  - Exemplo: arquivo "100.mp3" vira "carta_50.mp3"

### 3. Opções de Execução:

#### Opção A - Script Automático:
1. Execute o PowerShell como Administrador
2. Navegue até a pasta do projeto: `cd "C:\Users\guilh\Maisvidaemnossasvida\meu_app_flutter"`
3. Execute: `.\organizar_audios.ps1`

#### Opção B - Manual:
1. Abra as pastas:
   - Origem: `C:\Users\guilh\OneDrive\Documentos\Audios Cartas`
   - Destino 1: `C:\Users\guilh\Maisvidaemnossasvida\meu_app_flutter\assets\audios_cartas_dia`
   - Destino 2: `C:\Users\guilh\Maisvidaemnossasvida\meu_app_flutter\assets\audios_cartas_org`

2. Copie e renomeie conforme descrito acima

### 4. Formatos Suportados:
- MP3 (recomendado)
- WAV
- M4A
- AAC

### 5. Verificação:
Após organizar os arquivos, você deve ter:
- 50 arquivos em `assets/audios_cartas_dia/`
- 50 arquivos em `assets/audios_cartas_org/`
- Todos nomeados como `carta_X.mp3` (onde X vai de 1 a 50)