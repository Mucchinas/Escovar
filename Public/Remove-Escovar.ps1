function Remove-Escovar {
    $cwd = (Get-Location).ProviderPath

    # 1. Controlla se la rotta è nel Libro Mastro (RAM)
    if (-not $script:Escovar_AllowedDb.ContainsKey($cwd)) {
        Write-EscovarLog "This territory is not in the ledger. Nothing to burn." "Gray"
        return
    }

    $stashFile = $script:Escovar_AllowedDb[$cwd].File

    # 2. Smantella il carico attivo (Unload)
    if ($script:Escovar_LoadedFile -eq $stashFile) {
        Unload-EscovarFile
    }

    # 3. Rimuovi dal database in RAM
    $script:Escovar_AllowedDb.Remove($cwd)

    # 4. Rimuovi dal Libro Mastro fisico sul disco
    if (Test-Path $script:Escovar_LedgerPath) {
        [array]$allEntries = @(Get-Content $script:Escovar_LedgerPath | Where-Object { $_ -notmatch "^$([regex]::Escape($stashFile))\|" })
        Set-Content -Path $script:Escovar_LedgerPath -Value $allEntries
    }

    Write-EscovarLog "Route burned. All evidence destroyed and ledger updated." "Yellow"
}