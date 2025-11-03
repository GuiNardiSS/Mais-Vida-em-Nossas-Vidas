from PIL import Image, ImageDraw, ImageFont

w, h = 800, 450

items = [
    ("meditacao_guiada", "Meditação", (106, 76, 147)),
    ("desenvolvimento_pessoal", "Desenvolvimento", (11, 76, 82)),
    ("mindfulness", "Mindfulness", (46, 125, 50)),
    ("yoga_e_bem_estar", "Yoga", (156, 39, 176)),
    ("inspiracao_diaria", "Inspiração", (255, 152, 0)),
    ("inteligencia_emocional", "Inteligência", (0, 121, 107))
]

for name, txt, clr in items:
    im = Image.new("RGB", (w, h), clr)
    dr = ImageDraw.Draw(im)
    try:
        ft = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 80)
    except:
        ft = ImageFont.load_default()
    bb = dr.textbbox((0, 0), txt, font=ft)
    tw = bb[2] - bb[0]
    th = bb[3] - bb[1]
    x = (w - tw) / 2
    y = (h - th) / 2
    dr.text((x+3, y+3), txt, fill=(0,0,0), font=ft)
    dr.text((x, y), txt, fill="white", font=ft)
    im.save(f"{name}.png")
    print(f"OK: {name}.png")
