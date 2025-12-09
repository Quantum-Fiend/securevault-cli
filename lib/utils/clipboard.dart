import 'dart:io';
import 'dart:async';

/// Clipboard manager with auto-clear functionality
class ClipboardManager {
  static Timer? _clearTimer;

  /// Copy text to clipboard
  static Future<void> copy(String text, {int clearAfterSeconds = 30}) async {
    try {
      // Cancel existing timer
      _clearTimer?.cancel();

      // Copy to clipboard based on platform
      if (Platform.isWindows) {
        await _copyWindows(text);
      } else if (Platform.isMacOS) {
        await _copyMacOS(text);
      } else if (Platform.isLinux) {
        await _copyLinux(text);
      } else {
        throw UnsupportedError('Clipboard not supported on this platform');
      }

      // Set timer to clear clipboard
      _clearTimer = Timer(Duration(seconds: clearAfterSeconds), () async {
        await clear();
      });
    } catch (e) {
      throw Exception('Failed to copy to clipboard: $e');
    }
  }

  /// Copy to clipboard on Windows
  static Future<void> _copyWindows(String text) async {
    final result = await Process.run(
      'powershell',
      ['-command', 'Set-Clipboard -Value "$text"'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to copy to clipboard');
    }
  }

  /// Copy to clipboard on macOS
  static Future<void> _copyMacOS(String text) async {
    final process = await Process.start('pbcopy', []);
    process.stdin.write(text);
    await process.stdin.close();
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception('Failed to copy to clipboard');
    }
  }

  /// Copy to clipboard on Linux
  static Future<void> _copyLinux(String text) async {
    // Try xclip first
    try {
      final process = await Process.start('xclip', ['-selection', 'clipboard']);
      process.stdin.write(text);
      await process.stdin.close();
      final exitCode = await process.exitCode;

      if (exitCode == 0) return;
    } catch (e) {
      // xclip not available, try xsel
    }

    // Try xsel
    try {
      final process = await Process.start('xsel', ['--clipboard', '--input']);
      process.stdin.write(text);
      await process.stdin.close();
      final exitCode = await process.exitCode;

      if (exitCode == 0) return;
    } catch (e) {
      throw Exception('Clipboard tools not found. Install xclip or xsel.');
    }
  }

  /// Clear clipboard
  static Future<void> clear() async {
    try {
      if (Platform.isWindows) {
        await Process.run(
          'powershell',
          ['-command', 'Set-Clipboard -Value ""'],
          runInShell: true,
        );
      } else if (Platform.isMacOS) {
        final process = await Process.start('pbcopy', []);
        process.stdin.write('');
        await process.stdin.close();
      } else if (Platform.isLinux) {
        try {
          final process = await Process.start('xclip', ['-selection', 'clipboard']);
          process.stdin.write('');
          await process.stdin.close();
        } catch (e) {
          // Ignore if xclip not available
        }
      }
    } catch (e) {
      // Ignore errors when clearing
    }
  }
}
