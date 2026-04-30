# Escovar

**A blazingly fast, secure, and native direnv alternative for PowerShell.**

Escovar (a portmanteau of Escobar and var) is an environment variable manager for PowerShell 7+. It automatically loads and unloads environment variables depending on your current directory, keeping your global scope clean and your secrets secure.

Built with an uncompromising focus on performance and security, Escovar operates with zero disk I/O in unauthorized directories and enforces strict SHA-256 validation for your environment files.

---

## Features

- **Zero-Latency Overhead:** Uses an in-memory Hash Table (O(1) lookups). Escovar never scans your disk unless you are explicitly entering an authorized territory.
- **Cryptographic Security:** Environment files are tracked using SHA-256 hashes. If a file is altered, Escovar locks it down immediately until you manually re-authorize it.
- **Surgical Unload:** Variables injected into your session are tracked. When you exit a directory, Escovar unsets only those specific variables.
- **Native PowerShell:** No external dependencies. Compatible with PowerShell 7+.

---

## Installation

### 1. Installation
Clone the repo and run `Install.ps1` to install the module or run:

```powershell
Install-Module Escovar -Scope CurrentUser
```

### 2. Hook it into your Profile
Add the following line to your `$PROFILE`:

```powershell
Import-Module Escovar
```

or run:

```powershell
if (-not (Test-Path $PROFILE)) { New-Item -Type File -Path $PROFILE -Force }
Add-Content -Path $PROFILE -Value "`n# Escovar - Environment Manager`nImport-Module Escovar"
```

### 3. Create **.coca** file 
Create one in each folder that requires specific env vars:

```text
# .coca
DB_USER = "white"
DB_PASS = "snow"
ENVIRONMENT = "production"
```

### 4. Smuggle your vars!
Escovar won't scan your dirs unless explicitly told. Use **New-Escovar** to mark the current folder as scannable. Escovar will permanently
save the current dir and the first suitable **.coca** file as safe and automatically load the env variables once you cd
into that folder:

```powershell
PS C:\Users\User\Projects\folder> New-Escovar
```
```console
[escovar] Route secured and added to the ledger.
[escovar] Smuggling payload from 'C:\Users\User\Projects\folder\var.coca' into the system...
[escovar]   + supplied: DB_USER 
[escovar]   + supplied: DB_PASS
[escovar]   + supplied: ENVIRONMENT 
```
It will also restore the env variables to their original state on dir exit:

```powershell
PS C:\Users\User\Projects\folder> cd ..
```
```console
[escovar] Burning evidence from 'C:\Users\User\Projects\folder\var.coca'...
[escovar]   - confiscated: DB_USER 
[escovar]   - confiscated: DB_PASS
[escovar]   - confiscated: ENVIRONMENT 
```

If the **.coca** file hash changes, it must be marked again to prevent unwanted behaviour:

```console
[escovar] ALERT! The stash in C:\Users\User\Projects\folder has been tampered with.
[escovar] Type 'New-Escovar' to restart operation.
```

Safe dirs and **.coca** hashes are saved in $HOME\\.config\\escovar\\ledger.txt. Run **Get-Escovar** to see currently overridden vars:

```powershell
PS C:\Users\User\Projects\folder> Get-Escovar
```
```console
[escovar] Current active payload from: C:\Users\User\Projects\folder\vars.coca
  REAL_ENV = ********
```

and **Get-Escovar -a** to see all saved dirs:

```powershell
PS C:\Users\User\Projects\folder> Get-Escovar -a
```
```console
[escovar] Ledger (Authorized Routes):
  Territory: C:\Users\User\Projects\folder -> C:\Users\User\Projects\folder\vars.coca
  Territory: C:\Users\User\Projects\folder1 -> C:\Users\User\Projects\folder1\vars.coca
```

Remove current folder from the **ledger** with **Remove-Escovar**:

```powershell
PS C:\Users\User\Projects\folder> Remove-Escovar
```
```console
[escovar] Burning evidence from 'C:\Users\User\Projects\folder\var.coca'...
[escovar]   - confiscated: REAL_ENV
[escovar] Route burned. All evidence destroyed and ledger updated.
```
