<div align="center">

# 🔐 SecureVault CLI

**A Fully Offline, Encrypted Command-Line Password Manager**

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=for-the-badge)](https://github.com/Quantum-Fiend/securevault-cli)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Encryption](https://img.shields.io/badge/Encryption-AES--256--GCM-red?style=for-the-badge)](https://github.com/Quantum-Fiend/securevault-cli)

*Your passwords, encrypted and offline. Always.*

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Commands](#-commands) • [Security](#-security)

</div>

---

## 🎯 What is SecureVault?

SecureVault is a **desktop-based, terminal password manager** written in pure Dart. It runs entirely on your local machine with **zero network access**, using military-grade encryption to protect your credentials.

### Why SecureVault?

- 🔒 **Military-Grade Encryption**: AES-256-GCM with PBKDF2 key derivation
- 📴 **100% Offline**: No cloud, no sync, no network access
- 💻 **Cross-Platform**: Works on Windows, macOS, and Linux
- 🎨 **Beautiful CLI**: Colored output, tables, and interactive prompts
- 🔐 **Security First**: HMAC integrity, password rotation, breach detection
- 🚀 **Fast & Lightweight**: Native compiled executable

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔐 Security Features
- **AES-256-GCM** authenticated encryption
- **PBKDF2-HMAC-SHA256** (100,000+ iterations)
- **HMAC** integrity verification
- **Clipboard auto-clear** (30 seconds)
- **Password rotation tracking**
- **Breach detection** (common passwords)
- **Recovery key generation**
- **Encrypted activity logs**

</td>
<td width="50%">

### 💻 CLI Features
- **14 powerful commands**
- **Interactive prompts**
- **Password masking**
- **Colored output**
- **ASCII tables**
- **Search & filter**
- **Tags & organization**
- **Export/import vaults**

</td>
</tr>
</table>

---

## 🚀 Installation

### Prerequisites

- **Dart SDK 3.0+**: [Download here](https://dart.dev/get-dart)

### Option 1: Run from Source

```bash
# Clone the repository
git clone https://github.com/Quantum-Fiend/securevault-cli.git
cd securevault-cli

# Install dependencies
dart pub get

# Run the application
dart run bin/main.dart
```

### Option 2: Build Native Executable

```bash
# Build for your platform
dart compile exe bin/main.dart -o vault

# Move to PATH (macOS/Linux)
sudo mv vault /usr/local/bin/

# Move to PATH (Windows - PowerShell as Admin)
Move-Item vault.exe C:\Windows\System32\
```

Now you can use `vault` from anywhere in your terminal!

---

## ⚡ Quick Start

### 1. Create Your First Vault

```bash
vault create
```

<details>
<summary>📸 See example output</summary>

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🔐  SecureVault - Encrypted Password Manager           ║
║                                                           ║
║   Fully Offline • AES-256-GCM • PBKDF2 • HMAC            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════
 Create New Vault
═══════════════════════════════════════════════════════════

Vault name [My Vault]: Personal Passwords
Master password: ****************
Confirm password: ****************
Password Strength: STRONG (78.5 bits)
Generate recovery key? (Y/n): y
Vault file path [./vault.svault]: 

✓ Vault created successfully!
ℹ Location: ./vault.svault

⚠ IMPORTANT: Save your recovery key in a safe place!
Recovery Key: xK9mP2vL8nQ4rT6wY3zA5bC7dE1fG0hJ
```

</details>

### 2. Add a Password

```bash
vault add
```

<details>
<summary>📸 See example output</summary>

```
═══════════════════════════════════════════════════════════
 Add Password Entry
═══════════════════════════════════════════════════════════

Service/Website: GitHub
Username/Email: user@example.com
Generate password? (Y/n): y
Password length [20]: 24
Generated password: X9$mK#pL2@vN8qR!tY4wZ6aB
Notes (optional): Personal GitHub account
Tags (comma-separated, optional): work, development

✓ Password entry added successfully!
```

</details>

### 3. Retrieve a Password

```bash
vault get github
```

<details>
<summary>📸 See example output</summary>

```
═══════════════════════════════════════════════════════════
 GitHub
═══════════════════════════════════════════════════════════

Username: user@example.com
Password: X9$mK#pL2@vN8qR!tY4wZ6aB
Notes: Personal GitHub account
Tags: work, development

Created: 2025-12-09 18:30:00
Modified: 2025-12-09 18:30:00
Password age: 0 days

Copy password to clipboard? (Y/n): y
✓ Password copied! Will auto-clear in 30 seconds.
```

</details>

---

## 📋 Commands

<table>
<tr>
<th>Command</th>
<th>Description</th>
<th>Example</th>
</tr>
<tr>
<td><code>vault create</code></td>
<td>Create a new vault</td>
<td><code>vault create</code></td>
</tr>
<tr>
<td><code>vault unlock &lt;file&gt;</code></td>
<td>Unlock existing vault</td>
<td><code>vault unlock vault.svault</code></td>
</tr>
<tr>
<td><code>vault lock</code></td>
<td>Lock current vault</td>
<td><code>vault lock</code></td>
</tr>
<tr>
<td><code>vault add</code></td>
<td>Add password entry</td>
<td><code>vault add</code></td>
</tr>
<tr>
<td><code>vault get &lt;service&gt;</code></td>
<td>Get password entry</td>
<td><code>vault get github</code></td>
</tr>
<tr>
<td><code>vault list</code></td>
<td>List all entries</td>
<td><code>vault list</code></td>
</tr>
<tr>
<td><code>vault search &lt;query&gt;</code></td>
<td>Search entries</td>
<td><code>vault search work</code></td>
</tr>
<tr>
<td><code>vault generate [length]</code></td>
<td>Generate secure password</td>
<td><code>vault generate 24</code></td>
</tr>
<tr>
<td><code>vault analyze [password]</code></td>
<td>Analyze password strength</td>
<td><code>vault analyze</code></td>
</tr>
<tr>
<td><code>vault export &lt;file&gt;</code></td>
<td>Export vault</td>
<td><code>vault export backup.svault</code></td>
</tr>
<tr>
<td><code>vault import &lt;src&gt; &lt;dst&gt;</code></td>
<td>Import vault</td>
<td><code>vault import backup.svault vault.svault</code></td>
</tr>
<tr>
<td><code>vault info</code></td>
<td>Show vault information</td>
<td><code>vault info</code></td>
</tr>
<tr>
<td><code>vault log</code></td>
<td>Show activity log</td>
<td><code>vault log</code></td>
</tr>
</table>

---

## 🔐 Security

### Encryption Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Master Password                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│          PBKDF2-HMAC-SHA256 (100,000 iterations)        │
│                  + Random Salt (16 bytes)               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              256-bit Encryption Key                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│           AES-256-GCM Authenticated Encryption          │
│                  + Random IV (12 bytes)                 │
│                  + Auth Tag (16 bytes)                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              HMAC-SHA256 Signature                      │
│              (Tamper Detection)                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│            Binary .svault File Format                   │
│         (Encrypted + Authenticated + Signed)            │
└─────────────────────────────────────────────────────────┘
```

### Vault File Format

```
[Magic: SVLT] [Version] [Iterations] [Salt] [IV] [HMAC] [Encrypted Data] [Timestamp]
    4 bytes     4 bytes    4 bytes    16B   12B   32B      variable         8 bytes
```

### Security Guarantees

✅ **What SecureVault Protects Against**:
- ✓ Unauthorized access without master password
- ✓ Data tampering (HMAC verification)
- ✓ Brute force attacks (100,000+ PBKDF2 iterations)
- ✓ Clipboard snooping (30-second auto-clear)
- ✓ Password reuse (breach detection)
- ✓ Weak passwords (strength analyzer)

⚠️ **What SecureVault Cannot Protect Against**:
- ✗ Keyloggers or malware on your device
- ✗ Physical access to unlocked vault
- ✗ Master password disclosure
- ✗ Quantum computing attacks (future threat)

---

## 🛠️ Development

### Project Structure

```
securevault-cli/
├── bin/
│   └── main.dart                    # CLI entry point
├── lib/
│   ├── crypto/
│   │   └── crypto_service.dart      # AES-GCM, PBKDF2, HMAC
│   ├── models/
│   │   └── vault_models.dart        # Data models
│   ├── vault/
│   │   ├── vault_file_manager.dart  # Binary file I/O
│   │   └── vault_manager.dart       # Vault operations
│   └── utils/
│       ├── terminal_ui.dart         # CLI UI utilities
│       └── clipboard.dart           # Clipboard management
├── test/                            # Unit tests
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

### Running Tests

```bash
dart test
```

### Code Quality

```bash
# Analyze code
dart analyze

# Format code
dart format .

# Check for issues
dart fix --dry-run
```

---

## 🐛 Troubleshooting

<details>
<summary><b>Clipboard not working on Linux</b></summary>

Install clipboard utilities:

```bash
# Ubuntu/Debian
sudo apt-get install xclip

# or
sudo apt-get install xsel

# Fedora
sudo dnf install xclip
```

</details>

<details>
<summary><b>Permission denied on macOS/Linux</b></summary>

Make the executable file executable:

```bash
chmod +x vault
```

</details>

<details>
<summary><b>Dart not found</b></summary>

Install Dart SDK:

```bash
# macOS (Homebrew)
brew tap dart-lang/dart
brew install dart

# Windows (Chocolatey)
choco install dart-sdk

# Linux (apt)
sudo apt-get update
sudo apt-get install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update
sudo apt-get install dart
```

</details>

---

## 📊 Comparison

| Feature | SecureVault CLI | 1Password | LastPass | Bitwarden |
|---------|----------------|-----------|----------|-----------|
| **Offline** | ✅ 100% | ❌ Cloud | ❌ Cloud | ❌ Cloud |
| **Open Source** | ✅ Yes | ❌ No | ❌ No | ✅ Yes |
| **CLI** | ✅ Native | ⚠️ Limited | ❌ No | ⚠️ Limited |
| **Encryption** | AES-256-GCM | AES-256 | AES-256 | AES-256 |
| **Cost** | ✅ Free | 💰 Paid | 💰 Freemium | 💰 Freemium |
| **Network** | ❌ Never | ✅ Required | ✅ Required | ✅ Required |
| **Self-Hosted** | ✅ Always | ❌ No | ❌ No | ⚠️ Optional |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Dart style guide
- Add tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

SecureVault is provided "as is" without warranty of any kind. While we implement industry-standard cryptography, we cannot guarantee absolute security. Always maintain backups of important data.

**Use at your own risk.**

---

## 🙏 Acknowledgments

- **Dart Team** - For the excellent language and ecosystem
- **PointyCastle** - For cryptography implementations
- **Open Source Community** - For inspiration and support

---

## 📞 Support

- 📧 **Email**: tusharbisht706@gmail.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/Quantum-Fiend/securevault-cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Quantum-Fiend/securevault-cli/discussions)

---

<div align="center">

**⭐ Star this repo if you find it useful! ⭐**

Made with ❤️ and 🔐 by [Quantum-Fiend](https://github.com/Quantum-Fiend)

**Remember**: Your master password is the key to everything. Choose wisely, store securely, never share.

🔐 **Stay Secure!**

</div>
