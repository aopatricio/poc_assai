# ================================
# Script: Windows Update Automático
# ================================

# Variáveis
$LogPath = "C:\Logs"
$LogFile = "$LogPath\WindowsUpdate_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

# Criar pasta de log se não existir
if (!(Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath
}

Start-Transcript -Path $LogFile -Append

Write-Host "Iniciando processo de Windows Update..." -ForegroundColor Cyan

# Garantir TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Instalar NuGet se necessário
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force
}

# Instalar módulo PSWindowsUpdate se não existir
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Instalando módulo PSWindowsUpdate..." -ForegroundColor Yellow
    Install-Module PSWindowsUpdate -Force -Confirm:$false
}

Import-Module PSWindowsUpdate

# Mostrar updates disponíveis
Write-Host "Verificando atualizações disponíveis..." -ForegroundColor Cyan
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot

# Resultado final
Write-Host "Atualizações instaladas. Verificando necessidade de reboot..." -ForegroundColor Green

# Checar se reboot é necessário
$RebootRequired = (Get-WURebootStatus).RebootRequired

if ($RebootRequired) {
    Write-Host "Reboot necessário!" -ForegroundColor Red
    Restart-Computer -Force
} else {
    Write-Host "Reboot NÃO é necessário." -ForegroundColor Green
}

Stop-Transcript
