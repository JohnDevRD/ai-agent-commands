# =============================================================================
# ai-agent-commands - Interactive installer (PowerShell)
# =============================================================================
# Compatible with: Windows PowerShell 5.1+, PowerShell Core 7+
# Usage:
#   iwr -useb https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.ps1 | iex
#   .\install.ps1
# =============================================================================

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# -- Configuration --
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

# -- Output helpers --
function Print-Banner {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  AI Agent Commands - Installer" -ForegroundColor Cyan
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

# -- Installation target --
function Detect-InstallTarget {
    Print-Header "Installation target"
    Write-Host "  1) Current project (./.opencode/commands/)"
    Write-Host "  2) User global (~/.config/opencode/commands/)"
    Write-Host "  3) Custom path"
    Prompt-Input "Choose an option" "1" "choice"

    switch ($choice) {
        "1" { $script:InstallDir = Join-Path (Get-Location) ".opencode\commands" }
        "2" { $script:InstallDir = Join-Path $env:USERPROFILE ".config\opencode\commands" }
        "3" {
            Prompt-Input "Full destination path" "" "customPath"
            $script:InstallDir = $customPath
        }
        default {
            Print-Error "Invalid option"
            exit 1
        }
    }

    Print-Info "Selected target: $InstallDir"
}

# -- Fetch catalog --
function Fetch-Catalog {
    Print-Header "Fetching catalog"

    if (Test-Path (Join-Path $CacheDir ".git")) {
        Print-Info "Updating cached catalog..."
        Push-Location $CacheDir
        try {
            Invoke-GitQuiet @("pull", "origin", $RepoBranch)
        } catch {
            Print-Warning "Could not update cache; using existing local cache"
        } finally {
            Pop-Location
        }
    } else {
        Print-Info "Cloning catalog for the first time..."
        try {
            New-Item -ItemType Directory -Path (Split-Path $CacheDir) -Force | Out-Null
            Invoke-GitQuiet @("clone", "--depth", "1", "--branch", $RepoBranch, $RepoUrl, $CacheDir)
        } catch {
            Print-Error "Could not clone the repository. Check your connection and git installation."
            if ($_.Exception.Message) {
                Print-Warning $_.Exception.Message
            }
            if (Test-Path (Join-Path $ScriptDir ".git")) {
                Print-Warning "Using local repository files as fallback."
                $script:CacheDir = $ScriptDir
            } else {
                exit 1
            }
        }
    }

    if (-not (Test-Path $CacheDir)) {
        Print-Error "Catalog was not found."
        exit 1
    }
}

# -- Catalog helpers --
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

    Print-Header "Available categories"
    $i = 1
    foreach ($cat in $Categories) {
        $manifest = Join-Path $CacheDir "$cat\manifest.json"
        $content = Get-Content $manifest -Raw | ConvertFrom-Json
        $count = if ($content.commands) { $content.commands.Count } else { 0 }
        Write-Host ("  {0}) {1} ({2} commands)" -f $i, $content.displayName, $count) -ForegroundColor Yellow
        $i++
    }
    Write-Host "  all) Install everything" -ForegroundColor Yellow
    Write-Host "  q) Quit" -ForegroundColor Yellow
}

function Show-CommandsInCategory {
    param([string]$Category)

    $manifest = Join-Path $CacheDir "$Category\manifest.json"
    $content = Get-Content $manifest -Raw | ConvertFrom-Json

    Print-Header "Commands in: $($content.displayName)"
    $i = 1
    foreach ($cmd in $content.commands) {
        Write-Host ("  {0}) {1} - {2}" -f $i, $cmd.id, $cmd.description)
        $i++
    }
}

function Install-Command {
    param([string]$Category, [string]$CmdFile)

    $source = Join-Path $CacheDir "$Category\$CmdFile"

    if (-not (Test-Path $source)) {
        Print-Error "File not found: $source"
        return
    }

    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $dest = Join-Path $InstallDir $CmdFile
    if (Test-Path $dest) {
        Print-Warning "Overwriting: $CmdFile"
    }

    Copy-Item $source $dest -Force
    Print-Success "Installed: $CmdFile"
}

# -- Main flow --
function Main {
    Print-Banner
    Detect-InstallTarget
    Fetch-Catalog

    $categories = Get-Categories
    if ($categories.Count -eq 0) {
        Print-Error "No categories found in catalog."
        exit 1
    }

    while ($true) {
        Write-Host ""
        Show-Categories -Categories $categories
        Write-Host ""
        Prompt-Input "Select category, 'all', or 'q'" "" "choice"

        switch ($choice.ToLower()) {
            "q" {
                Print-Info "Exiting..."
                exit 0
            }
            "all" {
                Print-Header "Installing all categories"
                foreach ($cat in $categories) {
                    $catDir = Join-Path $CacheDir $cat
                    Get-ChildItem -Path $catDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
                        Install-Command -Category $cat -CmdFile $_.Name
                    }
                }
                Print-Success "Everything installed."
                break
            }
            default {
                $categoryNumber = 0
                if (-not [int]::TryParse($choice, [ref]$categoryNumber) -or $categoryNumber -lt 1 -or $categoryNumber -gt $categories.Count) {
                    Print-Error "Invalid option"
                    continue
                }

                $selectedCat = $categories[$categoryNumber - 1]
                Show-CommandsInCategory -Category $selectedCat
                Write-Host ""
                Prompt-Input "Select commands (example: 1,3,4 or 'all')" "all" "cmdChoice"

                $catDir = Join-Path $CacheDir $selectedCat
                $files = @(Get-ChildItem -Path $catDir -Filter "*.md" | Sort-Object Name)

                if ($cmdChoice.ToLower() -eq "all") {
                    foreach ($file in $files) {
                        Install-Command -Category $selectedCat -CmdFile $file.Name
                    }
                } else {
                    $selected = $cmdChoice -split "," | ForEach-Object { [int]$_.Trim() }
                    for ($i = 0; $i -lt $files.Count; $i++) {
                        if ($selected -contains ($i + 1)) {
                            Install-Command -Category $selectedCat -CmdFile $files[$i].Name
                        }
                    }
                }

                Write-Host ""
                Prompt-Input "Install another category?" "y" "continue"
                if ($continue.ToLower() -notin @("s", "si", "y", "yes")) {
                    break
                }
            }
        }

        if ($choice.ToLower() -eq "all") { break }
    }

    Write-Host ""
    Print-Header "Summary"
    Print-Success "Commands installed in: $InstallDir"
    Write-Host ""
    Print-Info "Commands available in your AI agent:"
    if (Test-Path $InstallDir) {
        Get-ChildItem -Path $InstallDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
            Write-Host "  /$($_.BaseName)" -ForegroundColor Green
        }
    }
    Write-Host ""
    Print-Success "Done. You can now use the commands in your AI agent."
}

Main
