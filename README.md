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
