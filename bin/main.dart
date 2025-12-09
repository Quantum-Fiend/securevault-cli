#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import '../lib/crypto/crypto_service.dart';
import '../lib/vault/vault_file_manager.dart';
import '../lib/vault/vault_manager.dart';
import '../lib/utils/terminal_ui.dart';
import '../lib/utils/clipboard.dart';
import '../lib/models/vault_models.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version');

  try {
    final argResults = parser.parse(arguments);

    if (argResults['help'] as bool) {
      _printHelp();
      return;
    }

    if (argResults['version'] as bool) {
      print('SecureVault v1.0.0');
      return;
    }

    if (argResults.rest.isEmpty) {
      TerminalUI.printLogo();
      _printHelp();
      return;
    }

    final command = argResults.rest.first;
    final commandArgs = argResults.rest.skip(1).toList();

    // Initialize services
    final crypto = CryptoService();
    final fileManager = VaultFileManager(crypto);
    final vaultManager = VaultManager(crypto, fileManager);

    // Execute command
    await _executeCommand(
      command,
      commandArgs,
      crypto,
      fileManager,
      vaultManager,
    );
  } catch (e) {
    TerminalUI.error('Error: $e');
    exit(1);
  }
}

Future<void> _executeCommand(
  String command,
  List<String> args,
  CryptoService crypto,
  VaultFileManager fileManager,
  VaultManager vaultManager,
) async {
  switch (command) {
    case 'create':
      await _createVault(args, vaultManager);
      break;
    case 'unlock':
      await _unlockVault(args, vaultManager);
      break;
    case 'lock':
      _lockVault(vaultManager);
      break;
    case 'add':
      await _addEntry(args, vaultManager);
      break;
    case 'get':
      await _getEntry(args, vaultManager, crypto);
      break;
    case 'list':
      await _listEntries(args, vaultManager);
      break;
    case 'search':
      await _searchEntries(args, vaultManager);
      break;
    case 'update':
      await _updateEntry(args, vaultManager);
      break;
    case 'delete':
      await _deleteEntry(args, vaultManager);
      break;
    case 'generate':
      _generatePassword(args, crypto);
      break;
    case 'analyze':
      _analyzePassword(args, crypto);
      break;
    case 'export':
      await _exportVault(args, vaultManager);
      break;
    case 'import':
      await _importVault(args, fileManager);
      break;
    case 'info':
      _showVaultInfo(vaultManager);
      break;
    case 'log':
      _showActivityLog(vaultManager);
      break;
    default:
      TerminalUI.error('Unknown command: $command');
      _printHelp();
      exit(1);
  }
}

Future<void> _createVault(List<String> args, VaultManager vaultManager) async {
  TerminalUI.header('Create New Vault');

  final name = TerminalUI.readInput('Vault name', defaultValue: 'My Vault');
  final password = TerminalUI.readPassword('Master password');
  final confirmPassword = TerminalUI.readPassword('Confirm password');

  if (password != confirmPassword) {
    TerminalUI.error('Passwords do not match');
    exit(1);
  }

  // Analyze password strength
  final strength = vaultManager._crypto.analyzePasswordStrength(password);
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);

  if (strength.score < 5) {
    if (!TerminalUI.confirm('Password is weak. Continue anyway?')) {
      exit(0);
    }
  }

  final filePath = args.isNotEmpty
      ? args.first
      : TerminalUI.readInput(
          'Vault file path',
          defaultValue: path.join(Directory.current.path, 'vault.svault'),
        );

  final generateRecovery = TerminalUI.confirm(
    'Generate recovery key?',
    defaultYes: true,
  );

  try {
    final recoveryKey = await vaultManager.createVault(
      name: name,
      password: password,
      filePath: filePath,
      generateRecovery: generateRecovery,
    );

    TerminalUI.success('Vault created successfully!');
    TerminalUI.info('Location: $filePath');

    if (recoveryKey != null) {
      print('');
      TerminalUI.warning('IMPORTANT: Save your recovery key in a safe place!');
      print('Recovery Key: $recoveryKey');
      print('');
    }
  } catch (e) {
    TerminalUI.error('Failed to create vault: $e');
    exit(1);
  }
}

Future<void> _unlockVault(List<String> args, VaultManager vaultManager) async {
  final filePath = args.isNotEmpty
      ? args.first
      : TerminalUI.readInput(
          'Vault file path',
          defaultValue: path.join(Directory.current.path, 'vault.svault'),
        );

  if (!await File(filePath).exists()) {
    TerminalUI.error('Vault file not found: $filePath');
    exit(1);
  }

  final password = TerminalUI.readPassword('Master password');

  try {
    await vaultManager.unlockVault(password, filePath);
    TerminalUI.success('Vault unlocked successfully!');
    TerminalUI.info('Vault: ${vaultManager.metadata?.name}');
    TerminalUI.info('Entries: ${vaultManager.metadata?.entryCount}');
  } catch (e) {
    TerminalUI.error('Failed to unlock vault: $e');
    exit(1);
  }
}

void _lockVault(VaultManager vaultManager) {
  vaultManager.lockVault();
  TerminalUI.success('Vault locked');
}

Future<void> _addEntry(List<String> args, VaultManager vaultManager) async {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  TerminalUI.header('Add Password Entry');

  final service = TerminalUI.readInput('Service/Website');
  final username = TerminalUI.readInput('Username/Email');

  String password;
  if (TerminalUI.confirm('Generate password?', defaultYes: true)) {
    final length = int.tryParse(
          TerminalUI.readInput('Password length', defaultValue: '20'),
        ) ??
        20;
    password = vaultManager._crypto.generatePassword(length: length);
    print('Generated password: $password');
  } else {
    password = TerminalUI.readPassword('Password');
  }

  final notes = TerminalUI.readInput('Notes (optional)');
  final tagsInput = TerminalUI.readInput('Tags (comma-separated, optional)');
  final tags = tagsInput.isEmpty
      ? <String>[]
      : tagsInput.split(',').map((t) => t.trim()).toList();

  try {
    await vaultManager.addEntry(
      service: service,
      username: username,
      password: password,
      notes: notes,
      tags: tags,
    );

    TerminalUI.success('Password entry added successfully!');
  } catch (e) {
    TerminalUI.error('Failed to add entry: $e');
    exit(1);
  }
}

Future<void> _getEntry(
  List<String> args,
  VaultManager vaultManager,
  CryptoService crypto,
) async {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  if (args.isEmpty) {
    TerminalUI.error('Usage: vault get <service>');
    exit(1);
  }

  final query = args.join(' ');
  final entries = vaultManager.searchEntries(query);

  if (entries.isEmpty) {
    TerminalUI.warning('No entries found for: $query');
    return;
  }

  if (entries.length > 1) {
    TerminalUI.warning('Multiple entries found:');
    for (var i = 0; i < entries.length; i++) {
      print('${i + 1}. ${entries[i].service} (${entries[i].username})');
    }

    final choice = int.tryParse(TerminalUI.readInput('Select entry')) ?? 1;
    if (choice < 1 || choice > entries.length) {
      TerminalUI.error('Invalid selection');
      exit(1);
    }

    final entry = entries[choice - 1];
    _displayEntry(entry, crypto);
  } else {
    _displayEntry(entries.first, crypto);
  }
}

void _displayEntry(PasswordEntry entry, CryptoService crypto) {
  TerminalUI.header(entry.service);

  print('Username: ${entry.username}');
  print('Password: ${entry.password}');

  if (entry.notes.isNotEmpty) {
    print('Notes: ${entry.notes}');
  }

  if (entry.tags.isNotEmpty) {
    print('Tags: ${entry.tags.join(', ')}');
  }

  print('');
  print('Created: ${entry.createdAt}');
  print('Modified: ${entry.modifiedAt}');
  print('Password age: ${entry.passwordAge} days');

  if (entry.needsRotation) {
    TerminalUI.warning('⚠ Password needs rotation (>90 days old)');
  }

  print('');

  if (TerminalUI.confirm('Copy password to clipboard?', defaultYes: true)) {
    ClipboardManager.copy(entry.password).then((_) {
      TerminalUI.success('Password copied! Will auto-clear in 30 seconds.');
    }).catchError((e) {
      TerminalUI.warning('Could not copy to clipboard: $e');
    });
  }
}

Future<void> _listEntries(List<String> args, VaultManager vaultManager) async {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  final entries = vaultManager.getAllEntries();

  if (entries.isEmpty) {
    TerminalUI.warning('No entries in vault');
    return;
  }

  TerminalUI.header('Password Entries (${entries.length})');

  final rows = entries.map((e) {
    final ageWarning = e.needsRotation ? '⚠' : '';
    return [
      e.service,
      e.username,
      '${e.passwordAge}d $ageWarning',
      e.tags.join(', '),
    ];
  }).toList();

  TerminalUI.printTable(
    rows,
    headers: ['Service', 'Username', 'Age', 'Tags'],
  );
}

Future<void> _searchEntries(
  List<String> args,
  VaultManager vaultManager,
) async {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  if (args.isEmpty) {
    TerminalUI.error('Usage: vault search <query>');
    exit(1);
  }

  final query = args.join(' ');
  final entries = vaultManager.searchEntries(query);

  if (entries.isEmpty) {
    TerminalUI.warning('No entries found for: $query');
    return;
  }

  TerminalUI.header('Search Results (${entries.length})');

  final rows = entries.map((e) {
    return [
      e.service,
      e.username,
      '${e.passwordAge}d',
    ];
  }).toList();

  TerminalUI.printTable(
    rows,
    headers: ['Service', 'Username', 'Age'],
  );
}

Future<void> _updateEntry(List<String> args, VaultManager vaultManager) async {
  TerminalUI.error('Update command not yet implemented');
  // TODO: Implement update functionality
}

Future<void> _deleteEntry(List<String> args, VaultManager vaultManager) async {
  TerminalUI.error('Delete command not yet implemented');
  // TODO: Implement delete functionality
}

void _generatePassword(List<String> args, CryptoService crypto) {
  final length = args.isNotEmpty ? (int.tryParse(args.first) ?? 20) : 20;

  final password = crypto.generatePassword(length: length);
  final strength = crypto.analyzePasswordStrength(password);

  print('Generated Password: $password');
  print('');
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);
  print('Feedback: ${strength.feedback}');
}

void _analyzePassword(List<String> args, CryptoService crypto) {
  final password = args.isNotEmpty
      ? args.join(' ')
      : TerminalUI.readPassword('Enter password to analyze');

  final strength = crypto.analyzePasswordStrength(password);

  TerminalUI.header('Password Analysis');
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);
  print('Score: ${strength.score}/10');
  print('Feedback: ${strength.feedback}');

  if (crypto.checkPasswordBreach(password)) {
    TerminalUI.warning('⚠ This password appears in known breach databases!');
  }
}

Future<void> _exportVault(List<String> args, VaultManager vaultManager) async {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  final destination = args.isNotEmpty
      ? args.first
      : TerminalUI.readInput('Export to');

  try {
    await vaultManager.exportVault(destination);
    TerminalUI.success('Vault exported to: $destination');
  } catch (e) {
    TerminalUI.error('Failed to export vault: $e');
    exit(1);
  }
}

Future<void> _importVault(
  List<String> args,
  VaultFileManager fileManager,
) async {
  if (args.length < 2) {
    TerminalUI.error('Usage: vault import <source> <destination>');
    exit(1);
  }

  final source = args[0];
  final destination = args[1];

  try {
    await fileManager.importVault(source, destination);
    TerminalUI.success('Vault imported to: $destination');
  } catch (e) {
    TerminalUI.error('Failed to import vault: $e');
    exit(1);
  }
}

void _showVaultInfo(VaultManager vaultManager) {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  final metadata = vaultManager.metadata!;

  TerminalUI.header('Vault Information');

  print('Name: ${metadata.name}');
  print('Version: ${metadata.version}');
  print('KDF: ${metadata.kdfType}');
  print('Iterations: ${metadata.iterations}');
  print('Created: ${metadata.createdAt}');
  print('Last Modified: ${metadata.lastModified}');
  print('Entries: ${metadata.entryCount}');
  print('Recovery Key: ${metadata.hasRecoveryKey ? "Yes" : "No"}');
}

void _showActivityLog(VaultManager vaultManager) {
  if (!vaultManager.isUnlocked) {
    TerminalUI.error('Vault is locked. Please unlock it first.');
    exit(1);
  }

  final log = vaultManager.getActivityLog(limit: 20);

  if (log.isEmpty) {
    TerminalUI.warning('No activity logged');
    return;
  }

  TerminalUI.header('Activity Log');

  for (final entry in log) {
    print('[${entry.timestamp}] ${entry.description}');
  }
}

void _printHelp() {
  print('''
Usage: vault <command> [arguments]

Commands:
  create              Create a new vault
  unlock <file>       Unlock an existing vault
  lock                Lock the current vault
  add                 Add a password entry
  get <service>       Get a password entry
  list                List all entries
  search <query>      Search entries
  update <id>         Update an entry
  delete <id>         Delete an entry
  generate [length]   Generate a secure password
  analyze [password]  Analyze password strength
  export <file>       Export vault to file
  import <src> <dst>  Import vault from file
  info                Show vault information
  log                 Show activity log

Options:
  -h, --help          Show this help message
  -v, --version       Show version

Examples:
  vault create                    Create a new vault
  vault unlock vault.svault       Unlock a vault
  vault add                       Add a new password
  vault get github                Get GitHub password
  vault list                      List all passwords
  vault generate 24               Generate 24-char password
  vault export backup.svault      Export vault

For more information, visit: https://github.com/yourusername/securevault
''');
}
