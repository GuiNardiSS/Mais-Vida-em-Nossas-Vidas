# Script para organizar os áudios das cartas
# Execute este script no PowerShell como Administrador

$sourceFolder = "C:\Users\guilh\OneDrive\Documentos\Audios Cartas"
$destinationDia = "C:\Users\guilh\Maisvidaemnossasvida\meu_app_flutter\assets\audios_cartas_dia"
$destinationOrg = "C:\Users\guilh\Maisvidaemnossasvida\meu_app_flutter\assets\audios_cartas_org"

Write-Host "Organizando áudios das cartas..." -ForegroundColor Green

# Verifica se a pasta de origem existe
if (-not (Test-Path $sourceFolder)) {
    Write-Host "ERRO: Pasta de origem não encontrada: $sourceFolder" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit
}

# Lista todos os arquivos de áudio na pasta de origem
$audioFiles = Get-ChildItem -Path $sourceFolder -File | Where-Object { $_.Extension -match '\.(mp3|wav|m4a|aac)$' }

Write-Host "Encontrados $($audioFiles.Count) arquivos de áudio" -ForegroundColor Yellow

# Organiza os arquivos
foreach ($file in $audioFiles) {
    $fileName = $file.BaseName
    $extension = $file.Extension
    
    # Extrai o número do arquivo (assumindo que há um número no nome)
    if ($fileName -match '(\d+)') {
        $number = [int]$matches[1]
        
        if ($number -le 50) {
            # Cartas do Dia (1-50)
            $newName = "carta_$number$extension"
            $destination = Join-Path $destinationDia $newName
            Write-Host "Copiando $($file.Name) -> audios_cartas_dia/$newName" -ForegroundColor Cyan
            Copy-Item -Path $file.FullName -Destination $destination -Force
        } elseif ($number -le 100) {
            # Cartas da Organização (51-100 -> 1-50)
            $orgNumber = $number - 50
            $newName = "carta_$orgNumber$extension"
            $destination = Join-Path $destinationOrg $newName
            Write-Host "Copiando $($file.Name) -> audios_cartas_org/$newName" -ForegroundColor Magenta
            Copy-Item -Path $file.FullName -Destination $destination -Force
        } else {
            Write-Host "AVISO: Arquivo $($file.Name) tem número $number maior que 100, ignorando..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "AVISO: Não foi possível extrair número do arquivo $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Organização concluída!" -ForegroundColor Green
Write-Host "Cartas do Dia: $(Get-ChildItem -Path $destinationDia -File | Where-Object { $_.Extension -match '\.(mp3|wav|m4a|aac)$' } | Measure-Object | Select-Object -ExpandProperty Count) arquivos"
Write-Host "Cartas da Organização: $(Get-ChildItem -Path $destinationOrg -File | Where-Object { $_.Extension -match '\.(mp3|wav|m4a|aac)$' } | Measure-Object | Select-Object -ExpandProperty Count) arquivos"

Read-Host "Pressione Enter para continuar"