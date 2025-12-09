# 🔐 Quantum-Fiend SecureVault

> A fully offline, military-grade encrypted password manager with a futuristic hacker-style CLI interface

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg)](https://www.microsoft.com/windows)
[![Dart](https://img.shields.io/badge/Dart-3.0+-00B4AB.svg)](https://dart.dev)
[![Encryption: AES-256-GCM](https://img.shields.io/badge/Encryption-AES--256--GCM-red.svg)](https://en.wikipedia.org/wiki/Galois/Counter_Mode)

## ✨ Features

- 🔒 **Military-Grade Encryption** - AES-256-GCM with PBKDF2 key derivation
- 🌐 **100% Offline** - No internet connection required, ever
- 🎨 **Futuristic UI** - Cyberpunk-themed interactive terminal interface
- ⌨️ **Multiple Navigation** - Arrow keys, W/S keys, or number selection
- 📋 **Auto-Clipboard** - Passwords automatically copied with 30-second auto-clear
- 🎲 **Password Generator** - Cryptographically secure random passwords
- 🔍 **Password Analyzer** - Strength analysis and breach database checking
- 🗂️ **Multi-Vault Support** - Manage multiple encrypted vaults
- 🗑️ **Safe Deletion** - Double-confirmation vault deletion
- 💾 **Zero Dependencies** - Standalone executable, no installation required

## 📸 Screenshots

### Main Menu
```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║        QUANTUM-FIEND • SECURE VAULT INTERFACE                    ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║ ▶ [01] 🔐 Create New Vault      Initialize a new encrypted vault║
║   [02] 🔓 Unlock Vault           Access an existing vault        ║
║   [03] 📝 Manage Passwords       Add, view, or modify entries   ║
║   [04] 🎲 Generate Password      Create a secure random password║
║   [05] 🔍 Analyze Password       Check password strength         ║
║   [06] ℹ️  Vault Information     View vault metadata and stats  ║
║   [07] 🗑️  Delete Vault          Permanently delete a vault file║
║   [08] 🚪 Exit                   Close Quantum-Fiend interface  ║
╠══════════════════════════════════════════════════════════════════╣
║  ◆ Navigate: ↑/↓ or W/S or 1-8  •  Enter confirm  •  Q quit     ║
╚══════════════════════════════════════════════════════════════════╝
```

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- Administrator access (one-time installation only)

### Installation

1. **Download** the latest release
2. **Extract** the archive to your preferred location
3. **Run installer** as administrator:
   ```powershell
   Right-click install.bat → "Run as administrator"
   ```
4. **Launch** from any terminal:
   ```powershell
   Quantum-Fiend
   ```

### First-Time Setup

1. **Create your first vault:**
   ```
   Quantum-Fiend
   → Press 1 (Create New Vault)
   → Enter vault name: my_passwords
   → Enter master password: ********
   ```

2. **Add your first password:**
   ```
   → Press 2 (Unlock Vault)
   → Enter master password: ********
   → Press 3 (Manage Passwords)
   → Press 1 (Add New Password)
   → Service: Gmail
   → Username: yourname@gmail.com
   → Password: (or press Enter to generate)
   ```

3. **View your password:**
   ```
   → Press 3 (Manage Passwords)
   → Press 2 (View Password)
   → Type: Gmail
   → Password displayed + auto-copied to clipboard!
   ```

## 📖 Usage Guide

### Creating a Vault

A vault is an encrypted container for your passwords. You can have multiple vaults for different purposes (personal, work, etc.).

```powershell
Quantum-Fiend
→ [01] Create New Vault
→ Enter vault name: work_passwords
→ Enter master password: (choose a strong password)
→ Confirm master password: (re-enter)
```

**Important:** Your master password cannot be recovered if lost!

### Managing Passwords

Once your vault is unlocked, you can:

- **Add Password** - Store a new service credential
- **View Password** - Display and copy a password
- **List All** - See all stored services
- **Search** - Find passwords by service name
- **Update** - Modify existing entries
- **Delete** - Remove entries

### Password Generation

Generate cryptographically secure passwords:

```powershell
→ [04] Generate Password
→ Length: 20
→ Include uppercase? Y
→ Include numbers? Y
→ Include symbols? Y
→ Generated: Zq8#mK2$pL9@nR4%vT6!
→ Auto-copied to clipboard!
```

### Security Features

- **AES-256-GCM** encryption
- **PBKDF2** key derivation (100,000 iterations)
- **HMAC** authentication
- **Zero-knowledge** architecture (passwords never leave your device)
- **Auto-clear** clipboard after 30 seconds
- **Breach detection** against known password databases

## 🔧 Advanced Usage

### Multiple Vaults

You can create separate vaults for different purposes:

```
personal.svault     → Personal accounts
work.svault         → Work credentials
banking.svault      → Financial services
```

When unlocking, Quantum-Fiend will show all available vaults in the current directory.

### Vault Selection

If multiple `.svault` files exist:
1. Quantum-Fiend auto-detects them
2. Shows interactive selection menu
3. Displays vault name and file size
4. Navigate with arrow keys

### Deleting Vaults

**⚠️ Warning:** This action is permanent!

```powershell
→ [07] Delete Vault
→ Select vault to delete
→ Confirm deletion (asked twice)
→ Vault permanently deleted
```

## 🛡️ Security Best Practices

1. **Master Password**
   - Use a unique, strong password (16+ characters)
   - Include uppercase, lowercase, numbers, symbols
   - Never reuse passwords

2. **Vault Storage**
   - Keep `.svault` files in a secure location
   - Consider backing up to encrypted external drive
   - Never store in cloud without additional encryption

3. **Regular Maintenance**
   - Update weak passwords regularly
   - Remove unused entries
   - Check password strength periodically

## 📋 Navigation Controls

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate menu up/down |
| `W` / `S` | Alternative navigation |
| `1-8` | Direct menu selection |
| `Enter` | Confirm selection |
| `Q` | Quit/Back |

## 🔄 Uninstallation

```powershell
Right-click uninstall.bat → "Run as administrator"
```

This removes `Quantum-Fiend.exe` from system PATH.

## 🏗️ Technical Details

### Architecture

```
Quantum-Fiend
├── Encryption Layer (AES-256-GCM)
├── Key Derivation (PBKDF2)
├── Vault Manager
├── Password Generator
├── Clipboard Manager
└── Interactive UI
```

### Dependencies

- **crypto** - SHA-256, HMAC, PBKDF2
- **pointycastle** - AES-GCM encryption
- **path** - Cross-platform paths
- **tint** - Terminal colors

### File Format

Vaults are stored as `.svault` files:
- Binary encrypted format
- Metadata header
- Encrypted password entries
- HMAC authentication tag

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This software is provided "as is" without warranty. Always maintain backups of your password vaults. The developers are not responsible for lost passwords or data.

## 🙏 Acknowledgments

- Built with [Dart](https://dart.dev)
- Encryption powered by [PointyCastle](https://pub.dev/packages/pointycastle)
- Terminal UI with [Tint](https://pub.dev/packages/tint)

---

<div align="center">

**[⬆ Back to Top](#-quantum-fiend-securevault)**

Made with 🔐 by [Quantum-Fiend]([https://github.com/Quantum-Fiend](https://github.com/Quantum-Fiend))

</div>
