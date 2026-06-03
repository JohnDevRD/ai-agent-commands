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
$RepoUrl    = "https://github.com/JohnDevRD/ai-agent-commands"
$RepoBranch = "main"
$Version    = "1.0.0"
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = if (-not [string]::IsNullOrWhiteSpace($ScriptPath)) {
    Split-Path -Parent $ScriptPath
} elseif (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} else {
    (Get-Location).Path
}
$CacheDir = Join-Path $env:USERPROFILE ".cache\ai-agent-commands"

# Contador de comandos instalados
$script:InstalledCount = 0
$script:InstalledFiles = @()

# =============================================================================
# FUNCIONES DE UI
# =============================================================================

function Write-Blank { Write-Host "" }

function Print-Banner {
    $width = 62
    Write-Blank
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "    ___    ____   ___                    __" -ForegroundColor Cyan
    Write-Host "   /   |  /  _/  /   | ____ ____  ____  / /_" -ForegroundColor Cyan
    Write-Host "  / /| |  / /   / /| |/ __ ``/ _ \/ __ \/ __/" -ForegroundColor Cyan
    Write-Host " / ___ |_/ /   / ___ / /_/ /  __/ / / / /_" -ForegroundColor Cyan
    Write-Host "/_/  |_/___/  /_/  |_\__, /\___/_/ /_/\__/" -ForegroundColor Cyan
    Write-Host "                    /____/  Commands" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host ("  Instalador Interactivo  v$Version") -ForegroundColor White
    Write-Host ("  $RepoUrl") -ForegroundColor DarkGray
    Write-Host ""
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Blank
}

function Print-SectionHeader {
    param([string]$Title)
    $line = "-" * 60
    Write-Blank
    Write-Host $line -ForegroundColor DarkGray
    Write-Host "  >> $Title" -ForegroundColor White
    Write-Host $line -ForegroundColor DarkGray
}

function Print-Success {
    param([string]$Message)
    Write-Host "  [+] " -NoNewline -ForegroundColor Green
    Write-Host $Message -ForegroundColor White
}

function Print-Error {
    param([string]$Message)
    Write-Host "  [x] " -NoNewline -ForegroundColor Red
    Write-Host $Message -ForegroundColor White
}

function Print-Warning {
    param([string]$Message)
    Write-Host "  [!] " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor White
}

function Print-Info {
    param([string]$Message)
    Write-Host "  [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Gray
}

function Print-Step {
    param([string]$Step, [string]$Value = "")
    Write-Host "  [>] " -NoNewline -ForegroundColor DarkCyan
    Write-Host $Step -NoNewline -ForegroundColor White
    if ($Value) {
        Write-Host "  $Value" -ForegroundColor DarkGray
    } else {
        Write-Host ""
    }
}

function Show-Spinner {
    param([string]$Message, [scriptblock]$Action)

    $frames  = @("|", "/", "-", "\")
    $job     = Start-Job -ScriptBlock $Action
    $i       = 0

    Write-Host ""
    while ($job.State -eq "Running") {
        $frame = $frames[$i % $frames.Length]
        Write-Host "`r  [$frame] $Message..." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
    }

    Write-Host "`r  [+] $Message... Listo.   " -ForegroundColor Green
    $result = Receive-Job $job -ErrorVariable jobErrors
    Remove-Job $job

    if ($jobErrors) {
        throw $jobErrors[0]
    }

    return $result
}

function Prompt-Input {
    param(
        [string]$Message,
        [string]$Default = "",
        [string]$Variable
    )

    Write-Host ""
    if ($Default) {
        Write-Host "  " -NoNewline
        Write-Host $Message -NoNewline -ForegroundColor White
        Write-Host " [" -NoNewline -ForegroundColor DarkGray
        Write-Host $Default -NoNewline -ForegroundColor Yellow
        Write-Host "]" -NoNewline -ForegroundColor DarkGray
        Write-Host " : " -NoNewline -ForegroundColor DarkGray
        $value = Read-Host
        if ([string]::IsNullOrWhiteSpace($value)) { $value = $Default }
    } else {
        Write-Host "  " -NoNewline
        Write-Host $Message -NoNewline -ForegroundColor White
        Write-Host " : " -NoNewline -ForegroundColor DarkGray
        $value = Read-Host
    }

    Set-Variable -Name $Variable -Value $value -Scope 1
}

function Invoke-GitQuiet {
    param([string[]]$Arguments)

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output   = & git @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw (($output | Out-String).Trim())
    }
}

# =============================================================================
# DESTINO DE INSTALACION
# =============================================================================

function Detect-InstallTarget {
    Print-SectionHeader "Destino de instalacion"

    Write-Host ""
    Write-Host "  [1]" -NoNewline -ForegroundColor Yellow
    Write-Host "  Proyecto actual         " -NoNewline -ForegroundColor White
    Write-Host "./.opencode/commands/" -ForegroundColor DarkGray

    Write-Host "  [2]" -NoNewline -ForegroundColor Yellow
    Write-Host "  Global del usuario      " -NoNewline -ForegroundColor White
    Write-Host "~/.config/opencode/commands/" -ForegroundColor DarkGray

    Write-Host "  [3]" -NoNewline -ForegroundColor Yellow
    Write-Host "  Ruta personalizada" -ForegroundColor White

    Prompt-Input "Elegir una opcion" "1" "choice"

    switch ($choice) {
        "1" { $script:InstallDir = Join-Path (Get-Location) ".opencode\commands" }
        "2" { $script:InstallDir = Join-Path $env:USERPROFILE ".config\opencode\commands" }
        "3" {
            Prompt-Input "Ruta completa de destino" "" "customPath"
            $script:InstallDir = $customPath
        }
        default {
            Print-Error "Opcion invalida. Saliendo."
            exit 1
        }
    }

    Write-Blank
    Print-Info "Destino: $InstallDir"
}

# =============================================================================
# CATALOGO
# =============================================================================

function Fetch-Catalog {
    Print-SectionHeader "Obteniendo catalogo"
    Write-Blank

    if (Test-Path (Join-Path $CacheDir ".git")) {
        Print-Step "Actualizando catalogo en cache"
        Push-Location $CacheDir
        try {
            Invoke-GitQuiet @("pull", "origin", $RepoBranch)
            Print-Success "Catalogo actualizado correctamente."
        } catch {
            Print-Warning "No se pudo actualizar el cache; se usara la version local existente."
        } finally {
            Pop-Location
        }
    } else {
        Print-Step "Clonando catalogo por primera vez"
        try {
            New-Item -ItemType Directory -Path (Split-Path $CacheDir) -Force | Out-Null
            Invoke-GitQuiet @("clone", "--depth", "1", "--branch", $RepoBranch, $RepoUrl, $CacheDir)
            Print-Success "Catalogo clonado correctamente."
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
        Print-Error "No se encontro el catalogo en: $CacheDir"
        exit 1
    }
}

# =============================================================================
# HELPERS DEL CATALOGO
# =============================================================================

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

    Print-SectionHeader "Categorias disponibles"
    Write-Blank

    $i = 1
    foreach ($cat in $Categories) {
        $manifest = Join-Path $CacheDir "$cat\manifest.json"
        $content  = Get-Content $manifest -Raw | ConvertFrom-Json
        $count    = if ($content.commands) { $content.commands.Count } else { 0 }
        $label    = $content.displayName.PadRight(30)

        Write-Host "  [" -NoNewline -ForegroundColor DarkGray
        Write-Host "$i" -NoNewline -ForegroundColor Yellow
        Write-Host "] " -NoNewline -ForegroundColor DarkGray
        Write-Host $label -NoNewline -ForegroundColor White
        Write-Host "$count comando(s)" -ForegroundColor DarkGray
        $i++
    }

    Write-Host ""
    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host "todo" -NoNewline -ForegroundColor Cyan
    Write-Host "]  Instalar todas las categorias" -ForegroundColor White

    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host "q" -NoNewline -ForegroundColor Red
    Write-Host "]     Salir" -ForegroundColor White
}

function Show-CommandsInCategory {
    param([string]$Category)

    $manifest = Join-Path $CacheDir "$Category\manifest.json"
    $content  = Get-Content $manifest -Raw | ConvertFrom-Json

    Print-SectionHeader "Comandos en: $($content.displayName)"
    Write-Blank

    $i = 1
    foreach ($cmd in $content.commands) {
        Write-Host "  [" -NoNewline -ForegroundColor DarkGray
        Write-Host "$i" -NoNewline -ForegroundColor Yellow
        Write-Host "] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($cmd.id)" -NoNewline -ForegroundColor White
        Write-Host "  - $($cmd.description)" -ForegroundColor DarkGray
        $i++
    }
}

function Get-CommandsFromCategory {
    param([string]$Category)

    $manifest = Join-Path $CacheDir "$Category\manifest.json"
    $content  = Get-Content $manifest -Raw | ConvertFrom-Json
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

    $script:InstalledCount++
    $script:InstalledFiles += $CmdFile
}

function Install-AllCategories {
    param([array]$Categories)

    Print-SectionHeader "Instalando todas las categorias"
    foreach ($cat in $Categories) {
        $commands = Get-CommandsFromCategory -Category $cat
        foreach ($cmd in $commands) {
            Install-Command -Category $cat -CmdFile $cmd.file
        }
    }
}

# =============================================================================
# RESUMEN FINAL
# =============================================================================

function Print-Summary {
    $width = 62
    Write-Blank
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Host "  RESUMEN DE INSTALACION" -ForegroundColor White
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Blank

    Print-Success "Directorio: $InstallDir"
    Print-Info    "Total instalados: $($script:InstalledCount) comando(s)"

    if ($script:InstalledFiles.Count -gt 0) {
        Write-Blank
        Write-Host "  Comandos disponibles en tu agente IA:" -ForegroundColor White
        Write-Host ("  " + ("-" * 40)) -ForegroundColor DarkGray

        $script:InstalledFiles | Sort-Object | ForEach-Object {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($_)
            Write-Host "    /" -NoNewline -ForegroundColor DarkCyan
            Write-Host $name -ForegroundColor White
        }
    } elseif (Test-Path $InstallDir) {
        Write-Blank
        Write-Host "  Comandos disponibles en tu agente IA:" -ForegroundColor White
        Write-Host ("  " + ("-" * 40)) -ForegroundColor DarkGray

        Get-ChildItem -Path $InstallDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
            Write-Host "    /" -NoNewline -ForegroundColor DarkCyan
            Write-Host $_.BaseName -ForegroundColor White
        }
    }

    Write-Blank
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Host "  Listo. Ya puedes usar los comandos en tu agente IA." -ForegroundColor Green
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Blank
}

# =============================================================================
# FLUJO PRINCIPAL
# =============================================================================

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
        Write-Blank
        Show-Categories -Categories $categories
        Write-Blank
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
            { $_ -in @("todo", "all") } {
                Install-AllCategories -Categories $categories
                $stopInstalling = $true
            }
            default {
                $categoryNumber = 0
                if (-not [int]::TryParse($choice, [ref]$categoryNumber) -or
                    $categoryNumber -lt 1 -or
                    $categoryNumber -gt $categories.Count) {
                    Print-Error "Opcion invalida. Ingresa un numero del 1 al $($categories.Count), 'todo' o 'q'."
                    continue
                }

                $selectedCat = $categories[$categoryNumber - 1]
                Show-CommandsInCategory -Category $selectedCat

                Write-Blank
                Prompt-Input "Selecciona comandos (ej: 1,3,4 o 'todo')" "todo" "cmdChoice"

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

                Write-Blank
                Prompt-Input "Instalar otra categoria? (s/n)" "s" "continue"
                if ($continue.ToLower() -notin @("s", "si", "y", "yes")) {
                    $stopInstalling = $true
                }
            }
        }

        if ($stopInstalling) { break }
    }

    Print-Summary
}

Main
