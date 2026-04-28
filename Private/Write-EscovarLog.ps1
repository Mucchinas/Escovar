function Write-EscovarLog {
    param([string]$Message, [string]$Color = "DarkCyan")
    Write-Host "[escovar] $Message" -ForegroundColor $Color
}