# ==========================================
# Uninstall.ps1 - Escovar Cleanup Operation
# ==========================================

Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host " Escovar Uninstaller - Burning Evidence" -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isRoot = ($IsLinux -and (id -u) -eq "0")
$hasAdminPrivileges = $isAdmin -or $isRoot

# --- 1. Find and Destroy the Module ---
Write-Host "Scanning for cartel infrastructure..." -ForegroundColor White

$separator = [System.IO.Path]::PathSeparator
$modulePaths = $env:PSModulePath -split $separator
$infrastructureFound = $false

foreach ($path in $modulePaths) {
    $targetPath = Join-Path $path "Escovar"
    if (Test-Path $targetPath) {
        $infrastructureFound = $true
        Write-Host "Found operation at: $targetPath" -ForegroundColor Yellow
        
        # Check if it's a system path requiring admin rights
        if ($path -match "Program Files|usr/local/share" -and -not $hasAdminPrivileges) {
            Write-Host "Error: Cannot remove global infrastructure without Admin/root privileges." -ForegroundColor Red
            Write-Host "Run this script again as Administrator/sudo to complete the cleanup." -ForegroundColor Yellow
            continue
        }

        Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop
        Write-Host "Infrastructure demolished." -ForegroundColor Green
    }
}

if (-not $infrastructureFound) {
    Write-Host "No module infrastructure found on the system." -ForegroundColor Gray
}

# --- 2. Clean up the Profiles ---
Write-Host "`nScrubbing traces from PowerShell profiles..." -ForegroundColor White

# Collect all possible profile paths
$profiles = @($PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost, $PROFILE.AllUsersAllHosts, $PROFILE.AllUsersCurrentHost) | Select-Object -Unique

foreach ($p in $profiles) {
    if (Test-Path $p) {
        $content = Get-Content $p -Raw
        if ($content -match "Escovar") {
            if ($p -match "AllUsers" -and -not $hasAdminPrivileges) {
                Write-Host "Warning: Cannot scrub global profile $p (Requires Admin/root)." -ForegroundColor Yellow
                continue
            }
            
            # Read lines, filter out anything mentioning Escovar, and overwrite
            $cleanLines = Get-Content $p | Where-Object { $_ -notmatch "Escovar" }
            Set-Content -Path $p -Value ($cleanLines -join "`r`n") -Force
            Write-Host "Scrubbed profile: $p" -ForegroundColor Green
        }
    }
}

# --- 3. Burn the Ledger ---
Write-Host "`nDo you want to burn the ledger and all operation records? (~/.config/escovar)" -ForegroundColor White
Write-Host "Warning: This will permanently delete your authorized routes list." -ForegroundColor Yellow
$burnChoice = Read-Host -Prompt "Burn evidence? (y/N)"

if ($burnChoice -match "^[yY]") {
    $ledgerDir = "$HOME/.config/escovar"
    if (Test-Path $ledgerDir) {
        Remove-Item -Path $ledgerDir -Recurse -Force
        Write-Host "Ledger burned to ashes." -ForegroundColor Green
    } else {
        Write-Host "No ledger found to burn." -ForegroundColor Gray
    }
} else {
    Write-Host "Ledger preserved." -ForegroundColor Gray
}

Write-Host "`nCleanup operation complete. The cartel was never here." -ForegroundColor DarkCyan