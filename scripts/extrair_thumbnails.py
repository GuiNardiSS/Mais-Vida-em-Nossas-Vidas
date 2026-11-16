#!/usr/bin/env python3
"""
Script para extrair thumbnails dos vídeos em assets/conteudo/
Extrai um frame de cada vídeo e salva como PNG
"""

try:
    import cv2  # type: ignore
except ImportError:
    print("❌ Erro: OpenCV não está instalado!")
    print("\n📦 Para instalar, execute:")
    print("   pip install opencv-python")
    exit(1)

import os

def extrair_thumbnail(video_path, output_path, segundo=2):
    """
    Extrai um frame do vídeo e salva como imagem
    
    Args:
        video_path: Caminho do arquivo de vídeo
        output_path: Caminho onde salvar a thumbnail
        segundo: Segundo do vídeo para extrair o frame (padrão: 2)
    """
    if not os.path.exists(video_path):
        print(f"❌ Vídeo não encontrado: {video_path}")
        return False
    
    print(f"📹 Processando: {video_path}")
    
    # Abre o vídeo
    video = cv2.VideoCapture(video_path)
    
    # Posiciona no segundo desejado
    video.set(cv2.CAP_PROP_POS_MSEC, segundo * 1000)
    
    # Lê o frame
    success, frame = video.read()
    
    if success:
        # Salva a imagem
        cv2.imwrite(output_path, frame)
        print(f"✅ Thumbnail salvo: {output_path}")
        result = True
    else:
        print(f"❌ Erro ao extrair frame de: {video_path}")
        result = False
    
    video.release()
    return result

def main():
    # Define os caminhos
    base_path = "assets/conteudo"
    
    videos = [
        {
            'video': f'{base_path}/video1.mp4',
            'thumb': f'{base_path}/video1_thumb.png',
            'segundo': 2
        },
        {
            'video': f'{base_path}/video2.mp4',
            'thumb': f'{base_path}/video2_thumb.png',
            'segundo': 2
        },
        {
            'video': f'{base_path}/video3.mp4',
            'thumb': f'{base_path}/video3_thumb.png',
            'segundo': 2
        }
    ]
    
    print("🎬 Iniciando extração de thumbnails dos vídeos...\n")
    
    sucesso = 0
    falha = 0
    
    for video_info in videos:
        if extrair_thumbnail(video_info['video'], video_info['thumb'], video_info['segundo']):
            sucesso += 1
        else:
            falha += 1
        print()
    
    print("=" * 50)
    print(f"✅ Thumbnails criados com sucesso: {sucesso}")
    if falha > 0:
        print(f"❌ Falhas: {falha}")
    print("=" * 50)
    
    if sucesso > 0:
        print("\n💡 As thumbnails foram atualizadas!")
        print("   Faça hot reload no Flutter para ver as mudanças.")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("❌ Erro: OpenCV não está instalado!")
        print("\n📦 Para instalar, execute:")
        print("   pip install opencv-python")
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
