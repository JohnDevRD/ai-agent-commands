# ═══════════════════════════════════════════════════════════════
# ai-agent-commands - Instalador interactivo (PowerShell)
# ═══════════════════════════════════════════════════════════════
# Compatible con: Windows PowerShell 5.1+, PowerShell Core 7+
# Uso: .\install.ps1
# ═══════════════════════════════════════════════════════════════

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# ── Configuración ──
$RepoUrl = "https://github.com/JohnDevRD/ai-agent-commands"
$RepoBranch = "main"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CacheDir = Join-Path $env:USERPROFILE ".cache\ai-agent-commands"

# ── Funciones auxiliares ──
function Print-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🤖 AI Agent Commands - Instalador       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Print-Error   { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Print-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Print-Info    { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Blue }
function Print-Header  { param($msg) Write-Host ""; Write-Host "── $msg ──" -ForegroundColor Cyan }

function Prompt-Input {
    param(
        [string]$Message,
        [string]$Default = "",
        [string]$Variable
    )
    if ($Default) {
        $input = Read-Host "$Message [$Default]"
        if ([string]::IsNullOrWhiteSpace($input)) { $input = $Default }
    } else {
        $input = Read-Host $Message
    }
    Set-Variable -Name $Variable -Value $input -Scope 1
}

# ── Detectar destino ──
function Detect-InstallTarget {
    Print-Header "Destino de instalación"
    Write-Host "  1) Proyecto actual (./.opencode/commands/)"
    Write-Host "  2) Global del usuario (~/.config/opencode/commands/)"
    Write-Host "  3) Personalizado"
    Prompt-Input "Elige una opción" "1" "choice"

    switch ($choice) {
        "1" { $script:InstallDir = Join-Path (Get-Location) ".opencode\commands" }
        "2" { $script:InstallDir = Join-Path $env:USERPROFILE ".config\opencode\commands" }
        "3" { Prompt-Input "Ruta completa de destino" "" "customPath"
              $script:InstallDir = $customPath }
        default { Print-Error "Opción inválida"; exit 1 }
    }

    Print-Info "Destino seleccionado: $InstallDir"
}


# ── Obtener catálogo ──
function Fetch-Catalog {
    Print-Header "Obteniendo catálogo"

    if (Test-Path (Join-Path $CacheDir ".git")) {
        Print-Info "Actualizando catálogo en caché..."
        Push-Location $CacheDir
        try {
            git pull origin $RepoBranch 2>&1 | Out-Null
        } catch {
            Print-Warning "No se pudo actualizar, usando versión local"
        }
        Pop-Location
    } else {
        Print-Info "Clonando catálogo por primera vez..."
        try {
            New-Item -ItemType Directory -Path (Split-Path $CacheDir) -Force | Out-Null
            git clone --depth 1 --branch $RepoBranch $RepoUrl $CacheDir 2>&1 | Out-Null
        } catch {
            Print-Error "No se pudo clonar el repo. Verifica tu conexión."
            Print-Info "Usando archivos locales del repo..."
            $script:CacheDir = $ScriptDir
        }
    }

    if (-not (Test-Path $CacheDir)) {
        Print-Error "No se encontró el catálogo."
        exit 1
    }
}

# ── Cargar categorías ──
function Get-Categories {
    $categories = @()
    Get-ChildItem -Path $CacheDir -Directory | ForEach-Object {
        $manifest = Join-Path $_.FullName "manifest.json"
        if (Test-Path $manifest) {
            $categories += $_.Name
        }
    }
    return $categories
}

# ── Mostrar menú de categorías ──
function Show-Categories {
    param([array]$Categories)

    Print-Header "Categorías disponibles"
    $i = 1
    foreach ($cat in $Categories) {
        $manifest = Join-Path $CacheDir "$cat\manifest.json"
        $content = Get-Content $manifest -Raw | ConvertFrom-Json
        $count = if ($content.commands) { $content.commands.Count } else { 0 }
        Write-Host ("  {0}) {1} ({2} comandos)" -f $i, $content.displayName, $count) -ForegroundColor Yellow
        $i++
    }
    Write-Host "  all) Instalar todo" -ForegroundColor Yellow
    Write-Host "  q) Salir" -ForegroundColor Yellow
}

# ── Mostrar comandos de una categoría ──
function Show-CommandsInCategory {
    param([string]$Category)
    $manifest = Join-Path $CacheDir "$Category\manifest.json"
    $content = Get-Content $manifest -Raw | ConvertFrom-Json

    Print-Header "Comandos en: $($content.displayName)"

    $i = 1
    foreach ($cmd in $content.commands) {
        Write-Host ("  {0}) {1} - {2}" -f $i, $cmd.id, $cmd.description)
        $i++
    }
}

# ── Instalar comando ──
function Install-Command {
    param([string]$Category, [string]$CmdFile)

    $source = Join-Path $CacheDir "$Category\$CmdFile"

    if (-not (Test-Path $source)) {
        Print-Error "Archivo no encontrado: $source"

# ── Flujo principal ──
function Main {
    Print-Banner
    Detect-InstallTarget
    Fetch-Catalog

    $categories = Get-Categories
    if ($categories.Count -eq 0) {
        Print-Error "No se encontraron categorías en el catálogo."
        exit 1
    }

    while ($true) {
        Write-Host ""
        Show-Categories -Categories $categories
        Write-Host ""
        Prompt-Input "Selecciona categoría, 'all' o 'q'" "" "choice"

        switch ($choice.ToLower()) {
            "q" { Print-Info "Saliendo..."; exit 0 }
            "all" {
                Print-Header "Instalando todas las categorías"
                foreach ($cat in $categories) {
                    $catDir = Join-Path $CacheDir $cat
                    Get-ChildItem -Path $catDir -Filter "*.md" | ForEach-Object {
                        Install-Command -Category $cat -CmdFile $_.Name
                    }
                }
                Print-Success "¡Todo instalado!"
                return
            }
            default {
                if (-not ($choice -as [int]) -or $choice -lt 1 -or $choice -gt $categories.Count) {
                    Print-Error "Opción inválida"
                    continue
                }

                $selectedCat = $categories[$choice - 1]
                Show-CommandsInCategory -Category $selectedCat
                Write-Host ""
                Prompt-Input "Selecciona comandos (ej: 1,3,4 o 'all')" "all" "cmdChoice"

                $catDir = Join-Path $CacheDir $selectedCat
                $files = Get-ChildItem -Path $catDir -Filter "*.md" | Sort-Object Name

                if ($cmdChoice.ToLower() -eq "all") {
                    foreach ($file in $files) {
                        Install-Command -Category $selectedCat -CmdFile $file.Name
                    }
                } else {
                    $selected = $cmdChoice -split "," | ForEach-Object { [int]$_.Trim() }
                    $i = 1
                    foreach ($file in $files) {
                        if ($selected -contains $i) {
                            Install-Command -Category $selectedCat -CmdFile $file.Name
                        }
                        $i++
                    }
                }

                Write-Host ""
                Prompt-Input "¿Instalar otra categoría?" "s" "continue"
                if ($continue.ToLower() -notin @("s", "si", "y", "yes")) {
                    break
                }
            }
        }
    }

    Write-Host ""
    Print-Header "Resumen"
    Print-Success "Comandos instalados en: $InstallDir"
    Write-Host ""
    Print-Info "Comandos disponibles en tu agente:"
    if (Test-Path $InstallDir) {
        Get-ChildItem -Path $InstallDir -Filter "*.md" | ForEach-Object {
            $name = $_.BaseName
            Write-Host "  /$name" -ForegroundColor Green
        }
    }
    Write-Host ""
    Print-Success "¡Listo! Ya puedes usar los comandos en tu agente IA 🎉"
}

# ── Ejecutar ──
Main

        return
    }

    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $dest = Join-Path $InstallDir $CmdFile
    if (Test-Path $dest) {
        Print-Warning "Sobrescribiendo: $CmdFile"
    }

    Copy-Item $source $dest -Force
    Print-Success "Instalado: $CmdFile"
}
