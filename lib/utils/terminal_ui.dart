import 'dart:io';
import 'package:tint/tint.dart';

/// Terminal UI utilities
class TerminalUI {
  /// Print success message
  static void success(String message) {
    print('✓ $message'.green());
  }

  /// Print error message
  static void error(String message) {
    print('✗ $message'.red());
  }

  /// Print warning message
  static void warning(String message) {
    print('⚠ $message'.yellow());
  }

  /// Print info message
  static void info(String message) {
    print('ℹ $message'.blue());
  }

  /// Print header
  static void header(String text) {
    print('');
    print('═' * 60);
    print(' $text'.bold());
    print('═' * 60);
    print('');
  }

  /// Print table
  static void printTable(List<List<String>> rows, {List<String>? headers}) {
    if (rows.isEmpty) return;

    // Calculate column widths
    final allRows = headers != null ? [headers, ...rows] : rows;
    final columnCount = allRows.first.length;
    final columnWidths = List<int>.filled(columnCount, 0);

    for (final row in allRows) {
      for (var i = 0; i < row.length; i++) {
        columnWidths[i] = columnWidths[i] > row[i].length
            ? columnWidths[i]
            : row[i].length;
      }
    }

    // Print header
    if (headers != null) {
      _printRow(headers, columnWidths, isHeader: true);
      print('─' * (columnWidths.reduce((a, b) => a + b) + columnCount * 3 + 1));
    }

    // Print rows
    for (final row in rows) {
      _printRow(row, columnWidths);
    }
  }

  static void _printRow(
    List<String> row,
    List<int> widths, {
    bool isHeader = false,
  }) {
    final buffer = StringBuffer('│');
    for (var i = 0; i < row.length; i++) {
      final cell = row[i].padRight(widths[i]);
      buffer.write(' ${isHeader ? cell.bold() : cell} │');
    }
    print(buffer.toString());
  }

  /// Read password (masked input)
  static String readPassword(String prompt) {
    stdout.write('$prompt: ');
    try {
      stdin.echoMode = false;
      stdin.lineMode = true;
    } catch (e) {
      // Ignore if not supported
    }
    
    final password = stdin.readLineSync() ?? '';
    
    try {
      stdin.echoMode = true;
      stdin.lineMode = true;
    } catch (e) {
      // Ignore if not supported
    }
    
    print('');
    return password;
  }

  /// Read input
  static String readInput(String prompt, {String? defaultValue}) {
    // Ensure echo mode is on for visible typing
    try {
      stdin.echoMode = true;
      stdin.lineMode = true;
    } catch (e) {
      // Ignore if not supported
    }
    
    if (defaultValue != null) {
      stdout.write('$prompt [$defaultValue]: ');
    } else {
      stdout.write('$prompt: ');
    }
    final input = stdin.readLineSync() ?? '';
    return input.isEmpty ? (defaultValue ?? '') : input;
  }

  /// Confirm action
  static bool confirm(String message, {bool defaultYes = false}) {
    final defaultStr = defaultYes ? 'Y/n' : 'y/N';
    stdout.write('$message ($defaultStr): ');
    final input = (stdin.readLineSync() ?? '').toLowerCase();

    if (input.isEmpty) return defaultYes;
    return input == 'y' || input == 'yes';
  }

  /// Print password strength indicator
  static void printPasswordStrength(String strength, double entropy) {
    final color = switch (strength) {
      'weak' => (String s) => s.red(),
      'medium' => (String s) => s.yellow(),
      'strong' => (String s) => s.green(),
      'excellent' => (String s) => s.blue(),
      _ => (String s) => s,
    };

    print('Password Strength: ${color(strength.toUpperCase())} (${entropy.toStringAsFixed(1)} bits)');
  }

  /// Clear screen
  static void clearScreen() {
    if (Platform.isWindows) {
      print(Process.runSync('cls', [], runInShell: true).stdout);
    } else {
      print(Process.runSync('clear', [], runInShell: true).stdout);
    }
  }

  /// Print logo
  static void printLogo() {
    print('''
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🔐  SecureVault - Encrypted Password Manager           ║
║                                                           ║
║   Fully Offline • AES-256-GCM • PBKDF2 • HMAC             ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
'''.cyan());
  }
}
