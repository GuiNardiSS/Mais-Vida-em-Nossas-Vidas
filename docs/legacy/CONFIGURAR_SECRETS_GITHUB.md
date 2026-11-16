# 🔐 Configurar Secrets do GitHub para Build APK

## ⚠️ IMPORTANTE: Configure ANTES de rodar o workflow!

O build do APK requer 4 secrets configurados no GitHub Actions.

---

## 📋 Passo a Passo

### 1. Acesse as configurações de Secrets

Vá para: **https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/settings/secrets/actions**

### 2. Configure os 4 Secrets

Clique em **"New repository secret"** para cada um:

#### 🔑 Secret 1: `KEYSTORE_BASE64`

**Comando para gerar:**
```bash
cd /workspaces/Mais-Vida-em-Nossas-Vidas
base64 -w 0 android/maisvidaapp-release.jks
```

**Valor:** Cole a saída do comando acima (será uma string longa, ~5800 caracteres)

---

#### 🔑 Secret 2: `KEY_ALIAS`

**Valor:** `maisvidaapp`

---

#### 🔑 Secret 3: `KEY_PASSWORD`

**Valor:** `maisvidaapp2026`

---

#### 🔑 Secret 4: `STORE_PASSWORD`

**Valor:** `maisvidaapp2026`

---

## ✅ Validação

Depois de configurar, o workflow irá validar automaticamente:
- Se os secrets existem
- Se o keystore pode ser decodificado
- Se o alias e senhas estão corretos

Se alguma validação falhar, o build para **antes** de tentar compilar, economizando tempo.

---

## 🚀 Rodar o Build

Após configurar os secrets:

1. Acesse: https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/actions/workflows/build-apk.yml
2. Clique "Run workflow"
3. Escolha branch `nome-da-branch`
4. Clique "Run workflow"

O APK estará em "Artifacts" após ~18-25 minutos.
