"""
Script para gerar vídeos com áudio (narração) a partir dos textos das informações.
Requer: moviepy, gtts (Google Text-to-Speech)

Instalação:
pip install moviepy gtts pillow

Uso:
python gerar_videos.py
"""

from gtts import gTTS
from moviepy.editor import *
from PIL import Image, ImageDraw, ImageFont
import os

# Textos originais das informações
informacoes = [
    {
        'titulo': 'Espiritualidade',
        'texto': 'A espiritualidade é a busca por um sentido maior na vida, conectando-se com valores, propósito e o universo.',
        'cor': '#4A90E2'
    },
    {
        'titulo': 'Autoconhecimento',
        'texto': 'O autoconhecimento é fundamental para o crescimento pessoal e espiritual, permitindo compreender emoções e atitudes.',
        'cor': '#50C878'
    },
    {
        'titulo': 'Gratidão',
        'texto': 'A gratidão transforma a percepção da vida, trazendo leveza e bem-estar ao reconhecer o valor das pequenas coisas.',
        'cor': '#FFB347'
    },
    {
        'titulo': 'Fé',
        'texto': 'A fé é a confiança em algo maior, capaz de renovar esperanças e superar desafios.',
        'cor': '#9B59B6'
    },
    {
        'titulo': 'Resiliência',
        'texto': 'Resiliência é a capacidade de se adaptar e crescer diante das adversidades, mantendo o equilíbrio emocional.',
        'cor': '#E74C3C'
    },
    {
        'titulo': 'Compaixão',
        'texto': 'Compaixão é a empatia ativa, promovendo ajuda e compreensão ao outro.',
        'cor': '#F39C12'
    },
    {
        'titulo': 'Propósito',
        'texto': 'Ter propósito é viver com direção e significado, guiando escolhas e ações.',
        'cor': '#1ABC9C'
    },
    {
        'titulo': 'Equilíbrio',
        'texto': 'O equilíbrio é essencial para o bem-estar integral, unindo saúde física, mental e espiritual.',
        'cor': '#3498DB'
    },
    {
        'titulo': 'Esperança',
        'texto': 'A esperança motiva a busca por soluções e mantém o otimismo diante das dificuldades.',
        'cor': '#F1C40F'
    },
    {
        'titulo': 'Amor',
        'texto': 'O amor é a base das relações humanas, capaz de curar, unir e transformar vidas.',
        'cor': '#E91E63'
    },
]

def hex_to_rgb(hex_color):
    """Converte cor hexadecimal para RGB."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def criar_frame_texto(titulo, texto, cor_hex, tamanho=(1280, 720)):
    """Cria um frame de imagem com o título e texto."""
    # Criar imagem
    img = Image.new('RGB', tamanho, color=hex_to_rgb(cor_hex))
    draw = ImageDraw.Draw(img)
    
    # Configurar fontes (use fontes do sistema ou baixe)
    try:
        fonte_titulo = ImageFont.truetype("arial.ttf", 80)
        fonte_texto = ImageFont.truetype("arial.ttf", 40)
    except:
        fonte_titulo = ImageFont.load_default()
        fonte_texto = ImageFont.load_default()
    
    # Desenhar título
    bbox_titulo = draw.textbbox((0, 0), titulo, font=fonte_titulo)
    w_titulo = bbox_titulo[2] - bbox_titulo[0]
    h_titulo = bbox_titulo[3] - bbox_titulo[1]
    x_titulo = (tamanho[0] - w_titulo) // 2
    y_titulo = 150
    
    # Sombra do título
    draw.text((x_titulo + 3, y_titulo + 3), titulo, fill=(0, 0, 0), font=fonte_titulo)
    draw.text((x_titulo, y_titulo), titulo, fill=(255, 255, 255), font=fonte_texto)
    
    # Quebrar texto em linhas
    palavras = texto.split()
    linhas = []
    linha_atual = ""
    max_largura = tamanho[0] - 200
    
    for palavra in palavras:
        teste = f"{linha_atual} {palavra}".strip()
        bbox = draw.textbbox((0, 0), teste, font=fonte_texto)
        largura = bbox[2] - bbox[0]
        
        if largura <= max_largura:
            linha_atual = teste
        else:
            linhas.append(linha_atual)
            linha_atual = palavra
    
    if linha_atual:
        linhas.append(linha_atual)
    
    # Desenhar texto
    y_texto = y_titulo + h_titulo + 100
    for linha in linhas:
        bbox = draw.textbbox((0, 0), linha, font=fonte_texto)
        w_linha = bbox[2] - bbox[0]
        x_linha = (tamanho[0] - w_linha) // 2
        
        # Sombra
        draw.text((x_linha + 2, y_texto + 2), linha, fill=(0, 0, 0), font=fonte_texto)
        draw.text((x_linha, y_texto), linha, fill=(255, 255, 255), font=fonte_texto)
        y_texto += 60
    
    return img

def gerar_video(info, index):
    """Gera vídeo com áudio para uma informação."""
    print(f"Gerando vídeo {index + 1}/10: {info['titulo']}...")
    
    # 1. Gerar áudio usando Google TTS (português do Brasil)
    texto_completo = f"{info['titulo']}. {info['texto']}"
    tts = gTTS(text=texto_completo, lang='pt-br', slow=False)
    
    audio_path = f"temp_audio_{index}.mp3"
    tts.save(audio_path)
    
    # 2. Carregar áudio e obter duração
    audio_clip = AudioFileClip(audio_path)
    duracao = audio_clip.duration + 1  # +1 segundo de margem
    
    # 3. Criar frame visual
    frame_img = criar_frame_texto(info['titulo'], info['texto'], info['cor'])
    frame_path = f"temp_frame_{index}.png"
    frame_img.save(frame_path)
    
    # 4. Criar vídeo a partir do frame
    video_clip = ImageClip(frame_path).set_duration(duracao)
    
    # 5. Adicionar áudio ao vídeo
    video_final = video_clip.set_audio(audio_clip)
    
    # 6. Exportar vídeo final
    nome_arquivo = info['titulo'].lower().replace('ã', 'a').replace('ç', 'c')
    output_path = f"{nome_arquivo}.mp4"
    
    video_final.write_videofile(
        output_path,
        fps=24,
        codec='libx264',
        audio_codec='aac',
        temp_audiofile=f'temp_audio_final_{index}.m4a',
        remove_temp=True
    )
    
    # 7. Limpar arquivos temporários
    os.remove(audio_path)
    os.remove(frame_path)
    
    print(f"✓ Vídeo gerado: {output_path}")
    
    return output_path

def main():
    """Função principal para gerar todos os vídeos."""
    print("=" * 60)
    print("Gerador de Vídeos com Narração - Conheça Mais")
    print("=" * 60)
    print()
    
    # Criar pasta de saída se não existir
    os.makedirs('.', exist_ok=True)
    
    videos_gerados = []
    
    for i, info in enumerate(informacoes):
        try:
            video_path = gerar_video(info, i)
            videos_gerados.append(video_path)
        except Exception as e:
            print(f"✗ Erro ao gerar vídeo {info['titulo']}: {e}")
    
    print()
    print("=" * 60)
    print(f"Concluído! {len(videos_gerados)}/10 vídeos gerados com sucesso.")
    print("=" * 60)
    print()
    print("Vídeos gerados:")
    for video in videos_gerados:
        print(f"  - {video}")
    print()
    print("Agora você pode copiar estes arquivos .mp4 para a pasta assets/conteudo/")

if __name__ == "__main__":
    main()
