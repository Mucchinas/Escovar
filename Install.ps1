# ==========================================
# Install.ps1 - Escovar Deployment Script
# ==========================================

Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "            Escovar Installer             " -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

# --- 0. Controllo Privilegi ---
$isAdmin = $false
if ($IsWindows) {
    $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
$isRoot = ($IsLinux -and ((id -u) -match "^0$"))
$hasPrivileges = ($isAdmin -or $isRoot)

# --- 1. Determinare i percorsi disponibili ---
$separator = [System.IO.Path]::PathSeparator
$modulePaths = $env:PSModulePath -split $separator

$userModulePath = $modulePaths[0] # Sempre il primo per l'utente corrente

# Trova il percorso globale di sistema (diverso tra OS, solitamente il secondo o terzo)
$globalModulePath = $modulePaths | Where-Object { $_ -match "Program Files|usr/local/share" } | Select-Object -First 1

if (-not $globalModulePath) {
    $globalModulePath = $modulePaths[1] 
}

# --- 2. Chiedere all'utente dove installare ---
Write-Host "Where do you want to deploy the operation?" -ForegroundColor White
Write-Host "[1] Current User  ($userModulePath)" -ForegroundColor Yellow
Write-Host "[2] Global System ($globalModulePath) [Requires Admin/Sudo]" -ForegroundColor Yellow
Write-Host "[3] Cancel" -ForegroundColor Gray

$choice = Read-Host -Prompt "Enter your choice (1/2/3)"

$targetPath = ""
switch ($choice) {
    "1" { $targetPath = Join-Path $userModulePath "Escovar" }
    "2" { 
        if (-not $hasPrivileges) {
            Write-Host "Error: Global deployment requires Administrator/root privileges." -ForegroundColor Red
            Write-Host "Restart your terminal as Admin or run with sudo and try again." -ForegroundColor Yellow
            exit
        }
        $targetPath = Join-Path $globalModulePath "Escovar" 
    }
    "3" { Write-Host "Operation cancelled."; exit }
    default { Write-Host "Invalid choice. Operation cancelled." -ForegroundColor Red; exit }
}

# --- 3. Installazione dei file ---
Write-Host "`nDeploying infrastructure to $targetPath..." -ForegroundColor DarkCyan

if (Test-Path $targetPath) {
    Write-Host "Old cartel infrastructure found. Demolishing..." -ForegroundColor Yellow
    Remove-Item -Path $targetPath -Recurse -Force
}

New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
Copy-Item -Path .\* -Destination $targetPath -Recurse -Exclude ".git", ".gitignore", "Install.ps1", "Uninstall.ps1", "README.md"

Write-Host "Module successfully smuggled." -ForegroundColor Green

# --- 4. Configurazione del Profilo ---
Write-Host "`nDo you want to automatically add Escovar to your PowerShell Profile?" -ForegroundColor White
Write-Host "[1] Yes, Current User Profile" -ForegroundColor Yellow
Write-Host "[2] Yes, All Users Profile (Requires Admin/Sudo)" -ForegroundColor Yellow
Write-Host "[3] No, I will do it manually" -ForegroundColor Gray

$profileChoice = Read-Host -Prompt "Enter your choice (1/2/3)"

$profileToEdit = $null
switch ($profileChoice) {
    "1" { $profileToEdit = $PROFILE.CurrentUserAllHosts }
    "2" { 
        if (-not $hasPrivileges) {
            Write-Host "Error: Modifying All Users profile requires Admin/root. Skipping." -ForegroundColor Red
            exit
        }
        $profileToEdit = $PROFILE.AllUsersAllHosts 
    }
    "3" { Write-Host "Profile integration skipped."; exit }
    default { Write-Host "Invalid choice. Skipping profile integration." -ForegroundColor Red; exit }
}

# Creazione cartella profilo se non esiste
$profileDir = Split-Path $profileToEdit
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$importCommand = "Import-Module Escovar"

# Controllo se il modulo è già nel profilo
$alreadyHooked = $false
if (Test-Path $profileToEdit) {
    $profileContent = Get-Content $profileToEdit -Raw
    if ($profileContent -match "Import-Module Escovar") {
        $alreadyHooked = $true
    }
}

if ($alreadyHooked) {
    Write-Host "Escovar is already hooked in your profile ($profileToEdit)." -ForegroundColor Yellow
} else {
    Add-Content -Path $profileToEdit -Value "`n# Load Escovar - The Cartel Environment Manager`n$importCommand"
    Write-Host "Successfully hooked Escovar into $profileToEdit." -ForegroundColor Green
}

Write-Host "`nInstallation complete. Please restart your PowerShell terminal to begin operations." -ForegroundColor DarkCyan