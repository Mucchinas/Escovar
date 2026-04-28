# ==========================================
# escovar.ps1 - The Cartel Environment Manager
# ==========================================

$script:Escovar_LoadedFile   = $null
$script:Escovar_TrackedVars  = @{}
$script:Escovar_LastPath     = $null
# Allower folders db
$script:Escovar_LedgerPath   = "$HOME\.config\escovar\ledger.txt"
$script:Escovar_AllowedDb    = @{} 

# Init allowed folders
if (!(Test-Path (Split-Path $script:Escovar_LedgerPath))) {
    New-Item -ItemType Directory -Path (Split-Path $script:Escovar_LedgerPath) -Force | Out-Null
} elseif (Test-Path $script:Escovar_LedgerPath) {
    foreach ($line in (Get-Content $script:Escovar_LedgerPath -ErrorAction SilentlyContinue)) {
        $parts = $line -split '\|', 2
        if ($parts.Count -eq 2) {
            $dir = Split-Path $parts[0]
            $script:Escovar_AllowedDb[$dir] = @{ File = $parts[0]; Hash = $parts[1] }
        }
    }
}

function Write-EscovarLog {
    param([string]$Message, [string]$Color = "DarkCyan")
    Write-Host "[escovar] $Message" -ForegroundColor $Color
}

function Get-EscovarHash {
    param([string]$FilePath)
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
}

# Smuggle command to allow folders/validate .coca files
function smuggle {
    $cwd = (Get-Location).ProviderPath
    # Cerchiamo qualsiasi file con estensione .coca (es. .coca, config.coca)
    $stash = Get-ChildItem -Path $cwd -Filter "*.coca" -File | Select-Object -First 1
    
    if (!$stash) { 
        Write-EscovarLog "Plata o Plomo. No .coca product found in this territory." "Red"
        return 
    }

    $hash = Get-EscovarHash $stash.FullName
    $entry = "$($stash.FullName)|$hash"
    
    # Save allowed on disk
    $allEntries = @()
    if (Test-Path $script:Escovar_LedgerPath) {
        $allEntries = Get-Content $script:Escovar_LedgerPath | Where-Object { $_ -notmatch "^$([regex]::Escape($stash.FullName))\|" }
    }
    $allEntries += $entry
    Set-Content -Path $script:Escovar_LedgerPath -Value $allEntries

    # Update memory
    $script:Escovar_AllowedDb[$cwd] = @{ File = $stash.FullName; Hash = $hash }

    Write-EscovarLog "Bribe accepted. Route secured and added to the ledger." "Green"
    Load-EscovarFile $stash.FullName
}

function Load-EscovarFile {
    param([string]$EnvFile)
    
    Write-EscovarLog "Smuggling payload from '$EnvFile' into the system..."
    $before = Get-ChildItem Env: | Select-Object -ExpandProperty Name
    
    try { 
        # Invoke .coca in memory
        $pureProduct = Get-Content $EnvFile -Raw
        Invoke-Expression $pureProduct
    } catch { 
        Write-Warning "The product is defective: $_" 
    }
    
    $after = Get-ChildItem Env: | Select-Object -ExpandProperty Name

    $script:Escovar_TrackedVars = @{}
    foreach ($name in $after) {
        if ($name -notin $before) {
            $script:Escovar_TrackedVars[$name] = $true
            Write-EscovarLog "  + supplied: $name"
        }
    }
    $script:Escovar_LoadedFile = $EnvFile
}

function Unload-EscovarFile {
    if (-not $script:Escovar_LoadedFile) { return }
    Write-EscovarLog "Burning evidence from '$script:Escovar_LoadedFile'..."
    foreach ($name in $script:Escovar_TrackedVars.Keys) {
        if (Test-Path "Env:$name") { 
            Remove-Item "Env:$name" -Force -ErrorAction SilentlyContinue 
            Write-EscovarLog "  - confiscated: $name"
        }
    }
    $script:Escovar_TrackedVars = @{}
    $script:Escovar_LoadedFile  = $null
}

function Invoke-Escovar {
    $currentPath = (Get-Location).ProviderPath
    
    if ($currentPath -eq $script:Escovar_LastPath) { return }
    $script:Escovar_LastPath = $currentPath

    if ($script:Escovar_AllowedDb.ContainsKey($currentPath)) {
        $allowedData = $script:Escovar_AllowedDb[$currentPath]
        
        if (Test-Path $allowedData.File) {
            $currentHash = Get-EscovarHash $allowedData.File
            if ($currentHash -eq $allowedData.Hash) {
                if ($script:Escovar_LoadedFile -ne $allowedData.File) {
                    Unload-EscovarFile
                    Load-EscovarFile $allowedData.File
                }
                return 
            } else {
                Write-EscovarLog "RAT DETECTED! The stash in $currentPath has been cut or tampered with." "Red"
                Write-EscovarLog "Type 'smuggle' to verify the new purity." "Yellow"
            }
        }
    }
    
    if ($script:Escovar_LoadedFile) {
        Unload-EscovarFile
    }
}

# --- Hooking Prompt ---
if (-not (Get-Command Escovar_OldPrompt -ErrorAction SilentlyContinue)) {
    if (Get-Command prompt -ErrorAction SilentlyContinue) {
        Rename-Item Function:\prompt Escovar_OldPrompt
    } else {
        function Escovar_OldPrompt { "PS $($executionContext.SessionState.Path.CurrentLocation)> " }
    }
    function prompt { Invoke-Escovar; Escovar_OldPrompt }
}