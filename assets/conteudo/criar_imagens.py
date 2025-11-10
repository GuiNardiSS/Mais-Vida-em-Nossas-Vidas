from PIL import Image, ImageDraw, ImageFontfrom PIL import Image, ImageDraw, ImageFont

import osimport os



width, height = 800, 450# Configurações

output_dir = "."width, height = 800, 450

output_dir = "assets/conteudo"

conteudos = [

    ("meditacao_guiada", "Meditação Guiada", (106, 76, 147)),# Conteúdos com cores

    ("desenvolvimento_pessoal", "Desenvolvimento Pessoal", (11, 76, 82)),conteudos = [

    ("mindfulness", "Mindfulness", (46, 125, 50)),    ("meditacao_guiada", "Meditação\nGuiada", (106, 76, 147)),  # Roxo

    ("yoga_e_bem_estar", "Yoga e Bem-estar", (156, 39, 176)),    ("desenvolvimento_pessoal", "Desenvolvimento\nPessoal", (11, 76, 82)),  # Verde-azulado

    ("inspiracao_diaria", "Inspiração Diária", (255, 152, 0)),    ("mindfulness", "Mindfulness", (46, 125, 50)),  # Verde

    ("inteligencia_emocional", "Inteligência Emocional", (0, 121, 107)),    ("yoga_e_bem_estar", "Yoga e\nBem-estar", (156, 39, 176)),  # Púrpura

]    ("inspiracao_diaria", "Inspiração\nDiária", (255, 152, 0)),  # Laranja

    ("inteligencia_emocional", "Inteligência\nEmocional", (0, 121, 107)),  # Teal

for filename, text, color in conteudos:]

    img = Image.new("RGB", (width, height), color)

    draw = ImageDraw.Draw(img)# Criar imagens

    for filename, text, color in conteudos:

    try:    img = Image.new("RGB", (width, height), color)

        font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 60)    draw = ImageDraw.Draw(img)

    except:    

        font = ImageFont.load_default()    # Tentar usar fonte, caso não tenha, usar padrão

        try:

    bbox = draw.textbbox((0, 0), text, font=font)        font = ImageFont.truetype("arial.ttf", 80)

    text_width = bbox[2] - bbox[0]    except:

    text_height = bbox[3] - bbox[1]        font = ImageFont.load_default()

        

    x = (width - text_width) / 2    # Desenhar texto centralizado

    y = (height - text_height) / 2    bbox = draw.textbbox((0, 0), text, font=font)

        text_width = bbox[2] - bbox[0]

    draw.text((x+2, y+2), text, fill=(0,0,0,128), font=font)    text_height = bbox[3] - bbox[1]

    draw.text((x, y), text, fill="white", font=font)    

        x = (width - text_width) / 2

    filepath = os.path.join(output_dir, f"{filename}.png")    y = (height - text_height) / 2 - 20

    img.save(filepath)    

    print(f"Criado: {filepath}")    draw.text((x, y), text, fill="white", font=font, align="center")

    

print("\nImagens criadas com sucesso!")    # Salvar

    filepath = os.path.join(output_dir, f"{filename}.png")
    img.save(filepath)
    print(f"Criado: {filepath}")

print("\nImagens criadas com sucesso!")
