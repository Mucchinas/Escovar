function Initialize-Escovar {
    # Initialize global state variables
    $script:Escovar_LoadedFile   = $null
    $script:Escovar_TrackedVars  = @{}
    $script:Escovar_LastPath     = $null
    
    # Cross-platform path formatting
    $script:Escovar_LedgerPath   = "$HOME/.config/escovar/ledger.txt"
    $script:Escovar_AllowedDb    = @{} 

    # Init allowed folders db
    $ledgerDir = Split-Path $script:Escovar_LedgerPath
    if (-not (Test-Path $ledgerDir)) {
        New-Item -ItemType Directory -Path $ledgerDir -Force | Out-Null
    } elseif (Test-Path $script:Escovar_LedgerPath) {
        foreach ($line in (Get-Content $script:Escovar_LedgerPath -ErrorAction SilentlyContinue)) {
            $parts = $line -split '\|', 2
            if ($parts.Count -eq 2) {
                $dir = Split-Path $parts[0]
                $script:Escovar_AllowedDb[$dir] = @{ File = $parts[0]; Hash = $parts[1] }
            }
        }
    }

    # Hook Prompt
    if (-not (Get-Command Escovar_OldPrompt -ErrorAction SilentlyContinue)) {
        
        # 1. Catturiamo la funzione prompt originale
        $originalPrompt = Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue
        
        if ($originalPrompt) {
            # 2. Ne iniettiamo il codice in una nuova funzione globale
            Set-Item -Path Function:\global:Escovar_OldPrompt -Value $originalPrompt.ScriptBlock
        } else {
            # Fallback robusto se il sistema non ha un prompt
            function global:Escovar_OldPrompt { "PS $($PWD.ProviderPath)> " }
        }
        
        # 3. Creiamo la nostra vedetta globale
        function global:prompt { 
            Invoke-Escovar
            Escovar_OldPrompt 
        }
    }
}