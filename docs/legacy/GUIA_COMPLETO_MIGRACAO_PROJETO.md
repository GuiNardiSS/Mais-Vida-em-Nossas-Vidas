# 📚 Guia Completo de Migração do Projeto - Mais Vida em Nossas Vidas

## 📋 Índice

1. [Visão Geral do Projeto](#visão-geral-do-projeto)
2. [Tecnologias Utilizadas](#tecnologias-utilizadas)
3. [Estrutura do Projeto](#estrutura-do-projeto)
4. [Configuração do Ambiente](#configuração-do-ambiente)
5. [Backend (Node.js + MongoDB)](#backend-nodejs--mongodb)
6. [Frontend (Flutter)](#frontend-flutter)
7. [Sistema de Pagamentos](#sistema-de-pagamentos)
8. [Sistemas Implementados](#sistemas-implementados)
9. [Deploy e Produção](#deploy-e-produção)
10. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral do Projeto

**Nome:** Mais Vida em Nossas Vidas  
**Tipo:** Aplicativo Mobile de Espiritualidade  
**Plataforma:** Flutter (Android/iOS)  
**Backend:** Node.js + Express + MongoDB  
**Repositório GitHub:** GuiNardiSS/Mais-Vida-em-Nossas-Vidas  
**Branch Atual:** nome-da-branch

### Funcionalidades Principais

- 📖 **Cartas do Dia**: Cartas espirituais diárias com áudio
- 🎴 **Cartas de Organização**: Sistema de orientação organizacional com áudio
- 📚 **Conteúdo**: Vídeos, textos e materiais educativos
- 💳 **Sistema de Assinaturas**: PIX e Cartão de Crédito (Stripe)
- 🔒 **Sistema de Restrições**: Free vs Premium (implementado, mas desabilitado)
- 📊 **Sistema de Logging**: Monitoramento completo de eventos
- 🔔 **Notificações**: Sistema de notificações locais
- 👤 **Sem Login**: Sistema baseado em Device ID único

---

## 🛠️ Tecnologias Utilizadas

### Frontend (Flutter)

| Tecnologia | Versão | Descrição |
|------------|--------|-----------|
| Flutter SDK | >=3.0.0 <4.0.0 | Framework principal |
| Dart | >=3.0.0 | Linguagem de programação |
| flutter_stripe | ^12.0.2 | Integração com Stripe |
| http | ^1.2.2 | Requisições HTTP |
| shared_preferences | ^2.3.2 | Armazenamento local |
| flutter_secure_storage | ^9.2.4 | Armazenamento seguro |
| device_info_plus | ^10.1.0 | Informações do dispositivo |
| audioplayers | ^6.1.0 | Reprodução de áudio |
| video_player | ^2.8.7 | Reprodução de vídeo |
| sqflite | ^2.3.3+1 | Banco de dados local |
| crypto | ^3.0.3 | Criptografia (SHA256) |
| logger | ^2.4.0 | Sistema de logs |
| path_provider | ^2.1.4 | Acesso a diretórios |
| intl | ^0.20.2 | Internacionalização |
| qr_flutter | ^4.1.0 | Geração de QR Codes |
| flutter_local_notifications | ^19.4.1 | Notificações locais |
| url_launcher | ^6.3.0 | Abrir URLs externas |
| flutter_svg | ^2.0.10+1 | Suporte a SVG |
| font_awesome_flutter | ^10.7.0 | Ícones Font Awesome |
| mask_text_input_formatter | ^2.9.0 | Máscaras de input |

### Backend (Node.js)

| Tecnologia | Versão | Descrição |
|------------|--------|-----------|
| Node.js | 18+ | Runtime JavaScript |
| Express | ^4.19.2 | Framework web |
| MongoDB | 8.0+ | Banco de dados NoSQL |
| Mongoose | ^8.0.0 | ODM para MongoDB |
| Stripe | ^16.6.0 | Processamento de pagamentos |
| axios | ^1.7.2 | Cliente HTTP |
| jsonwebtoken | ^9.0.2 | Autenticação JWT |
| helmet | ^7.1.0 | Segurança HTTP |
| express-rate-limit | ^7.1.5 | Limitação de taxa |
| cors | ^2.8.5 | Controle de CORS |
| dotenv | ^16.4.5 | Variáveis de ambiente |

### Ferramentas de Desenvolvimento

- **VS Code**: Editor recomendado
- **Android Studio**: Emuladores e ferramentas Android
- **Git**: Controle de versão
- **MongoDB Compass**: Interface gráfica para MongoDB (opcional)
- **Postman**: Testes de API (opcional)

---

## 📁 Estrutura do Projeto

```
Maisvidaemnossasvida/
│
├── meu_app_flutter/                    # Aplicativo Flutter
│   ├── android/                        # Configurações Android
│   │   ├── app/
│   │   │   └── build.gradle.kts       # Config. do app Android
│   │   ├── build.gradle.kts           # Config. raiz Android
│   │   └── gradle.properties          # Propriedades Gradle
│   │
│   ├── ios/                           # Configurações iOS
│   │
│   ├── lib/                           # Código-fonte Flutter
│   │   ├── config/                    # Configurações do app
│   │   ├── dat/                       # Dados estáticos
│   │   ├── data/                      # Dados dinâmicos
│   │   │
│   │   ├── models/                    # (vazio - futuro uso)
│   │   │
│   │   ├── pages/                     # Telas do aplicativo
│   │   │   ├── assinaturas.dart       # Página de assinaturas
│   │   │   ├── audio_mapper.dart      # Mapeamento de áudios
│   │   │   ├── audio_validator.dart   # Validação de áudios
│   │   │   ├── cartas_do_dia.dart     # Cartas do dia
│   │   │   ├── cartas_intro.dart      # Introdução (tela inicial)
│   │   │   ├── cartas_organizacao.dart # Cartas de organização
│   │   │   ├── contato.dart           # Página de contato
│   │   │   ├── conteudo.dart          # Conteúdo educativo
│   │   │   ├── espiritualidade_dia.dart # Espiritualidade diária
│   │   │   ├── home.dart              # Tela principal
│   │   │   ├── inicio.dart            # Tela de início
│   │   │   ├── pagamento_cartao.dart  # Pagamento por cartão
│   │   │   └── pagamento_pix.dart     # Pagamento via PIX
│   │   │
│   │   ├── services/                  # Serviços e lógica
│   │   │   ├── app_logger.dart        # Sistema de logging
│   │   │   ├── audio_service.dart     # Serviço de áudio
│   │   │   ├── auth_service.dart      # Autenticação
│   │   │   ├── device_service.dart    # Gerenciamento de dispositivo
│   │   │   ├── logging_navigator_observer.dart # Observer de navegação
│   │   │   ├── notifications.dart     # Notificações
│   │   │   ├── palette.dart           # Paleta de cores
│   │   │   ├── payment_service.dart   # Serviço de pagamento
│   │   │   ├── prefs.dart             # Preferências locais
│   │   │   ├── route_observer.dart    # Observer de rotas
│   │   │   ├── secure_storage_service.dart # Armazenamento seguro
│   │   │   ├── subscription_service.dart # Gerenciamento de assinaturas
│   │   │   ├── theme_controller.dart  # Controle de tema
│   │   │   └── usage_restriction_service.dart # Restrições Free/Premium
│   │   │
│   │   ├── widgets/                   # Widgets reutilizáveis
│   │   │   ├── audio_control_widget.dart # Controle de áudio
│   │   │   ├── card_payment_dialog.dart # Diálogo de pagamento cartão
│   │   │   ├── decorative_icon.dart   # Ícone decorativo
│   │   │   ├── pix_payment_dialog.dart # Diálogo de pagamento PIX
│   │   │   ├── themed_logo.dart       # Logo temático
│   │   │   ├── video_player_widget.dart # Player de vídeo
│   │   │   └── video_popup_player.dart # Player popup
│   │   │
│   │   └── main.dart                  # Ponto de entrada
│   │
│   ├── assets/                        # Recursos (imagens, vídeos, áudios)
│   │   ├── assinaturas/               # Imagens de assinaturas
│   │   ├── audios_cartas_dia/         # Áudios das cartas do dia
│   │   ├── audios_cartas_org/         # Áudios das cartas de organização
│   │   ├── cartas_do_dia/             # Imagens cartas do dia
│   │   ├── cartas_do_dia_org/         # Imagens cartas organizadas
│   │   ├── conteudo/                  # Vídeos e conteúdo
│   │   ├── intro/                     # Recursos de introdução
│   │   ├── parceiros/                 # Logos de parceiros
│   │   └── perfil/                    # Imagens de perfil
│   │
│   ├── pubspec.yaml                   # Dependências Flutter
│   ├── analysis_options.yaml          # Opções de análise
│   │
│   └── Documentação/                  # Arquivos de documentação
│       ├── ANALISE_ORIENTACAO.md
│       ├── BUILD_SECURITY.md
│       ├── GUIA_RAPIDO_RESTRICOES.md
│       ├── INSTRUCOES_AUDIOS.md
│       ├── PROXIMOS_PASSOS.md
│       ├── README_IMPLEMENTACAO.md
│       ├── README.md
│       ├── SISTEMA_ASSINATURA_SEGURO.md
│       ├── SISTEMA_LOGGING.md
│       ├── SISTEMA_PAGAMENTO.md
│       ├── SISTEMA_RESTRICOES_IMPLEMENTADO.md
│       ├── SISTEMA_RESTRICOES.md
│       └── VIDEO_SETUP.md
│
└── meu_backend_node/                  # Backend Node.js
    ├── config/
    │   └── database.js                # Configuração MongoDB
    │
    ├── controllers/                   # Controladores da API
    │   ├── pixController.js           # Lógica PIX (3 provedores)
    │   ├── stripeController.js        # Lógica Stripe
    │   └── subscriptionController.js  # Lógica de assinaturas
    │
    ├── middleware/
    │   └── auth.js                    # Rate limiting e autenticação
    │
    ├── models/
    │   └── Subscription.js            # Modelo de assinatura (MongoDB)
    │
    ├── routes/                        # Rotas da API
    │   ├── pix.js                     # Rotas PIX
    │   ├── stripe.js                  # Rotas Stripe
    │   └── subscription.js            # Rotas de assinatura
    │
    ├── index.js                       # Servidor Express
    ├── package.json                   # Dependências Node.js
    ├── .env                           # Variáveis de ambiente (NÃO COMMITAR!)
    ├── .env.example                   # Template de .env
    │
    └── Documentação/
        ├── CONFIGURACAO_CONTAS.md     # Guia de config. de pagamentos
        └── README.md
```

---

## ⚙️ Configuração do Ambiente

### 1. Pré-requisitos

#### No Novo Computador, Instale:

**1.1. Flutter**
```bash
# Windows
# Baixe de: https://docs.flutter.dev/get-started/install/windows
# Extraia e adicione ao PATH

# Verifique a instalação
flutter doctor
```

**1.2. Android Studio**
```bash
# Baixe de: https://developer.android.com/studio
# Instale com Android SDK
# Configure o emulador Android
```

**1.3. Node.js**
```bash
# Baixe de: https://nodejs.org/ (versão 18 LTS ou superior)
# Instale o Node.js e npm

# Verifique a instalação
node --version
npm --version
```

**1.4. MongoDB**

Opção A - MongoDB Local:
```bash
# Baixe de: https://www.mongodb.com/try/download/community
# Instale e inicie o serviço

# Verificar se está rodando
mongod --version
```

Opção B - MongoDB Atlas (Cloud - Recomendado):
```
1. Acesse: https://www.mongodb.com/cloud/atlas
2. Crie uma conta gratuita
3. Crie um cluster gratuito
4. Obtenha a connection string
5. Use no .env: MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/maisvidaapp
```

**1.5. Git**
```bash
# Baixe de: https://git-scm.com/
# Instale o Git
git --version
```

**1.6. VS Code (Recomendado)**
```bash
# Baixe de: https://code.visualstudio.com/
# Instale as extensões:
- Flutter
- Dart
- ESLint
- Prettier
- MongoDB for VS Code (opcional)
```

---

### 2. Clonar o Repositório

```bash
# Clone o repositório
git clone https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas.git

# Entre na pasta
cd Mais-Vida-em-Nossas-Vidas

# Verifique a branch
git branch
# Deve estar em: nome-da-branch

# Se não estiver, mude para a branch correta
git checkout nome-da-branch
```

---

### 3. Configurar Backend

```bash
# Entre na pasta do backend
cd meu_backend_node

# Instale as dependências
npm install

# Crie o arquivo .env (copie do .env.example)
cp .env.example .env

# Abra o .env e configure (veja seção Backend abaixo)
```

**Configuração Mínima do `.env`:**

```env
# MongoDB (escolha uma opção)
MONGODB_URI=mongodb://localhost:27017/maisvidaapp
# OU
# MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/maisvidaapp

# JWT Secret (gere uma chave aleatória segura)
JWT_SECRET=sua-chave-secreta-aleatoria-aqui

# Stripe (modo teste)
STRIPE_SECRET_KEY=sk_test_sua_chave_aqui

# PIX Provider (escolha um)
PIX_PROVIDER=mercadopago
MERCADOPAGO_ACCESS_TOKEN=APP_USR-seu_token_aqui

# Sua chave PIX
PIX_KEY=seu-email@exemplo.com.br
PIX_KEY_TYPE=email
PIX_RECEIVER_NAME=Seu Nome
PIX_RECEIVER_DOCUMENT=12345678900
PIX_RECEIVER_CITY=Sao Paulo

# Servidor
PORT=3000
NODE_ENV=development
CORS_ORIGIN=*
```

**Iniciar o Backend:**

```bash
# Certifique-se de que o MongoDB está rodando
# Se local:
mongod

# Em outro terminal, inicie o backend
cd meu_backend_node
npm start

# Você deve ver:
# ✅ MongoDB conectado com sucesso
# ✅ API rodando na porta 3000
```

---

### 4. Configurar Flutter

```bash
# Entre na pasta do app Flutter
cd meu_app_flutter

# Limpe o cache (importante após clonar)
flutter clean

# Obtenha as dependências
flutter pub get

# Verifique se há problemas
flutter doctor -v

# Liste os dispositivos disponíveis
flutter devices

# Execute no emulador Android
flutter run

# OU execute especificando o dispositivo
flutter run -d emulator-5554
```

**Configurar Stripe (Android):**

O app já está configurado para Stripe. Verifique se o `pubspec.yaml` tem:

```yaml
dependencies:
  flutter_stripe: ^12.0.2
```

**Configurar URL do Backend:**

Abra `lib/services/payment_service.dart` e verifique a URL:

```dart
// Para emulador Android (10.0.2.2 aponta para localhost da máquina host)
static const String _baseUrl = 'http://10.0.2.2:3000';

// Para dispositivo físico, use o IP da sua máquina:
// static const String _baseUrl = 'http://192.168.1.100:3000';
```

**Descobrir seu IP local:**

```bash
# Windows
ipconfig

# Procure por "Endereço IPv4" na interface Wi-Fi ou Ethernet
```

---

## 🔙 Backend (Node.js + MongoDB)

### Arquitetura

O backend segue o padrão **MVC (Model-View-Controller)**:

- **Models**: Definição dos esquemas do MongoDB
- **Controllers**: Lógica de negócio
- **Routes**: Endpoints da API
- **Middleware**: Autenticação e rate limiting
- **Config**: Configuração do banco de dados

### Endpoints da API

#### Base URL (Desenvolvimento)
```
http://localhost:3000
```

#### Endpoints Disponíveis

**1. Health Check**
```
GET /health
Response: { status: 'ok', timestamp: '...', version: '1.0.0' }
```

**2. PIX**
```
POST /pix/gerar
Body: { valor: 29.90, deviceId: "abc123..." }
Response: {
  qrCode: "base64_image...",
  qrCodeText: "00020126...",
  transactionId: "TXN123..."
}
```

**3. Stripe (Cartão)**
```
POST /pagamento/criar-intent
Body: { valor: 29.90, deviceId: "abc123..." }
Response: {
  clientSecret: "pi_...secret",
  transactionId: "TXN123..."
}
```

**4. Assinaturas**
```
POST /subscription/activate
Body: {
  deviceId: "abc123...",
  transactionId: "TXN123",
  paymentMethod: "pix",
  amount: 29.90
}
Response: {
  success: true,
  subscription: { ... },
  token: "jwt_token..."
}

POST /subscription/validate
Body: { deviceId: "abc123..." }
Response: {
  isActive: true,
  status: "active",
  expiryDate: "2025-12-24T00:00:00.000Z",
  daysRemaining: 30
}

GET /subscription/info?deviceId=abc123
Response: {
  isActive: true,
  status: "active",
  startDate: "...",
  expiryDate: "...",
  daysRemaining: 30,
  paymentMethod: "pix"
}
```

### Modelo de Dados (MongoDB)

**Collection: `subscriptions`**

```javascript
{
  deviceId: String (unique, indexed),
  transactionId: String,
  paymentMethod: 'pix' | 'card',
  amount: Number,
  status: 'active' | 'expired' | 'cancelled' | 'pending',
  startDate: Date,
  expiryDate: Date,
  deviceInfo: {
    model: String,
    platform: String,
    version: String
  },
  createdAt: Date,
  updatedAt: Date
}
```

### Segurança Implementada

- ✅ **Helmet.js**: Headers HTTP seguros
- ✅ **CORS**: Controle de origem cruzada
- ✅ **Rate Limiting**: Proteção contra ataques
  - Geral: 30 requisições/minuto
  - Pagamentos: 5 requisições/15 minutos
  - Validações: 10 requisições/minuto
- ✅ **JWT**: Tokens de dispositivo (opcional)
- ✅ **Validação de Inputs**: Todos os dados são validados
- ✅ **Error Handling**: Tratamento global de erros

### Configuração de Pagamentos

Para configurar os provedores de pagamento (Stripe e PIX), consulte:

📖 **`meu_backend_node/CONFIGURACAO_CONTAS.md`**

Este documento contém instruções passo a passo para:
- Criar conta no Stripe e configurar cartão
- Escolher provedor PIX (Mercado Pago, Asaas ou Efi)
- Obter credenciais de API
- Configurar chave PIX
- Testar pagamentos

---

## 📱 Frontend (Flutter)

### Estrutura de Páginas

**Fluxo de Navegação:**

```
CartasIntroPage (inicial)
    ↓
HomePage (menu principal)
    ├── CartasDoDiaPage
    ├── CartasOrganizacaoPage
    ├── ConteudoPage
    ├── EspiritualidadeDiaPage
    ├── AssinaturasPage
    │   ├── PagamentoPix
    │   └── PagamentoCartao
    └── ContatoPage
```

### Serviços Principais

**1. DeviceService** (`device_service.dart`)
- Gera ID único do dispositivo (SHA256)
- Usado para identificar assinaturas sem login
- Armazenado em SharedPreferences

```dart
final deviceId = await DeviceService.getDeviceId();
```

**2. SubscriptionService** (`subscription_service.dart`)
- Gerencia status de assinatura (Free/Premium)
- Sincroniza com backend a cada 24h
- Cache local para funcionamento offline

```dart
final isPremium = await SubscriptionService.isPremium();
```

**3. PaymentService** (`payment_service.dart`)
- Integra com backend para pagamentos
- Suporta PIX e Cartão (Stripe)
- Tratamento de erros e timeouts

```dart
final result = await PaymentService.gerarPagamentoPix(29.90, deviceId);
```

**4. UsageRestrictionService** (`usage_restriction_service.dart`)
- Sistema de restrições Free/Premium
- **DESABILITADO por padrão** (`restricoesAtivas = false`)
- Limita cartas e conteúdo para usuários gratuitos

```dart
final canSelect = await UsageRestrictionService.canSelectCartaDia();
```

**5. AppLogger** (`app_logger.dart`)
- Sistema completo de logging
- Registra navegação, pagamentos, erros
- Logs salvos em arquivos diários

```dart
appLogger.info('Evento importante', data: {...});
```

**6. NotificationsService** (`notifications.dart`)
- Notificações locais
- Agendamento de lembretes
- Configurável pelo usuário

```dart
await NotificationsService.scheduleEvery3Hours();
```

### Paleta de Cores

Definida em `services/palette.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF2C5530);       // Verde escuro
  static const Color secondary = Color(0xFFD4A574);     // Dourado claro
  static const Color accent = Color(0xFFF5F1E8);        // Bege claro
  static const Color scaffold = Color(0xFFFFFBF5);      // Branco quente
  static const Color logoPrimary = Color(0xFF3B7A40);   // Verde médio
  static const Color logoGold = Color(0xFFD4A574);      // Dourado
}
```

### Assets

**Organização dos Assets:**

```
assets/
├── assinaturas/          # Imagens para página de assinaturas
├── audios_cartas_dia/    # 45 áudios (carta_1.mp3 a carta_45.mp3)
├── audios_cartas_org/    # 45 áudios organizados
├── cartas_do_dia/        # 45 imagens (carta_1.jpg a carta_45.jpg)
├── cartas_do_dia_org/    # Versões organizadas
├── conteudo/             # Vídeos e materiais
├── intro/                # Recursos de introdução
├── parceiros/            # Logos de parceiros
└── perfil/               # Imagens de perfil
```

**Nomenclatura Importante:**
- Cartas: `carta_1.jpg` a `carta_45.jpg` (com underscore)
- Áudios: `carta_1.mp3` a `carta_45.mp3` (com underscore)

### Configuração do pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2
  flutter_stripe: ^12.0.2
  http: ^1.2.2
  flutter_local_notifications: ^19.4.1
  url_launcher: ^6.3.0
  video_player: ^2.8.7
  mask_text_input_formatter: ^2.9.0
  qr_flutter: ^4.1.0
  font_awesome_flutter: ^10.7.0
  audioplayers: ^6.1.0
  flutter_svg: ^2.0.10+1
  device_info_plus: ^10.1.0
  crypto: ^3.0.3
  sqflite: ^2.3.3+1
  path: ^1.9.0
  logger: ^2.4.0
  path_provider: ^2.1.4
  intl: ^0.20.2
  flutter_secure_storage: ^9.2.4

flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/cartas_do_dia/
    - assets/cartas_do_dia_org/
    - assets/parceiros/
    - assets/conteudo/
    - assets/audios_cartas_dia/
    - assets/audios_cartas_org/
    - assets/perfil/
    - assets/assinaturas/
    - assets/intro/
```

---

## 💳 Sistema de Pagamentos

### Fluxo de Pagamento

**1. PIX:**
```
1. Usuário vai em Assinaturas
2. Clica em "Assinar com PIX"
3. Backend gera QR Code
4. Usuário paga via app bancário
5. Usuário clica "Já paguei"
6. Backend ativa assinatura
7. App sincroniza e libera conteúdo
```

**2. Cartão de Crédito:**
```
1. Usuário vai em Assinaturas
2. Clica em "Assinar com Cartão"
3. Preenche dados do cartão
4. Stripe processa pagamento
5. Backend ativa assinatura
6. App sincroniza e libera conteúdo
```

### Valores de Assinatura

Configurado em `pages/assinaturas.dart`:

```dart
// Valores atuais
R$ 29,90 - Mensal
R$ 9,90  - Teste/Promocional
```

### Integração com Provedores

**Stripe (Cartão):**
- Chave pública configurada no app
- Payment Intent criado no backend
- Pagamento processado via SDK Flutter

**PIX:**
- 3 provedores suportados:
  - Mercado Pago (Recomendado)
  - Asaas
  - Efi (Gerencianet)
- QR Code gerado no backend
- Confirmação manual ou via webhook

### Testes de Pagamento

**Cartão de Teste (Stripe):**
```
Número: 4242 4242 4242 4242
Data: 12/28 (qualquer futura)
CVV: 123 (qualquer)
Nome: Qualquer
```

**PIX de Teste:**
```
Em modo desenvolvimento, o backend gera QR Codes fictícios.
Clique em "Já paguei" para simular pagamento.
```

---

## 🔧 Sistemas Implementados

### 1. Sistema de Assinaturas Seguro (SEM LOGIN)

✅ **Status:** Implementado e funcional

**Características:**
- Identificação por Device ID único (SHA256)
- Sem necessidade de cadastro/login
- Sincronização automática com backend
- Cache local para funcionamento offline
- Validação a cada 24h

**Documentação Completa:**
📖 `meu_app_flutter/SISTEMA_ASSINATURA_SEGURO.md`

**Como Funciona:**
1. App gera Device ID único ao iniciar
2. Device ID é usado em todas as transações
3. Backend registra: Device ID + Transaction ID + Data Expiração
4. App valida status periodicamente
5. Conteúdo liberado automaticamente para Premium

**Testar:**
```dart
// Ativar assinatura de teste
await SubscriptionService.activateSubscription(
  'teste-123',
  SubscriptionStatus.active,
  DateTime.now().add(Duration(days: 30)),
);

// Verificar status
final isPremium = await SubscriptionService.isPremium();
print('É Premium? $isPremium');

// Limpar (resetar)
await SubscriptionService.clearSubscription();
```

---

### 2. Sistema de Restrições FREE/PREMIUM

✅ **Status:** Implementado e **DESABILITADO**

**Características:**
- Sistema completo de limitação Free/Premium
- **Flag de controle:** `restricoesAtivas = false` (DESABILITADO)
- Usuários Free: 1 carta/dia + sem conteúdo premium
- Usuários Premium: Ilimitado

**Documentação Completa:**
📖 `meu_app_flutter/SISTEMA_RESTRICOES_IMPLEMENTADO.md`

**Como Ativar:**

Abra `lib/services/usage_restriction_service.dart` e altere:

```dart
// Linha 10
static const bool restricoesAtivas = true; // Mude de false para true
```

**Páginas Integradas:**
- ✅ `cartas_do_dia.dart` - Limite de 1 carta/dia para Free
- ✅ `cartas_organizacao.dart` - Limite de 1 carta/dia para Free
- ✅ `conteudo.dart` - Marca conteúdo como `premiumOnly: true`

---

### 3. Sistema de Logging Completo

✅ **Status:** Implementado e ativo

**Características:**
- Logging automático de navegação
- Registro de pagamentos e assinaturas
- Logs de erros e exceções
- Salvamento em arquivos diários
- Rotação automática (7 dias)
- Performance tracking

**Documentação Completa:**
📖 `meu_app_flutter/SISTEMA_LOGGING.md`

**Níveis de Log:**
```dart
appLogger.debug('Debug info');
appLogger.info('Informação geral');
appLogger.warning('Aviso');
appLogger.error('Erro', error: e, stackTrace: st);
appLogger.fatal('Erro crítico', error: e, stackTrace: st);
```

**Logs Automáticos:**
- Navegação entre páginas
- Tempo em cada página
- Transações de pagamento
- Ativação/validação de assinaturas
- Erros e exceções

**Localização dos Logs:**
```
/storage/emulated/0/Android/data/com.example.meu_app_flutter/files/logs/
├── app_2025-11-24.log
├── app_2025-11-25.log
└── app_2025-11-26.log
```

**Exportar Logs:**
```dart
final exportedFile = await appLogger.exportLogs();
```

---

### 4. Sistema de Notificações

✅ **Status:** Implementado

**Características:**
- Notificações locais (não requer servidor)
- Agendamento de lembretes
- Notificações a cada 3 horas (opcional)
- Configurável pelo usuário

**Uso:**
```dart
// Agendar notificações
await NotificationsService.scheduleEvery3Hours();

// Cancelar notificações
await NotificationsService.cancelAll();
```

---

## 🚀 Deploy e Produção

### Deploy do Backend

**Opções Recomendadas (Gratuitas com HTTPS):**

**1. Render** (Recomendado)
```bash
1. Crie uma conta em: https://render.com
2. Conecte seu repositório GitHub
3. Crie um "Web Service"
4. Configure:
   - Build Command: npm install
   - Start Command: npm start
   - Environment Variables: Adicione todas do .env
5. Deploy automático a cada push!
```

**2. Railway**
```bash
1. Acesse: https://railway.app
2. Conecte GitHub
3. Deploy o repositório
4. Configure variáveis de ambiente
5. Pronto!
```

**3. Heroku**
```bash
# Instale Heroku CLI
npm install -g heroku

# Login
heroku login

# Crie app
cd meu_backend_node
heroku create seu-app-nome

# Configure variáveis de ambiente
heroku config:set MONGODB_URI=sua_uri
heroku config:set STRIPE_SECRET_KEY=sua_chave
# ... outras variáveis

# Deploy
git push heroku nome-da-branch:main

# Abra o app
heroku open
```

**Configurações Importantes para Produção:**

```env
NODE_ENV=production
MONGODB_URI=mongodb+srv://...  # Use MongoDB Atlas
STRIPE_SECRET_KEY=sk_live_...   # Chave de produção
CORS_ORIGIN=https://seu-dominio.com  # Domínio específico
```

### Deploy do Flutter

**Android (Google Play Store):**

```bash
# 1. Configure o app para release
# Edite android/app/build.gradle.kts
# Já está configurado!

# 2. Crie uma keystore (primeira vez)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 3. Configure key.properties
# Crie android/key.properties:
storePassword=senha-keystore
keyPassword=senha-key
keyAlias=upload
storeFile=caminho/para/upload-keystore.jks

# 4. Build release
flutter build appbundle --release

# 5. Upload para Play Console
# Arquivo gerado: build/app/outputs/bundle/release/app-release.aab
```

**iOS (App Store):**

```bash
# 1. Configure no Xcode
open ios/Runner.xcworkspace

# 2. Configure certificados (requer conta Apple Developer)

# 3. Build
flutter build ios --release

# 4. Archive no Xcode e envie para App Store Connect
```

### Configurar URL do Backend em Produção

Após fazer deploy do backend, atualize a URL no app:

**Abra:** `lib/services/payment_service.dart`

```dart
// Mude de:
static const String _baseUrl = 'http://10.0.2.2:3000';

// Para:
static const String _baseUrl = 'https://seu-backend.onrender.com';
```

Depois, reconstrua o app:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 🐛 Troubleshooting

### Problemas Comuns e Soluções

**1. "Failed to connect to backend"**

✅ Solução:
```bash
# Verifique se o backend está rodando
curl http://localhost:3000/health

# Se não estiver, inicie:
cd meu_backend_node
npm start

# No emulador Android, use:
# http://10.0.2.2:3000 (não localhost)

# Em dispositivo físico, use o IP da máquina:
# http://192.168.1.100:3000
```

**2. "MongoDB connection error"**

✅ Solução:
```bash
# Certifique-se de que o MongoDB está rodando
mongod

# OU use MongoDB Atlas (cloud)
# Configure MONGODB_URI no .env
```

**3. "Stripe not configured"**

✅ Solução:
```bash
# Verifique o .env:
STRIPE_SECRET_KEY=sk_test_sua_chave

# Obtenha a chave em:
# https://dashboard.stripe.com/apikeys
```

**4. "Flutter build failed"**

✅ Solução:
```bash
# Limpe o cache e reconstrua
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

**5. "Asset not found"**

✅ Solução:
```bash
# Verifique se os assets estão no lugar certo:
ls assets/cartas_do_dia/carta_1.jpg

# Verifique o pubspec.yaml:
# assets:
#   - assets/cartas_do_dia/

# Reconstrua:
flutter clean
flutter pub get
```

**6. "Device ID is null"**

✅ Solução:
```dart
// Limpe os dados e reinicie o app
await DeviceService.clearDeviceId();
// Reinicie o app
```

**7. "Permission denied (Android)"**

✅ Solução:
```xml
<!-- Verifique AndroidManifest.xml -->
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Adicione as permissões necessárias: -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**8. "Rate limit exceeded"**

✅ Solução:
```bash
# Aguarde alguns minutos
# O backend tem rate limiting configurado

# Se for desenvolvimento, você pode ajustar em:
# meu_backend_node/middleware/auth.js
```

---

## 📝 Checklist de Migração

Use este checklist para garantir que tudo está configurado:

### Ambiente de Desenvolvimento

- [ ] Flutter SDK instalado (`flutter doctor`)
- [ ] Android Studio instalado
- [ ] Emulador Android configurado
- [ ] Node.js instalado (v18+)
- [ ] MongoDB instalado ou Atlas configurado
- [ ] Git instalado
- [ ] VS Code + extensões instaladas

### Repositório

- [ ] Repositório clonado
- [ ] Branch correta (`nome-da-branch`)
- [ ] Estrutura de pastas verificada

### Backend

- [ ] Dependências instaladas (`npm install`)
- [ ] Arquivo `.env` criado e configurado
- [ ] MongoDB conectado
- [ ] Stripe configurado (chave de teste)
- [ ] PIX configurado (escolhido provedor)
- [ ] Backend iniciando sem erros (`npm start`)
- [ ] Health check funcionando (`GET /health`)

### Flutter

- [ ] Dependências instaladas (`flutter pub get`)
- [ ] URL do backend configurada
- [ ] Assets verificados
- [ ] App compilando sem erros
- [ ] Executando no emulador

### Testes

- [ ] Navegação entre páginas funcionando
- [ ] Cartas do Dia exibindo corretamente
- [ ] Áudios reproduzindo
- [ ] Vídeos reproduzindo
- [ ] Pagamento PIX testado
- [ ] Pagamento Cartão testado
- [ ] Assinatura ativando corretamente
- [ ] Sistema de logs funcionando

### Produção (Quando pronto)

- [ ] Chaves de produção configuradas (Stripe, PIX)
- [ ] MongoDB Atlas configurado
- [ ] Backend deployado (Render/Railway/Heroku)
- [ ] HTTPS ativado
- [ ] CORS configurado corretamente
- [ ] App buildado para release
- [ ] Testado em dispositivo físico

---

## 📞 Suporte e Recursos

### Documentação Adicional

- **Assinaturas:** `meu_app_flutter/SISTEMA_ASSINATURA_SEGURO.md`
- **Restrições:** `meu_app_flutter/SISTEMA_RESTRICOES_IMPLEMENTADO.md`
- **Logging:** `meu_app_flutter/SISTEMA_LOGGING.md`
- **Pagamentos:** `meu_backend_node/CONFIGURACAO_CONTAS.md`
- **Backend:** `meu_backend_node/README.md`

### Links Úteis

**Flutter:**
- Documentação: https://docs.flutter.dev/
- Pub.dev: https://pub.dev/
- Flutter Community: https://flutter.dev/community

**Node.js:**
- Documentação: https://nodejs.org/docs/
- npm: https://www.npmjs.com/

**MongoDB:**
- Documentação: https://www.mongodb.com/docs/
- Atlas: https://www.mongodb.com/cloud/atlas
- Compass: https://www.mongodb.com/products/compass

**Stripe:**
- Dashboard: https://dashboard.stripe.com/
- Documentação: https://stripe.com/docs
- Testes: https://stripe.com/docs/testing

**Mercado Pago:**
- Dashboard: https://www.mercadopago.com.br/
- Developers: https://www.mercadopago.com.br/developers

### Comandos Rápidos

**Flutter:**
```bash
flutter clean              # Limpar cache
flutter pub get            # Instalar dependências
flutter doctor             # Verificar instalação
flutter devices            # Listar dispositivos
flutter run                # Executar app
flutter build apk          # Build APK (debug)
flutter build appbundle    # Build AAB (release)
```

**Backend:**
```bash
npm install                # Instalar dependências
npm start                  # Iniciar servidor
npm run dev                # Modo desenvolvimento (se configurado)
```

**MongoDB:**
```bash
mongod                     # Iniciar MongoDB local
mongo                      # Abrir shell
mongodump                  # Backup
mongorestore               # Restaurar backup
```

**Git:**
```bash
git status                 # Ver mudanças
git add .                  # Adicionar tudo
git commit -m "msg"        # Commitar
git push                   # Enviar para GitHub
git pull                   # Atualizar do GitHub
git branch                 # Ver branches
git checkout nome-branch   # Mudar de branch
```

---

## 🎯 Próximos Passos Recomendados

1. **Implementar Renovação Automática**
   - Integrar webhooks do Stripe
   - Notificar usuários próximo à expiração
   - Sistema de lembretes

2. **Dashboard Administrativo**
   - Painel web para visualizar assinaturas
   - Relatórios de pagamentos
   - Gestão de usuários

3. **Mais Conteúdo**
   - Adicionar mais vídeos
   - Sistema de favoritos
   - Histórico de cartas selecionadas

4. **Gamificação**
   - Sistema de pontos/badges
   - Streak de dias consecutivos
   - Conquistas

5. **Social**
   - Compartilhar cartas nas redes sociais
   - Sistema de referência (indique e ganhe)

6. **Analytics**
   - Firebase Analytics
   - Google Analytics
   - Monitoramento de conversão

7. **Testes**
   - Testes unitários
   - Testes de integração
   - Testes E2E

---

## 📄 Informações do Projeto

**Versão:** 1.0.0  
**Última Atualização:** 24 de Novembro de 2025  
**Repositório:** https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas  
**Branch:** nome-da-branch  
**Licença:** Proprietária

**Desenvolvedor:** Guilherme Nardi  
**Contato:** [Adicione seu contato aqui]

---

## ✅ Resumo Executivo

Este projeto é um **aplicativo mobile de espiritualidade** completo com:

✅ **45 cartas** com imagens e áudios  
✅ **Sistema de assinaturas** (PIX + Cartão)  
✅ **Backend robusto** com Node.js + MongoDB  
✅ **Sem necessidade de login** (Device ID)  
✅ **Sistema de restrições Free/Premium** (desabilitado)  
✅ **Logging completo** de eventos  
✅ **Segurança** (Helmet, Rate Limiting, JWT)  
✅ **Pronto para produção** (com configurações)

**Stack Tecnológica:**
- Frontend: Flutter 3.0+ (Dart)
- Backend: Node.js 18+ (Express)
- Banco de Dados: MongoDB
- Pagamentos: Stripe + PIX (3 provedores)
- Deploy: Render/Railway/Heroku (backend) + Google Play/App Store (app)

**Para Migrar:**
1. Clone o repositório
2. Configure ambiente (Flutter + Node + MongoDB)
3. Configure .env no backend
4. Instale dependências
5. Execute e teste
6. Deploy quando pronto

**Tudo está documentado, testado e pronto para uso!** 🚀

---

**Bom desenvolvimento e sucesso com o projeto! 💚✨**
