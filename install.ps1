# =============================================================================
# ai-agent-commands - Instalador interactivo (PowerShell)
# =============================================================================
# Compatible con: Windows PowerShell 5.1+, PowerShell Core 7+
# Uso:
#   iwr -useb https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.ps1 | iex
#   .\install.ps1
# =============================================================================

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# -- Configuracion --
$RepoUrl = "https://github.com/JohnDevRD/ai-agent-commands"
$RepoBranch = "main"
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = if (-not [string]::IsNullOrWhiteSpace($ScriptPath)) {
    Split-Path -Parent $ScriptPath
} elseif (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} else {
    (Get-Location).Path
}
$CacheDir = Join-Path $env:USERPROFILE ".cache\ai-agent-commands"

# -- Funciones de salida --
function Print-Banner {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  AI Agent Commands - Instalador" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error   { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Print-Warning { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Print-Info    { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Print-Header  { param([string]$Message) Write-Host ""; Write-Host "-- $Message --" -ForegroundColor Cyan }

function Prompt-Input {
    param(
        [string]$Message,
        [string]$Default = "",
        [string]$Variable
    )

    if ($Default) {
        $value = Read-Host "$Message [$Default]"
        if ([string]::IsNullOrWhiteSpace($value)) { $value = $Default }
    } else {
        $value = Read-Host $Message
    }

    Set-Variable -Name $Variable -Value $value -Scope 1
}

function Invoke-GitQuiet {
    param([string[]]$Arguments)

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw (($output | Out-String).Trim())
    }
}

# -- Destino de instalacion --
function Detect-InstallTarget {
    Print-Header "Destino de instalacion"
    Write-Host "  1) Proyecto actual (./.opencode/commands/)"
    Write-Host "  2) Global del usuario (~/.config/opencode/commands/)"
    Write-Host "  3) Ruta personalizada"
    Prompt-Input "Elegir una opcion" "1" "choice"

    switch ($choice) {
        "1" { $script:InstallDir = Join-Path (Get-Location) ".opencode\commands" }
        "2" { $script:InstallDir = Join-Path $env:USERPROFILE ".config\opencode\commands" }
        "3" {
            Prompt-Input "Ruta completa de destino" "" "customPath"
            $script:InstallDir = $customPath
        }
        default {
            Print-Error "Opcion invalida"
            exit 1
        }
    }

    Print-Info "Destino seleccionado: $InstallDir"
}

# -- Obtener catalogo --
function Fetch-Catalog {
    Print-Header "Obteniendo catalogo"

    if (Test-Path (Join-Path $CacheDir ".git")) {
        Print-Info "Actualizando catalogo en cache..."
        Push-Location $CacheDir
        try {
            Invoke-GitQuiet @("pull", "origin", $RepoBranch)
        } catch {
            Print-Warning "No se pudo actualizar el cache; se usara el cache local existente"
        } finally {
            Pop-Location
        }
    } else {
        Print-Info "Clonando catalogo por primera vez..."
        try {
            New-Item -ItemType Directory -Path (Split-Path $CacheDir) -Force | Out-Null
            Invoke-GitQuiet @("clone", "--depth", "1", "--branch", $RepoBranch, $RepoUrl, $CacheDir)
        } catch {
            Print-Error "No se pudo clonar el repositorio. Verifica tu conexion y la instalacion de git."
            if ($_.Exception.Message) {
                Print-Warning $_.Exception.Message
            }
            if (Test-Path (Join-Path $ScriptDir ".git")) {
                Print-Warning "Usando archivos locales del repositorio como respaldo."
                $script:CacheDir = $ScriptDir
            } else {
                exit 1
            }
        }
    }

    if (-not (Test-Path $CacheDir)) {
        Print-Error "No se encontro el catalogo."
        exit 1
    }
}

# -- Ayudantes del catalogo --
function Get-Categories {
    $categories = @()
    Get-ChildItem -Path $CacheDir -Directory | Sort-Object Name | ForEach-Object {
        $manifest = Join-Path $_.FullName "manifest.json"
        if (Test-Path $manifest) {
            $categories += $_.Name
        }
    }
    return $categories
}

function Show-Categories {
    param([array]$Categories)

    Print-Header "Categorias disponibles"
    $i = 1
    foreach ($cat in $Categories) {
        $manifest = Join-Path $CacheDir "$cat\manifest.json"
        $content = Get-Content $manifest -Raw | ConvertFrom-Json
        $count = if ($content.commands) { $content.commands.Count } else { 0 }
        Write-Host ("  {0}) {1} ({2} comandos)" -f $i, $content.displayName, $count) -ForegroundColor Yellow
        $i++
    }
    Write-Host "  todo) Instalar todo" -ForegroundColor Yellow
    Write-Host "  q) Salir" -ForegroundColor Yellow
}

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

function Get-CommandsFromCategory {
    param([string]$Category)

    $manifest = Join-Path $CacheDir "$Category\manifest.json"
    $content = Get-Content $manifest -Raw | ConvertFrom-Json
    return @($content.commands)
}

function Install-Command {
    param([string]$Category, [string]$CmdFile)

    $source = Join-Path $CacheDir "$Category\$CmdFile"

    if (-not (Test-Path $source)) {
        Print-Error "Archivo no encontrado: $source"
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

function Install-AllCategories {
    param([array]$Categories)

    Print-Header "Instalando todas las categorias"
    foreach ($cat in $Categories) {
        $commands = Get-CommandsFromCategory -Category $cat
        foreach ($cmd in $commands) {
            Install-Command -Category $cat -CmdFile $cmd.file
        }
    }
    Print-Success "Todo instalado."
}

# -- Flujo principal --
function Main {
    Print-Banner
    Detect-InstallTarget
    Fetch-Catalog

    $categories = Get-Categories
    if ($categories.Count -eq 0) {
        Print-Error "No se encontraron categorias en el catalogo."
        exit 1
    }

    $stopInstalling = $false
    while ($true) {
        Write-Host ""
        Show-Categories -Categories $categories
        Write-Host ""
        Prompt-Input "Selecciona categoria, 'todo' o 'q'" "" "choice"

        if ([string]::IsNullOrWhiteSpace($choice)) {
            Print-Info "No se selecciono ninguna opcion. Saliendo..."
            break
        }

        switch ($choice.ToLower()) {
            "q" {
                Print-Info "Saliendo..."
                exit 0
            }
            "todo" {
                Install-AllCategories -Categories $categories
                $stopInstalling = $true
            }
            "all" {
                Install-AllCategories -Categories $categories
                $stopInstalling = $true
            }
            default {
                $categoryNumber = 0
                if (-not [int]::TryParse($choice, [ref]$categoryNumber) -or $categoryNumber -lt 1 -or $categoryNumber -gt $categories.Count) {
                    Print-Error "Opcion invalida"
                    continue
                }

                $selectedCat = $categories[$categoryNumber - 1]
                Show-CommandsInCategory -Category $selectedCat
                Write-Host ""
                Prompt-Input "Selecciona comandos (ejemplo: 1,3,4 o 'todo')" "todo" "cmdChoice"

                $commands = Get-CommandsFromCategory -Category $selectedCat

                if ($cmdChoice.ToLower() -in @("todo", "all")) {
                    foreach ($cmd in $commands) {
                        Install-Command -Category $selectedCat -CmdFile $cmd.file
                    }
                } else {
                    $selected = $cmdChoice -split "," | ForEach-Object { [int]$_.Trim() }
                    for ($i = 0; $i -lt $commands.Count; $i++) {
                        if ($selected -contains ($i + 1)) {
                            Install-Command -Category $selectedCat -CmdFile $commands[$i].file
                        }
                    }
                }

                Write-Host ""
                Prompt-Input "Instalar otra categoria?" "s" "continue"
                if ($continue.ToLower() -notin @("s", "si", "y", "yes")) {
                    $stopInstalling = $true
                }
            }
        }

        if ($stopInstalling) { break }
    }

    Write-Host ""
    Print-Header "Resumen"
    Print-Success "Comandos instalados en: $InstallDir"
    Write-Host ""
    Print-Info "Comandos disponibles en tu agente IA:"
    if (Test-Path $InstallDir) {
        Get-ChildItem -Path $InstallDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
            Write-Host "  /$($_.BaseName)" -ForegroundColor Green
        }
    }
    Write-Host ""
    Print-Success "Listo. Ya podes usar los comandos en tu agente IA."
}

Main
