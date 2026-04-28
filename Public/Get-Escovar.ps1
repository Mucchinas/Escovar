function Get-Escovar {
    [CmdletBinding()]
    param(
        [Alias('a')]
        [switch]$All
    )

    # Se l'utente usa il flag -All o -a, mostriamo l'intero database
    if ($All) {
        Write-EscovarLog "Ledger (Authorized Routes):" "DarkCyan"
        
        if ($script:Escovar_AllowedDb.Count -eq 0) {
            Write-Host "  (The ledger is currently empty)" -ForegroundColor Gray
            return
        }

        foreach ($territory in $script:Escovar_AllowedDb.Keys) {
            $stash = $script:Escovar_AllowedDb[$territory].File
            Write-Host "  Territory: " -NoNewline
            Write-Host $territory -ForegroundColor Yellow -NoNewline
            Write-Host " -> " -NoNewline
            Write-Host $stash -ForegroundColor Green
        }
        return
    }

    # Comportamento standard: mostra solo il carico attivo
    if (-not $script:Escovar_LoadedFile) {
        Write-EscovarLog "No active payload in the current territory." "Gray"
        return
    }

    Write-EscovarLog "Current active payload from: $script:Escovar_LoadedFile" "DarkCyan"
    
    if ($script:Escovar_TrackedVars.Count -eq 0) {
        Write-Host "  (No variables currently tracked)" -ForegroundColor Gray
    } else {
        foreach ($var in $script:Escovar_TrackedVars.Keys) {
            Write-Host "  $var = ********" -ForegroundColor Green
        }
    }
}