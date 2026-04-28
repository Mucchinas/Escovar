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
                Write-EscovarLog "ALERT! The stash in $currentPath has been tampered with." "Red"
                Write-EscovarLog "Type 'New-Escovar' to restart operation." "Yellow"
            }
        }
    }
    
    if ($script:Escovar_LoadedFile) {
        Unload-EscovarFile
    }
}