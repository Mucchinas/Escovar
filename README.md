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
- **Cartel Theme:** Manage your .coca files and secure your routes using the 'smuggle' command.

---

## Installation

### 1. Setup the script
Place `escovar.ps1` into a dedicated configuration folder (e.g., `~/.config/escovar/`).

### 2. Hook it into your Profile
Add the following line to your `$PROFILE`:

```powershell
. "$HOME\\.config\\escovar\\escovar.ps1
```

### 3. Create **.coca** file 
Create one in each folder that requires specific env vars:

```text
# .coca
$env:DB_USER = "pablo"
$env:DB_PASS = "plata_o_plomo"
$env:ENVIRONMENT = "production"
```

### 4. Smuggle your vars!
Escovar won't scan your dirs unless explicitly told. Use **smuggle** to mark your folder as scannable. Escovar will permanently
save the current dir and the first suitable **.coca** file as safe and automatically load and unload the env variables once you cd
into that folder:

```console
PS C:\Users\User\Projects\folder> smuggle
[escovar] Bribe accepted. Route secured and added to the ledger.
[escovar] Smuggling payload from 'C:\Users\User\Projects\folder\var.coca' into the system...
[escovar]   + supplied: DB_USER 
[escovar]   + supplied: DB_PASS
[escovar]   + supplied: ENVIRONMENT 
```
It will also restore the env variables to their original state on dir exit:

```console
PS C:\Users\User\Projects\folder> cd ..            
[escovar] Burning evidence from 'C:\Users\User\Projects\folder\var.coca'...
[escovar]   - confiscated: DB_USER 
[escovar]   - confiscated: DB_PASS
[escovar]   - confiscated: ENVIRONMENT 
```

If the **.coca** file hash changes, it must be smuggled again to prevent tampering:

```console
[escovar] RAT DETECTED! The stash in C:\Users\User\Projects\folder has been cut or tampered with.
[escovar] Type 'smuggle' to verify the new purity.
```

Safe dirs and **.coca** hashes are saved in $HOME\\.config\\escovar\\ledger.txt
