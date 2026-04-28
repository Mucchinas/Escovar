# ==========================================
# Escovar Module Main Entry Point
# ==========================================

$moduleRoot = $PSScriptRoot

# Load Private functions
Get-ChildItem -Path (Join-Path $moduleRoot "Private") -Filter "*.ps1" -File | ForEach-Object { . $_.FullName }

# Load Public functions
Get-ChildItem -Path (Join-Path $moduleRoot "Public") -Filter "*.ps1" -File | ForEach-Object { . $_.FullName }

# Initialize ledger and prompt hook
Initialize-Escovar

# Expose only public commands
Export-ModuleMember -Function New-Escovar, Get-Escovar, Remove-Escovar, Invoke-Escovar