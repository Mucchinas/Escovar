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