from PIL import Image, ImageDraw, ImageFont
import os

width, height = 800, 450

# Imagens que faltam
imagens = [
    ("video1_thumb", "Vídeo 1\nIntrodução à\nEspiritualidade", (33, 150, 243)),  # Azul
    ("video2_thumb", "Vídeo 2\nMeditação\nGuiada", (156, 39, 176)),  # Roxo
    ("video3_thumb", "Vídeo 3\nGratidão\nDiária", (255, 193, 7)),  # Amarelo
    ("gratidao", "O Poder da\nGratidão", (76, 175, 80)),  # Verde
    ("capa_livro_menina_jardim", "A Menina que\nFalava com o\nJardim", (102, 187, 106)),  # Verde claro
]

for filename, text, color in imagens:
    img = Image.new("RGB", (width, height), color)
    draw = ImageDraw.Draw(img)
    
    # Tentar usar fonte Arial, caso não tenha usar padrão
    try:
        font = ImageFont.truetype("arial.ttf", 70)
    except:
        font = ImageFont.load_default()
    
    # Desenhar texto centralizado
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (width - text_width) / 2
    y = (height - text_height) / 2
    
    # Sombra
    draw.text((x+3, y+3), text, fill=(0, 0, 0, 100), font=font, align="center")
    # Texto branco
    draw.text((x, y), text, fill="white", font=font, align="center")
    
    # Salvar
    filepath = f"{filename}.png"
    img.save(filepath)
    print(f"✅ Criado: {filepath}")

print("\n✨ Todas as imagens foram criadas com sucesso!")
