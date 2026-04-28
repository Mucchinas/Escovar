function New-Escovar {
    $cwd = (Get-Location).ProviderPath
    
    # Search for any .coca file
    $stash = Get-ChildItem -Path $cwd -Filter "*.coca" -File | Select-Object -First 1
    
    if (-not $stash) { 
        Write-EscovarLog "No .coca product found in this territory." "Red"
        return 
    }

    $hash = Get-EscovarHash $stash.FullName
    $entry = "$($stash.FullName)|$hash"
    
    # Save allowed file hash on disk
    [array]$allEntries = @()
    if (Test-Path $script:Escovar_LedgerPath) {
        # L'uso di @() forza PowerShell a trattare il risultato come una lista anche se c'è una sola riga
        $allEntries = @(Get-Content $script:Escovar_LedgerPath | Where-Object { $_ -notmatch "^$([regex]::Escape($stash.FullName))\|" })
    }
    $allEntries += $entry
    Set-Content -Path $script:Escovar_LedgerPath -Value $allEntries

    # Update in-memory db
    $script:Escovar_AllowedDb[$cwd] = @{ File = $stash.FullName; Hash = $hash }

    Write-EscovarLog "Route secured and added to the ledger." "Green"
    Load-EscovarFile $stash.FullName
}