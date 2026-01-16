# 🚀 Guia: Gerar APK via GitHub Actions

## 📋 Passos para Configurar

### 1️⃣ Adicionar Secrets no GitHub

Acesse: `https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/settings/secrets/actions`

Clique em **"New repository secret"** e adicione os seguintes secrets:

#### Secret 1: `KEYSTORE_BASE64`
Cole o valor abaixo (copie TUDO):
```
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
```

#### Secret 2: `KEY_ALIAS`
```
maisvidaapp
```

#### Secret 3: `KEY_PASSWORD`
```
maisvidaapp2026
```

#### Secret 4: `STORE_PASSWORD`
```
maisvidaapp2026
```

---

### 2️⃣ Fazer Commit e Push

No terminal do codespace, execute:

```bash
cd /workspaces/Mais-Vida-em-Nossas-Vidas
git add .github/workflows/build-apk.yml
git add android/key.properties
git commit -m "feat: adiciona workflow para gerar APK via GitHub Actions"
git push origin nome-da-branch
```

---

### 3️⃣ Executar o Workflow

**Opção A - Executar Manualmente:**
1. Acesse: `https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/actions`
2. Clique em **"Build Android APK"**
3. Clique em **"Run workflow"**
4. Selecione a branch `nome-da-branch`
5. Clique em **"Run workflow"** (botão verde)

**Opção B - Automático:**
O workflow roda automaticamente quando você faz push para `main` ou `nome-da-branch`

---

### 4️⃣ Baixar o APK

Após 5-10 minutos (tempo de compilação):

1. Volte em **Actions**
2. Clique no workflow executado (com ✅ verde)
3. Role até **"Artifacts"** no final da página
4. Clique em **"app-release-apk"** para baixar

O APK estará pronto para instalar no seu celular! 🎉

---

## 📱 Instalar no Celular

1. Transfira o APK para o celular
2. Ative **"Instalar de fontes desconhecidas"**
3. Abra o APK e instale

---

## ⚠️ IMPORTANTE: Backup

Faça backup dos arquivos:
- `android/maisvidaapp-release.jks`
- `android/key.properties`

Sem eles, você não conseguirá atualizar o app na Play Store!

---

## 🔧 Solução de Problemas

### Erro: "No valid keystore found"
- Verifique se os secrets foram adicionados corretamente
- Confira se copiou o KEYSTORE_BASE64 completo

### Erro de build
- Verifique os logs na aba Actions
- Procure por linhas vermelhas indicando o erro

### APK não instala
- Verifique se o celular permite instalação de fontes desconhecidas
- Certifique-se que baixou o arquivo completo
