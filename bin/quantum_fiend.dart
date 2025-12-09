#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:tint/tint.dart';
import '../lib/crypto/crypto_service.dart';
import '../lib/vault/vault_file_manager.dart';
import '../lib/vault/vault_manager.dart';
import '../lib/utils/animated_ui.dart';
import '../lib/utils/interactive_menu.dart';
import '../lib/utils/terminal_ui.dart';
import '../lib/utils/clipboard.dart';
import '../lib/models/vault_models.dart';

void main(List<String> arguments) async {
  await _launchQuantumFiend();
}

Future<void> _launchQuantumFiend() async {
  // Initialize services
  final crypto = CryptoService();
  final fileManager = VaultFileManager(crypto);
  final vaultManager = VaultManager(crypto, fileManager);

  // Startup sequence
  await _startupSequence();

  // Main interactive loop
  while (true) {
    final shouldExit = await _showMainMenu(crypto, fileManager, vaultManager);
    if (shouldExit) break;
  }

  await _shutdownSequence();
}

Future<void> _startupSequence() async {
  AnimatedUI.clearScreen();
  
  // Quick glitch intro
  await AnimatedUI.glitchText('INITIALIZING QUANTUM-FIEND PROTOCOL...', iterations: 2);
  await Future.delayed(Duration(milliseconds: 200));
  
  // Fast loading with bright theme
  print('');
  print('${'['.cyan()}${'█' * 50}${']'.cyan()} ${'100%'.green()}');
  await Future.delayed(Duration(milliseconds: 300));
  
  // Bright themed banner
  print('');
  print('╔${'═' * 68}╗'.cyan());
  print('║ ${' ' * 66} ║'.cyan());
  
  // SECUREVAULT text with bright colors
  final banner = '''
║        ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗       ║
║        ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝       ║
║        ███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗         ║
║        ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝         ║
║        ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗       ║
║        ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝       ║
║                                                                ║
║        ██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗                ║
║        ██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝                ║
║        ██║   ██║███████║██║   ██║██║     ██║                   ║
║        ╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║                   ║
║         ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║                   ║
║          ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝                   ║''';
  
  print(banner.cyan());
  
  print('║ ${' ' * 66} ║'.cyan());
  print('╚${'═' * 68}╝'.cyan());
  
  await Future.delayed(Duration(milliseconds: 200));
  
  // Bright status line
  final timestamp = DateTime.now().toIso8601String().substring(11, 19);
  print('');
  print('  ${'◆'.green()} ${'Encrypted Password Manager'.white().bold()}  ${'•'.white()}  ${'Fully Offline'.white()}  ${'•'.white()}  ${'AES-256-GCM'.white()}');
  print('  ${'◆'.green()} ${'System ready'.green()}  ${'[$timestamp]'.white()}  ${'◆'.blue()} ${'Quantum-Fiend protocol active'.blue()}');
  print('');
  
  await Future.delayed(Duration(milliseconds: 300));
}

Future<bool> _showMainMenu(
  CryptoService crypto,
  VaultFileManager fileManager,
  VaultManager vaultManager,
) async {
  final menu = InteractiveMenu(
    title: 'QUANTUM-FIEND • SECURE VAULT INTERFACE',
    items: [
      MenuItem(
        id: 'create',
        title: '🔐 Create New Vault',
        description: 'Initialize a new encrypted vault',
        onSelect: () => _createVault(vaultManager),
      ),
      MenuItem(
        id: 'unlock',
        title: '🔓 Unlock Vault',
        description: 'Access an existing vault',
        onSelect: () => _unlockVault(vaultManager),
      ),
      MenuItem(
        id: 'manage',
        title: '📝 Manage Passwords',
        description: 'Add, view, or modify entries',
        onSelect: () => _managePasswords(vaultManager, crypto),
      ),
      MenuItem(
        id: 'generate',
        title: '🎲 Generate Password',
        description: 'Create a secure random password',
        onSelect: () => _generatePassword(crypto),
      ),
      MenuItem(
        id: 'analyze',
        title: '🔍 Analyze Password',
        description: 'Check password strength',
        onSelect: () => _analyzePassword(crypto),
      ),
      MenuItem(
        id: 'info',
        title: 'ℹ️  Vault Information',
        description: 'View vault metadata and stats',
        onSelect: () => _showVaultInfo(vaultManager),
      ),
      MenuItem(
        id: 'delete',
        title: '🗑️  Delete Vault',
        description: 'Permanently delete a vault file',
        onSelect: () => _deleteVault(),
      ),
      MenuItem(
        id: 'exit',
        title: '🚪 Exit',
        description: 'Close Quantum-Fiend interface',
        onSelect: () async {
          await AnimatedUI.systemMessage('Shutting down...', type: 'INFO');
        },
      ),
    ],
  );

  await menu.show();
  return menu.items[menu.selectedIndex].id == 'exit';
}

Future<void> _unlockVault(VaultManager vaultManager) async {
  AnimatedUI.clearScreen();
  await AnimatedUI.printBanner();
  
  print('═══ UNLOCK VAULT ═══'.cyan().bold());
  print('');

  // Look for vault files in current directory
  final currentDir = Directory.current;
  final vaultFiles = currentDir
      .listSync()
      .where((entity) => entity is File && entity.path.endsWith('.svault'))
      .map((entity) => entity as File)
      .toList();

  String filePath;
  
  if (vaultFiles.isEmpty) {
    print('${'No vault files found in current directory.'.yellow()}');
    print('');
    filePath = TerminalUI.readInput(
      'Vault file path',
      defaultValue: 'vault.svault',
    );
  } else if (vaultFiles.length == 1) {
    // Only one vault, use it directly
    filePath = vaultFiles.first.path;
    final vaultName = path.basenameWithoutExtension(filePath);
    print('${'Found vault:'.white()} ${vaultName.cyan().bold()}');
    print('');
  } else {
    // Multiple vaults, show selection menu
    print('${'Found ${vaultFiles.length} vaults:'.green()}');
    print('');
    
    final vaultItems = vaultFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      final vaultName = path.basenameWithoutExtension(file.path);
      final fileSize = (file.lengthSync() / 1024).toStringAsFixed(1);
      
      return MenuItem(
        id: 'vault_$index',
        title: vaultName,
        description: '$fileSize KB',
        onSelect: () async {},
      );
    }).toList();
    
    vaultItems.add(MenuItem(
      id: 'other',
      title: 'Other vault file...',
      description: 'Enter custom path',
      onSelect: () async {},
    ));
    
    final menu = InteractiveMenu(
      title: 'SELECT VAULT TO UNLOCK',
      items: vaultItems,
    );
    
    await menu.show();
    final selectedIndex = menu.selectedIndex;
    
    if (selectedIndex == vaultFiles.length) {
      // User selected "Other vault file"
      AnimatedUI.clearScreen();
      await AnimatedUI.printBanner();
      print('═══ UNLOCK VAULT ═══'.cyan().bold());
      print('');
      filePath = TerminalUI.readInput(
        'Vault file path',
        defaultValue: 'vault.svault',
      );
    } else {
      filePath = vaultFiles[selectedIndex].path;
    }
  }

  // Display vault name before asking for password
  final vaultName = path.basenameWithoutExtension(filePath);
  print('');
  print('${'Vault:'.white()} ${vaultName.cyan().bold()}');
  print('${'File:'.white()} ${filePath.dim()}');
  print('');
  
  final password = TerminalUI.readPassword('Master password');

  try {
    await vaultManager.unlockVault(password, filePath);
    await AnimatedUI.systemMessage('Vault unlocked successfully!', type: 'SUCCESS');
    await Future.delayed(Duration(seconds: 2));
  } catch (e) {
    await AnimatedUI.systemMessage('Failed to unlock vault: $e', type: 'ERROR');
    await Future.delayed(Duration(seconds: 2));
  }
}

Future<void> _createVault(VaultManager vaultManager) async {
  AnimatedUI.clearScreen();
  await AnimatedUI.printBanner();
  
  print('═══ CREATE NEW VAULT ═══'.cyan().bold());
  print('');

  final name = TerminalUI.readInput('Vault name', defaultValue: 'My Vault');
  final password = TerminalUI.readPassword('Master password');
  final confirmPassword = TerminalUI.readPassword('Confirm password');

  if (password != confirmPassword) {
    await AnimatedUI.systemMessage('Passwords do not match', type: 'ERROR');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  // Analyze password strength
  final strength = vaultManager.crypto.analyzePasswordStrength(password);
  print('');
  print('Password Strength Analysis:');
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);
  print('Feedback: ${strength.feedback}');

  if (strength.score < 5) {
    if (!TerminalUI.confirm('Password is weak. Continue anyway?')) {
      return;
    }
  }

  final filePath = TerminalUI.readInput(
    'Vault file path',
    defaultValue: path.join(Directory.current.path, 'vault.svault'),
  );

  final generateRecovery = TerminalUI.confirm(
    'Generate recovery key?',
    defaultYes: true,
  );

  print('');
  await AnimatedUI.progressBar('Creating vault', durationMs: 1500);

  try {
    final recoveryKey = await vaultManager.createVault(
      name: name,
      password: password,
      filePath: filePath,
      generateRecovery: generateRecovery,
    );

    await AnimatedUI.systemMessage('Vault created successfully!', type: 'SUCCESS');
    await AnimatedUI.systemMessage('Location: $filePath', type: 'INFO');

    if (recoveryKey != null) {
      print('');
      await AnimatedUI.pulseText('⚠ IMPORTANT: Save your recovery key!');
      print('Recovery Key: $recoveryKey'.yellow().bold());
      print('');
    }
  } catch (e) {
    await AnimatedUI.systemMessage('Failed to create vault: $e', type: 'ERROR');
  }

  await Future.delayed(Duration(seconds: 3));
}



Future<void> _managePasswords(VaultManager vaultManager, CryptoService crypto) async {
  if (!vaultManager.isUnlocked) {
    await AnimatedUI.systemMessage('Vault is locked. Please unlock it first.', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  final choice = await QuickMenu.show(
    'PASSWORD MANAGEMENT',
    [
      'Add New Password',
      'View Password',
      'List All Passwords',
      'Search Passwords',
      'Back to Main Menu',
    ],
  );

  if (choice == null || choice == 4) return;

  switch (choice) {
    case 0:
      await _addPassword(vaultManager);
      break;
    case 1:
      await _viewPassword(vaultManager, crypto);
      break;
    case 2:
      await _listPasswords(vaultManager);
      break;
    case 3:
      await _searchPasswords(vaultManager);
      break;
  }
}

Future<void> _addPassword(VaultManager vaultManager) async {
  AnimatedUI.clearScreen();
  print('═══ ADD PASSWORD ENTRY ═══'.cyan().bold());
  print('');

  final service = TerminalUI.readInput('Service/Website');
  final username = TerminalUI.readInput('Username/Email');

  String password;
  if (TerminalUI.confirm('Generate password?', defaultYes: true)) {
    final length = int.tryParse(
          TerminalUI.readInput('Password length', defaultValue: '20'),
        ) ??
        20;
    password = vaultManager.crypto.generatePassword(length: length);
    print('Generated password: $password'.green());
  } else {
    password = TerminalUI.readPassword('Password');
  }

  final notes = TerminalUI.readInput('Notes (optional)');
  final tagsInput = TerminalUI.readInput('Tags (comma-separated, optional)');
  final tags = tagsInput.isEmpty
      ? <String>[]
      : tagsInput.split(',').map((t) => t.trim()).toList();

  print('');
  await AnimatedUI.progressBar('Saving entry', durationMs: 1000);

  try {
    await vaultManager.addEntry(
      service: service,
      username: username,
      password: password,
      notes: notes,
      tags: tags,
    );

    await AnimatedUI.systemMessage('Password entry added successfully!', type: 'SUCCESS');
  } catch (e) {
    await AnimatedUI.systemMessage('Failed to add entry: $e', type: 'ERROR');
  }

  await Future.delayed(Duration(seconds: 2));
}

Future<void> _viewPassword(VaultManager vaultManager, CryptoService crypto) async {
  AnimatedUI.clearScreen();
  print('═══ VIEW PASSWORD ═══'.cyan().bold());
  print('');

  final query = TerminalUI.readInput('Service name');
  final entries = vaultManager.searchEntries(query);

  if (entries.isEmpty) {
    await AnimatedUI.systemMessage('No entries found for: $query', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  PasswordEntry entry;
  if (entries.length > 1) {
    print('');
    print('Multiple entries found:'.yellow());
    for (var i = 0; i < entries.length; i++) {
      print('${i + 1}. ${entries[i].service} (${entries[i].username})');
    }

    final choice = int.tryParse(TerminalUI.readInput('Select entry')) ?? 1;
    if (choice < 1 || choice > entries.length) {
      await AnimatedUI.systemMessage('Invalid selection', type: 'ERROR');
      await Future.delayed(Duration(seconds: 2));
      return;
    }
    entry = entries[choice - 1];
  } else {
    entry = entries.first;
  }

  print('');
  AnimatedUI.separator();
  print('  ${entry.service}'.cyan().bold());
  AnimatedUI.separator();
  print('');
  print('Username: ${entry.username}');
  print('Password: ${entry.password}');
  if (entry.notes.isNotEmpty) print('Notes: ${entry.notes}');
  if (entry.tags.isNotEmpty) print('Tags: ${entry.tags.join(', ')}');
  print('');
  print('Created: ${entry.createdAt}');
  print('Modified: ${entry.modifiedAt}');
  print('Password age: ${entry.passwordAge} days');

  if (entry.needsRotation) {
    await AnimatedUI.systemMessage('Password needs rotation (>90 days old)', type: 'WARNING');
  }

  print('');

  // Auto-copy to clipboard
  try {
    await ClipboardManager.copy(entry.password);
    await AnimatedUI.systemMessage('Password copied to clipboard!', type: 'SUCCESS');
  } catch (e) {
    // Silently fail if clipboard not available
  }


  print('');
  print('${'[Screen will clear in 30 seconds...]'.dim()}');
  await Future.delayed(Duration(seconds: 30));
}

Future<void> _listPasswords(VaultManager vaultManager) async {
  AnimatedUI.clearScreen();
  
  final entries = vaultManager.getAllEntries();

  if (entries.isEmpty) {
    await AnimatedUI.systemMessage('No entries in vault', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  print('═══ PASSWORD ENTRIES (${entries.length}) ═══'.cyan().bold());
  print('');

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

  print('');
  TerminalUI.readInput('Press Enter to continue');
}

Future<void> _searchPasswords(VaultManager vaultManager) async {
  AnimatedUI.clearScreen();
  print('═══ SEARCH PASSWORDS ═══'.cyan().bold());
  print('');

  final query = TerminalUI.readInput('Search query');
  final entries = vaultManager.searchEntries(query);

  if (entries.isEmpty) {
    await AnimatedUI.systemMessage('No entries found for: $query', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  print('');
  print('Search Results (${entries.length})'.green());
  print('');

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

  print('');
  TerminalUI.readInput('Press Enter to continue');
}

Future<void> _generatePassword(CryptoService crypto) async {
  AnimatedUI.clearScreen();
  print('═══ GENERATE SECURE PASSWORD ═══'.cyan().bold());
  print('');

  final length = int.tryParse(
        TerminalUI.readInput('Password length', defaultValue: '20'),
      ) ??
      20;

  print('');
  await AnimatedUI.matrixLoad('Generating password', durationMs: 1000);

  final password = crypto.generatePassword(length: length);
  final strength = crypto.analyzePasswordStrength(password);

  print('');
  await AnimatedUI.pulseText('Generated Password:');
  print(password.green().bold());
  print('');
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);
  print('Feedback: ${strength.feedback}');

  print('');
  // Auto-copy to clipboard
  try {
    await ClipboardManager.copy(password);
    await AnimatedUI.systemMessage('Password copied to clipboard!', type: 'SUCCESS');
  } catch (e) {
    // Silently fail if clipboard not available
  }


  print('');
  print('${'[Screen will clear in 30 seconds...]'.dim()}');
  await Future.delayed(Duration(seconds: 30));
}

Future<void> _analyzePassword(CryptoService crypto) async {
  AnimatedUI.clearScreen();
  print('═══ PASSWORD ANALYSIS ═══'.cyan().bold());
  print('');

  final password = TerminalUI.readPassword('Enter password to analyze');

  print('');
  await AnimatedUI.matrixLoad('Analyzing password', durationMs: 1500);

  final strength = crypto.analyzePasswordStrength(password);

  print('');
  TerminalUI.printPasswordStrength(strength.strength, strength.entropy);
  print('Score: ${strength.score}/10');
  print('Feedback: ${strength.feedback}');

  if (crypto.checkPasswordBreach(password)) {
    await AnimatedUI.systemMessage('This password appears in known breach databases!', type: 'WARNING');
  }

  print('');
  print('${'[Screen will clear in 30 seconds...]'.dim()}');
  await Future.delayed(Duration(seconds: 30));
}

Future<void> _showVaultInfo(VaultManager vaultManager) async {
  if (!vaultManager.isUnlocked) {
    await AnimatedUI.systemMessage('Vault is locked. Please unlock it first.', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  AnimatedUI.clearScreen();
  print('═══ VAULT INFORMATION ═══'.cyan().bold());
  print('');

  final metadata = vaultManager.metadata!;

  print('Name: ${metadata.name}');
  print('Version: ${metadata.version}');
  print('KDF: ${metadata.kdfType}');
  print('Iterations: ${metadata.iterations}');
  print('Created: ${metadata.createdAt}');
  print('Last Modified: ${metadata.lastModified}');
  print('Entries: ${metadata.entryCount}');
  print('Recovery Key: ${metadata.hasRecoveryKey ? "Yes" : "No"}');

  print('');
  TerminalUI.readInput('Press Enter to continue');
}

Future<void> _deleteVault() async {
  AnimatedUI.clearScreen();
  await AnimatedUI.printBanner();
  
  print('═══ DELETE VAULT ═══'.red().bold());
  print('');

  // Look for vault files
  final currentDir = Directory.current;
  final vaultFiles = currentDir
      .listSync()
      .where((entity) => entity is File && entity.path.endsWith('.svault'))
      .map((entity) => entity as File)
      .toList();

  if (vaultFiles.isEmpty) {
    await AnimatedUI.systemMessage('No vault files found in current directory.', type: 'WARNING');
    await Future.delayed(Duration(seconds: 2));
    return;
  }

  String filePath;
  
  if (vaultFiles.length == 1) {
    filePath = vaultFiles.first.path;
    final vaultName = path.basenameWithoutExtension(filePath);
    print('${'Found vault:'.white()} ${vaultName.cyan().bold()}');
    print('');
  } else {
    // Multiple vaults, show selection
    print('${'Select vault to delete:'.yellow()}');
    print('');
    
    final vaultItems = vaultFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      final vaultName = path.basenameWithoutExtension(file.path);
      final fileSize = (file.lengthSync() / 1024).toStringAsFixed(1);
      
      return MenuItem(
        id: 'vault_$index',
        title: vaultName,
        description: '$fileSize KB',
        onSelect: () async {},
      );
    }).toList();
    
    vaultItems.add(MenuItem(
      id: 'cancel',
      title: 'Cancel',
      description: 'Go back to main menu',
      onSelect: () async {},
    ));
    
    final menu = InteractiveMenu(
      title: 'SELECT VAULT TO DELETE',
      items: vaultItems,
    );
    
    await menu.show();
    final selectedIndex = menu.selectedIndex;
    
    if (selectedIndex == vaultFiles.length) {
      // User cancelled
      return;
    }
    
    filePath = vaultFiles[selectedIndex].path;
  }

  // Confirm deletion
  final vaultName = path.basenameWithoutExtension(filePath);
  print('');
  print('${'⚠️  WARNING: This action cannot be undone!'.red().bold()}');
  print('');
  print('${'Vault to delete:'.white()} ${vaultName.red().bold()}');
  print('${'File:'.white()} ${filePath.dim()}');
  print('');

  if (!TerminalUI.confirm('Are you absolutely sure you want to delete this vault?', defaultYes: false)) {
    await AnimatedUI.systemMessage('Deletion cancelled.', type: 'INFO');
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  // Double confirmation
  print('');
  if (!TerminalUI.confirm('This will permanently delete all passwords in this vault. Continue?', defaultYes: false)) {
    await AnimatedUI.systemMessage('Deletion cancelled.', type: 'INFO');
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  try {
    await File(filePath).delete();
    await AnimatedUI.systemMessage('Vault deleted successfully: $vaultName', type: 'SUCCESS');
  } catch (e) {
    await AnimatedUI.systemMessage('Failed to delete vault: $e', type: 'ERROR');
  }

  await Future.delayed(Duration(seconds: 2));
}

Future<void> _shutdownSequence() async {
  AnimatedUI.clearScreen();
  
  print('Initiating shutdown sequence...'.yellow());
  await AnimatedUI.matrixLoad('Clearing memory', durationMs: 800);
  await AnimatedUI.matrixLoad('Locking vault', durationMs: 800);
  await AnimatedUI.matrixLoad('Terminating session', durationMs: 800);
  
  print('');
  await AnimatedUI.glitchText('QUANTUM-FIEND PROTOCOL TERMINATED', iterations: 5);
  await Future.delayed(Duration(milliseconds: 500));
  
  AnimatedUI.clearScreen();
}
