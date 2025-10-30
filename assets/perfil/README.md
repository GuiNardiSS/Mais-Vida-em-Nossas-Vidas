# 📸 Pasta de Imagem de Perfil

## Como adicionar a foto

1. Salve a foto de Helô Coelho como `helo_coelho.jpg`
2. Coloque o arquivo nesta pasta: `assets/perfil/`
3. Execute `flutter pub get` para recarregar os assets
4. Execute `flutter run` para ver as mudanças

## Formato recomendado

- **Nome do arquivo**: `helo_coelho.jpg`
- **Formato**: JPG ou PNG
- **Tamanho recomendado**: Mínimo 800x800px
- **Orientação**: Vertical ou quadrada

## Visualização

A foto será exibida na página de "Contato" com:
- **Mobile**: Foto acima do texto (layout vertical)
- **Desktop**: Foto à esquerda, texto à direita (layout horizontal)
- **Bordas arredondadas** com sombra suave
- **Responsivo**: Adapta-se automaticamente ao tamanho da tela

## Fallback

Se a imagem não for encontrada, será exibido um placeholder com:
- Ícone de pessoa
- Nome "Helô Coelho"
- Fundo na cor dourada do app