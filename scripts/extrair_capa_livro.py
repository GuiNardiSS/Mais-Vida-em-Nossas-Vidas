#!/usr/bin/env python3
"""
Script para extrair a capa do PDF do livro e salvar como PNG
"""

try:
    import fitz  # PyMuPDF  # type: ignore
    from PIL import Image  # type: ignore
except ImportError:
    print("❌ Erro: PyMuPDF ou Pillow não está instalado!")
    print("\n📦 Para instalar, execute:")
    print("   pip install PyMuPDF pillow")
    exit(1)

import os

def extrair_capa_pdf(pdf_path, output_path):
    """
    Extrai a primeira página de um PDF e salva como imagem PNG
    Redimensiona para um tamanho adequado para thumbnail
    
    Args:
        pdf_path: Caminho do arquivo PDF
        output_path: Caminho onde salvar a imagem
    """
    if not os.path.exists(pdf_path):
        print(f"❌ PDF não encontrado: {pdf_path}")
        return False
    
    print(f"📄 Processando PDF: {pdf_path}")
    
    try:
        # Abre o PDF
        pdf_document = fitz.open(pdf_path)
        
        # Pega a primeira página
        first_page = pdf_document[0]
        
        # Converte para imagem em alta resolução (200 DPI - boa qualidade)
        zoom = 2  # Fator de zoom para melhor qualidade
        mat = fitz.Matrix(zoom, zoom)
        pix = first_page.get_pixmap(matrix=mat)
        
        # Converte para PIL Image para poder redimensionar
        img_data = pix.tobytes("png")
        from io import BytesIO
        img = Image.open(BytesIO(img_data))
        
        # Redimensiona mantendo proporção
        # Alvo: largura ideal para card de 180px de altura (similar aos vídeos)
        target_height = 720  # Altura adequada para boa visualização
        aspect_ratio = img.width / img.height
        target_width = int(target_height * aspect_ratio)
        
        img_resized = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
        
        # Salva como PNG
        img_resized.save(output_path, 'PNG', optimize=True, quality=95)
        
        pdf_document.close()
        
        print(f"✅ Capa extraída e redimensionada: {output_path}")
        print(f"   Dimensões: {target_width}x{target_height}px")
        return True
            
    except Exception as e:
        print(f"❌ Erro ao processar PDF: {e}")
        return False

def main():
    pdf_path = "assets/conteudo/capa do livro A menina que falava com o jardim.pdf"
    output_path = "assets/conteudo/capa_livro_menina_jardim.png"
    
    print("📚 Extraindo capa do livro...\n")
    
    if extrair_capa_pdf(pdf_path, output_path):
        print("\n" + "="*50)
        print("✅ Capa do livro extraída com sucesso!")
        print("="*50)
        print("\n💡 Faça hot reload no Flutter para ver a mudança.")
    else:
        print("\n" + "="*50)
        print("❌ Falha ao extrair a capa")
        print("="*50)

if __name__ == "__main__":
    main()
