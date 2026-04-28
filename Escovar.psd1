@{
    RootModule = 'Escovar.psm1'
    ModuleVersion = '1.0.0'
    GUID = '5c3d69ba-ccf4-474e-a2bd-fb625c22d09a'
    Author = 'Mucchinas'
    CompanyName = 'Celestial Dragon Sect'
    Copyright = '(c) 2026. All rights reserved.'
    Description = 'A blazingly fast, secure, and native direnv alternative for PowerShell.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @('New-Escovar', 'Get-Escovar', 'Remove-Escovar', 'Invoke-Escovar')
    VariablesToExport = @()
    AliasesToExport = @()
    CmdletsToExport = @()

    PrivateData = @{
        PSData = @{
            Tags = @('Environment', 'Variables', 'DotEnv', 'Security', 'Linux', 'Windows')
            ProjectUri = 'https://github.com/Mucchinas/Escovar'
            LicenseUri = 'https://github.com/Mucchinas/Escovar/blob/main/LICENSE'
        }
    }
}