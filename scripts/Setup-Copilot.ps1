<# 
.SYNOPSIS
    Configure les settings VS Code pour une utilisation optimale de GitHub Copilot.

.DESCRIPTION
    Ce script ajoute les parametres recommandes pour Copilot dans le settings.json de VS Code.
    Par defaut, il affiche les settings. Avec -Apply, il les applique.

.PARAMETER Check
    Verifie si les settings sont deja configures.

.PARAMETER Apply
    Applique les settings recommandes (merge, sans ecraser les existants).

.EXAMPLE
    .\Setup-Copilot.ps1
    Affiche les settings recommandes.

.EXAMPLE
    .\Setup-Copilot.ps1 -Check
    Verifie quels settings sont manquants.

.EXAMPLE
    .\Setup-Copilot.ps1 -Apply
    Applique les settings apres confirmation.
#>

param(
    [switch]$Check,
    [switch]$Apply
)

# Settings recommandes pour Copilot
$RecommendedSettings = @{
    "chat.agent.maxRequests" = 100
    "github.copilot.nextEditSuggestions.enabled" = $true
    "chat.tools.autoApprove" = $true
    "chat.tools.terminal.autoApprove" = @(
        "git"
        "npm"
        "npx"
        "dotnet"
        "ng"
        "Copy-Item"
        "Remove-Item"
        "New-Item"
        "Move-Item"
        "Get-Content"
        "Set-Content"
        "mkdir"
        "cd"
        "ls"
        "cat"
        "code"
    )
}

# Chemin du settings.json selon l'OS
function Get-SettingsPath {
    if ($IsWindows -or $env:OS -match "Windows") {
        return "$env:APPDATA\Code\User\settings.json"
    } elseif ($IsMacOS) {
        return "$HOME/Library/Application Support/Code/User/settings.json"
    } else {
        return "$HOME/.config/Code/User/settings.json"
    }
}

# Lire le settings.json actuel
function Get-CurrentSettings {
    $path = Get-SettingsPath
    if (Test-Path $path) {
        return Get-Content $path -Raw | ConvertFrom-Json
    }
    return $null
}

# Afficher les settings recommandes
function Show-RecommendedSettings {
    Write-Host ""
    Write-Host "[INFO] Settings Copilot recommandes :" -ForegroundColor Cyan
    Write-Host ""
    $RecommendedSettings | ConvertTo-Json -Depth 10 | Write-Host
    Write-Host ""
    Write-Host "-> Copie ces settings dans ton settings.json" -ForegroundColor Gray
    Write-Host "-> Ou tape: .\Setup-Copilot.ps1 -Apply" -ForegroundColor Gray
    Write-Host ""
}

# Verifier les settings
function Test-Settings {
    $current = Get-CurrentSettings
    $missing = @()
    $ok = @()

    Write-Host ""
    Write-Host "[CHECK] Verification des settings Copilot :" -ForegroundColor Cyan
    Write-Host ""

    foreach ($key in $RecommendedSettings.Keys) {
        $value = $null
        if ($current -ne $null) {
            $value = $current.PSObject.Properties[$key].Value
        }
        if ($value -eq $RecommendedSettings[$key]) {
            Write-Host "  [OK] $key" -ForegroundColor Green
            $ok += $key
        } else {
            Write-Host "  [X] $key : manquant ou different" -ForegroundColor Red
            $missing += $key
        }
    }

    Write-Host ""
    if ($missing.Count -gt 0) {
        Write-Host "-> $($missing.Count) parametre(s) manquant(s). Tape: .\Setup-Copilot.ps1 -Apply" -ForegroundColor Yellow
    } else {
        Write-Host "-> Tous les settings sont configures !" -ForegroundColor Green
    }
    Write-Host ""
}

# Appliquer les settings
function Set-Settings {
    $path = Get-SettingsPath
    $current = Get-CurrentSettings

    Write-Host ""
    Write-Host "[WARNING] Modification du settings.json" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parametres a ajouter/modifier :" -ForegroundColor White
    foreach ($key in $RecommendedSettings.Keys) {
        Write-Host "  - $key : $($RecommendedSettings[$key])" -ForegroundColor Gray
    }
    Write-Host ""

    $confirm = Read-Host "Confirmer ? (oui/non)"
    if ($confirm -ne "oui") {
        Write-Host "Annule." -ForegroundColor Red
        return
    }

    # Lire le JSON brut et le convertir en hashtable manuellement
    if ($current -eq $null) {
        $currentHash = @{}
    } else {
        $currentHash = @{}
        $current.PSObject.Properties | ForEach-Object { $currentHash[$_.Name] = $_.Value }
    }

    # Merge les settings
    foreach ($key in $RecommendedSettings.Keys) {
        $currentHash[$key] = $RecommendedSettings[$key]
    }

    # Sauvegarder
    $currentHash | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8

    Write-Host ""
    Write-Host "[OK] settings.json mis a jour" -ForegroundColor Green
    foreach ($key in $RecommendedSettings.Keys) {
        Write-Host "  + $key : $($RecommendedSettings[$key])" -ForegroundColor Gray
    }
    Write-Host ""
}

# Main
if ($Check) {
    Test-Settings
} elseif ($Apply) {
    Set-Settings
} else {
    Show-RecommendedSettings
}
