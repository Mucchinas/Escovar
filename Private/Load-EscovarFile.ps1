function Load-EscovarFile {
    param([string]$EnvFile)
    
    Write-EscovarLog "Smuggling payload from '$EnvFile' into the system..."
    
    # Inizializziamo il tracciamento da zero, senza fare snapshot lenti
    $script:Escovar_TrackedVars = @{}
    
    try { 
        $lines = Get-Content $EnvFile -ErrorAction Stop
        
        foreach ($line in $lines) {
            $line = $line.Trim()
            
            # Ignora le righe vuote e i commenti (le regole dell'omertà)
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) { 
                continue 
            }
            
            # Regex: Cerca una CHIAVE (solo lettere/numeri/underscore) seguita da = e da un VALORE
            if ($line -match '^([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.*)$') {
                $key = $Matches[1]
                $val = $Matches[2]
                
                # Se il valore è racchiuso tra virgolette o apici singoli, li rimuove pulendo il prodotto
                if ($val -match '^"(.*)"$' -or $val -match "^'(.*)'$") {
                    $val = $Matches[1]
                }
                
                # Inietta nel sistema e traccia nel registro
                Set-Item "Env:$key" -Value $val
                $script:Escovar_TrackedVars[$key] = $true
                Write-EscovarLog "  + supplied: $key"
            } else {
                # Write-Warning "Impurity detected. Ignoring invalid line: $line"
            }
        }
    } catch { 
        Write-Warning "The product is defective: $_" 
    }
    
    $script:Escovar_LoadedFile = $EnvFile
}